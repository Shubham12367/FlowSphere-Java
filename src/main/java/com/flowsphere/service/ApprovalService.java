package com.flowsphere.service;

import com.flowsphere.entity.*;
import com.flowsphere.repository.*;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

@Service
public class ApprovalService {

    @Autowired
    private RequestRepository requestRepository;

    @Autowired
    private WorkflowInstanceRepository workflowInstanceRepository;

    @Autowired
    private WorkflowStageInstanceRepository workflowStageInstanceRepository;

    @Autowired
    private ApprovalActionRepository approvalActionRepository;

    @Autowired
    private NotificationService notificationService;

    @Autowired
    private TaskService taskService;

    @Autowired
    private AuditService auditService;

    @Autowired
    private WorkflowEngineService workflowEngineService;

    /**
     * Check if a user is authorized to approve/reject a stage.
     */
    public boolean isAuthorized(WorkflowStageInstance stage, User user) {
        if (user == null || stage == null) {
            return false;
        }

        // Super Admin is always authorized
        boolean isSuperAdmin = user.getRoles().stream()
                .anyMatch(r -> r.getName() == RoleName.SUPER_ADMIN);
        if (isSuperAdmin) {
            return true;
        }

        // Assigned user is directly authorized
        if (stage.getAssignedUser() != null && stage.getAssignedUser().getId().equals(user.getId())) {
            return true;
        }

        // Role-based authorization matching stage
        int order = stage.getStageOrder();
        if (order == 1) {
            return user.getRoles().stream().anyMatch(r -> r.getName() == RoleName.MANAGER);
        } else if (order == 2) {
            return user.getRoles().stream().anyMatch(r -> r.getName() == RoleName.DEPARTMENT_HEAD);
        } else if (order == 3) {
            return user.getRoles().stream().anyMatch(r -> r.getName() == RoleName.PROCESSOR);
        }

        return false;
    }

    /**
     * Approve the current stage and advance workflow.
     */
    @Transactional
    public void approveStage(Long requestId, Long stageInstanceId, User decider, String comments) {
        Request request = requestRepository.findById(requestId)
                .orElseThrow(() -> new IllegalArgumentException("Request not found: " + requestId));

        WorkflowStageInstance currentStage = workflowStageInstanceRepository.findById(stageInstanceId)
                .orElseThrow(() -> new IllegalArgumentException("Stage instance not found: " + stageInstanceId));

        if (currentStage.getStatus() != RequestStatus.PENDING_APPROVAL) {
            throw new IllegalStateException("Stage is not pending approval (current: " + currentStage.getStatus() + ")");
        }

        if (!isAuthorized(currentStage, decider)) {
            throw new AccessDeniedException("User " + decider.getEmail() + " is not authorized to approve stage: " + currentStage.getStageName());
        }

        // Complete current stage
        currentStage.setStatus(RequestStatus.APPROVED);
        workflowStageInstanceRepository.save(currentStage);

        // Complete any open tasks for this stage
        taskService.completeTasksForStage(currentStage.getId());

        // Record Approval Action
        ApprovalAction action = new ApprovalAction(
                request,
                currentStage,
                decider,
                "APPROVED",
                currentStage.getStageName(),
                comments != null && !comments.isBlank() ? comments : "Approved by " + decider.getFirstName() + " " + decider.getLastName()
        );
        approvalActionRepository.save(action);

        // Advance to next stage or complete workflow
        WorkflowInstance instance = currentStage.getWorkflowInstance();
        int nextOrder = currentStage.getStageOrder() + 1;

        if (nextOrder <= 3) { // 3-stage standard pipeline: 1: Manager, 2: Dept Head, 3: Processor
            String nextStageName = nextOrder == 2 ? "IT Department Head Approval" : "IT Processor Fulfillment";
            String nextRole = nextOrder == 2 ? "DEPARTMENT_HEAD" : "PROCESSOR";

            WorkflowStageInstance nextStage = new WorkflowStageInstance();
            nextStage.setWorkflowInstance(instance);
            nextStage.setStageOrder(nextOrder);
            nextStage.setStageName(nextStageName);
            nextStage.setStatus(RequestStatus.PENDING_APPROVAL);

            User nextApprover = workflowEngineService.resolveApproverForStage(nextOrder, nextRole, request);
            nextStage.setAssignedUser(nextApprover);
            nextStage = workflowStageInstanceRepository.save(nextStage);

            // Create task and notification for next approver
            if (nextApprover != null) {
                taskService.createTask(
                        nextStage,
                        "Action required: " + request.getRequestNumber(),
                        nextStageName + " for request: " + request.getTitle(),
                        nextApprover
                );

                notificationService.createNotification(
                        nextApprover,
                        "Pending Approval (" + nextStageName + ")",
                        "Request " + request.getRequestNumber() + " is awaiting your review."
                );
            }

            // Notify requester of progress
            notificationService.createNotification(
                    request.getCreatedBy(),
                    "Stage Approved: " + currentStage.getStageName(),
                    "Your request " + request.getRequestNumber() + " was approved by " + decider.getFirstName() + " and forwarded to " + nextStageName + "."
            );

            // Audit
            auditService.log(
                    decider,
                    "STAGE_APPROVED",
                    "Stage " + currentStage.getStageName() + " approved for request " + request.getRequestNumber() + ". Advanced to " + nextStageName
            );

        } else {
            // All stages completed!
            instance.setStatus(RequestStatus.COMPLETED);
            workflowInstanceRepository.save(instance);

            request.setStatus(RequestStatus.COMPLETED);
            request.setUpdatedAt(LocalDateTime.now());
            requestRepository.save(request);

            // Final ApprovalAction
            ApprovalAction completedAction = new ApprovalAction(
                    request,
                    currentStage,
                    decider,
                    "COMPLETED",
                    "Workflow Completion",
                    "All workflow stages successfully approved and fulfilled."
            );
            approvalActionRepository.save(completedAction);

            // Notify requester
            notificationService.createNotification(
                    request.getCreatedBy(),
                    "Request Completed Successfully",
                    "Your request " + request.getRequestNumber() + " (" + request.getTitle() + ") has been fully approved and completed!"
            );

            // Audit
            auditService.log(
                    decider,
                    "REQUEST_COMPLETED",
                    "Request " + request.getRequestNumber() + " fully completed by " + decider.getEmail()
            );
        }
    }

    /**
     * Reject request at current stage.
     */
    @Transactional
    public void rejectStage(Long requestId, Long stageInstanceId, User decider, String comments) {
        Request request = requestRepository.findById(requestId)
                .orElseThrow(() -> new IllegalArgumentException("Request not found: " + requestId));

        WorkflowStageInstance currentStage = workflowStageInstanceRepository.findById(stageInstanceId)
                .orElseThrow(() -> new IllegalArgumentException("Stage instance not found: " + stageInstanceId));

        if (currentStage.getStatus() != RequestStatus.PENDING_APPROVAL) {
            throw new IllegalStateException("Stage is not pending approval (current: " + currentStage.getStatus() + ")");
        }

        if (!isAuthorized(currentStage, decider)) {
            throw new AccessDeniedException("User " + decider.getEmail() + " is not authorized to reject stage: " + currentStage.getStageName());
        }

        currentStage.setStatus(RequestStatus.REJECTED);
        workflowStageInstanceRepository.save(currentStage);

        taskService.completeTasksForStage(currentStage.getId());

        WorkflowInstance instance = currentStage.getWorkflowInstance();
        instance.setStatus(RequestStatus.REJECTED);
        workflowInstanceRepository.save(instance);

        request.setStatus(RequestStatus.REJECTED);
        request.setRemarks(comments);
        request.setUpdatedAt(LocalDateTime.now());
        requestRepository.save(request);

        // Record Approval Action
        ApprovalAction action = new ApprovalAction(
                request,
                currentStage,
                decider,
                "REJECTED",
                currentStage.getStageName(),
                comments != null && !comments.isBlank() ? comments : "Rejected by " + decider.getFirstName() + " " + decider.getLastName()
        );
        approvalActionRepository.save(action);

        // Notify requester
        notificationService.createNotification(
                request.getCreatedBy(),
                "Request Rejected",
                "Your request " + request.getRequestNumber() + " was rejected by " + decider.getFirstName() + ". Reason: " + comments
        );

        // Audit
        auditService.log(
                decider,
                "REQUEST_REJECTED",
                "Request " + request.getRequestNumber() + " rejected at stage " + currentStage.getStageName() + " with reason: " + comments
        );
    }

    /**
     * Request changes on request.
     */
    @Transactional
    public void requestChanges(Long requestId, Long stageInstanceId, User decider, String comments) {
        Request request = requestRepository.findById(requestId)
                .orElseThrow(() -> new IllegalArgumentException("Request not found: " + requestId));

        WorkflowStageInstance currentStage = workflowStageInstanceRepository.findById(stageInstanceId)
                .orElseThrow(() -> new IllegalArgumentException("Stage instance not found: " + stageInstanceId));

        if (currentStage.getStatus() != RequestStatus.PENDING_APPROVAL) {
            throw new IllegalStateException("Stage is not pending approval (current: " + currentStage.getStatus() + ")");
        }

        if (!isAuthorized(currentStage, decider)) {
            throw new AccessDeniedException("User " + decider.getEmail() + " is not authorized to request changes for stage: " + currentStage.getStageName());
        }

        currentStage.setStatus(RequestStatus.CHANGES_REQUESTED);
        workflowStageInstanceRepository.save(currentStage);

        taskService.completeTasksForStage(currentStage.getId());

        request.setStatus(RequestStatus.CHANGES_REQUESTED);
        request.setRemarks(comments);
        request.setUpdatedAt(LocalDateTime.now());
        requestRepository.save(request);

        // Record Approval Action
        ApprovalAction action = new ApprovalAction(
                request,
                currentStage,
                decider,
                "CHANGES_REQUESTED",
                currentStage.getStageName(),
                comments != null && !comments.isBlank() ? comments : "Changes requested"
        );
        approvalActionRepository.save(action);

        // Notify requester
        notificationService.createNotification(
                request.getCreatedBy(),
                "Changes Requested for " + request.getRequestNumber(),
                "Changes were requested on your request by " + decider.getFirstName() + ". Details: " + comments
        );

        // Audit
        auditService.log(
                decider,
                "CHANGES_REQUESTED",
                "Changes requested for request " + request.getRequestNumber() + " at stage " + currentStage.getStageName()
        );
    }

    /**
     * Resubmit request after changes.
     */
    @Transactional
    public void resubmitRequest(Long requestId, User user, String remarks) {
        Request request = requestRepository.findById(requestId)
                .orElseThrow(() -> new IllegalArgumentException("Request not found: " + requestId));

        if (request.getStatus() != RequestStatus.CHANGES_REQUESTED) {
            throw new IllegalStateException("Request is not in CHANGES_REQUESTED status");
        }

        // Only creator or admin can resubmit
        boolean isAdmin = user.getRoles().stream().anyMatch(r -> r.getName() == RoleName.SUPER_ADMIN);
        if (!isAdmin && !request.getCreatedBy().getId().equals(user.getId())) {
            throw new AccessDeniedException("Only the request creator can resubmit this request");
        }

        // Find stage with CHANGES_REQUESTED
        WorkflowInstance instance = workflowInstanceRepository.findByRequestId(request.getId())
                .orElseThrow(() -> new IllegalStateException("No workflow instance for request: " + request.getId()));

        List<WorkflowStageInstance> stages = workflowStageInstanceRepository.findByWorkflowInstanceId(instance.getId());
        WorkflowStageInstance pendingStage = stages.stream()
                .filter(s -> s.getStatus() == RequestStatus.CHANGES_REQUESTED)
                .findFirst()
                .orElse(stages.isEmpty() ? null : stages.get(stages.size() - 1));

        if (pendingStage != null) {
            pendingStage.setStatus(RequestStatus.PENDING_APPROVAL);
            workflowStageInstanceRepository.save(pendingStage);

            if (pendingStage.getAssignedUser() != null) {
                taskService.createTask(
                        pendingStage,
                        "Review Resubmitted Request " + request.getRequestNumber(),
                        "Request resubmitted with updates by " + user.getFirstName(),
                        pendingStage.getAssignedUser()
                );

                notificationService.createNotification(
                        pendingStage.getAssignedUser(),
                        "Request Resubmitted",
                        "Request " + request.getRequestNumber() + " has been resubmitted with updates."
                );
            }
        }

        request.setStatus(RequestStatus.PENDING_APPROVAL);
        request.setRemarks("Resubmitted: " + (remarks != null ? remarks : "Updates made"));
        request.setUpdatedAt(LocalDateTime.now());
        requestRepository.save(request);

        // Record Approval Action
        ApprovalAction action = new ApprovalAction(
                request,
                pendingStage,
                user,
                "RESUBMITTED",
                pendingStage != null ? pendingStage.getStageName() : "Resubmission",
                remarks != null && !remarks.isBlank() ? remarks : "Request resubmitted by creator"
        );
        approvalActionRepository.save(action);

        auditService.log(
                user,
                "REQUEST_RESUBMITTED",
                "Request " + request.getRequestNumber() + " resubmitted after changes"
        );
    }

    /**
     * Get pending approvals accessible to a specific user.
     */
    public List<WorkflowStageInstance> getPendingApprovalsForUser(User user) {
        if (user == null) {
            return new ArrayList<>();
        }

        boolean isSuperAdmin = user.getRoles().stream().anyMatch(r -> r.getName() == RoleName.SUPER_ADMIN);
        boolean isManager = user.getRoles().stream().anyMatch(r -> r.getName() == RoleName.MANAGER);
        boolean isDeptHead = user.getRoles().stream().anyMatch(r -> r.getName() == RoleName.DEPARTMENT_HEAD);
        boolean isProcessor = user.getRoles().stream().anyMatch(r -> r.getName() == RoleName.PROCESSOR);

        List<WorkflowStageInstance> allPending = workflowStageInstanceRepository.findByStatus(RequestStatus.PENDING_APPROVAL);
        List<WorkflowStageInstance> userPending = new ArrayList<>();

        for (WorkflowStageInstance stage : allPending) {
            if (isSuperAdmin) {
                userPending.add(stage);
            } else if (stage.getAssignedUser() != null && stage.getAssignedUser().getId().equals(user.getId())) {
                userPending.add(stage);
            } else if (stage.getStageOrder() == 1 && isManager) {
                // If stage 1 and manager: include if in same department, or if request/manager has no dept, or if unassigned
                Request req = stage.getWorkflowInstance().getRequest();
                if (req.getDepartment() == null || user.getDepartment() == null ||
                    req.getDepartment().getId().equals(user.getDepartment().getId()) ||
                    stage.getAssignedUser() == null) {
                    userPending.add(stage);
                }
            } else if (stage.getStageOrder() == 2 && isDeptHead) {
                userPending.add(stage);
            } else if (stage.getStageOrder() == 3 && isProcessor) {
                userPending.add(stage);
            }
        }

        return userPending;
    }

    /**
     * Get timeline approval actions for a request.
     */
    public List<ApprovalAction> getApprovalHistory(Long requestId) {
        return approvalActionRepository.findByRequestIdOrderByTimestampAsc(requestId);
    }
}
