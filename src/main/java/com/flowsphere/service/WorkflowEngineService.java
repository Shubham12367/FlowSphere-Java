package com.flowsphere.service;

import com.flowsphere.entity.*;
import com.flowsphere.repository.*;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

@Service
public class WorkflowEngineService {

    @Autowired
    private RequestRepository requestRepository;

    @Autowired
    private WorkflowDefinitionRepository workflowDefinitionRepository;

    @Autowired
    private WorkflowVersionRepository workflowVersionRepository;

    @Autowired
    private WorkflowInstanceRepository workflowInstanceRepository;

    @Autowired
    private WorkflowStageInstanceRepository workflowStageInstanceRepository;

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private DepartmentRepository departmentRepository;

    @Autowired
    private NotificationService notificationService;

    @Autowired
    private TaskService taskService;

    @Autowired
    private AuditService auditService;

    @Autowired
    private ApprovalActionRepository approvalActionRepository;

    /**
     * Start a workflow for a submitted request.
     */
    @Transactional
    public WorkflowInstance startWorkflow(Long requestId) {
        Request request = requestRepository.findById(requestId)
                .orElseThrow(() -> new IllegalArgumentException("Request not found: " + requestId));

        if (request.getStatus() != RequestStatus.DRAFT && request.getStatus() != RequestStatus.SUBMITTED) {
            throw new IllegalStateException("Request cannot be started in status: " + request.getStatus());
        }

        // Find active workflow definition matching request type or first active
        WorkflowDefinition definition = workflowDefinitionRepository.findByStatus(WorkflowStatus.ACTIVE)
                .stream()
                .filter(d -> d.getName().equalsIgnoreCase(request.getRequestType()) || 
                             (d.getCategory() != null && d.getCategory().equalsIgnoreCase(request.getRequestType())))
                .findFirst()
                .orElseGet(() -> workflowDefinitionRepository.findByStatus(WorkflowStatus.ACTIVE)
                        .stream().findFirst()
                        .orElseThrow(() -> new IllegalStateException("No active workflow definition configured")));

        // Find latest version
        WorkflowVersion version = workflowVersionRepository.findFirstByWorkflowDefinitionIdOrderByVersionNumberDesc(definition.getId())
                .orElseGet(() -> {
                    WorkflowVersion defaultVersion = new WorkflowVersion();
                    defaultVersion.setWorkflowDefinition(definition);
                    defaultVersion.setVersionNumber(1);
                    defaultVersion.setStagesJson("[{\"order\":1,\"name\":\"Manager Approval\",\"role\":\"MANAGER\"}," +
                                                "{\"order\":2,\"name\":\"IT Department Head Approval\",\"role\":\"DEPARTMENT_HEAD\"}," +
                                                "{\"order\":3,\"name\":\"IT Processor Fulfillment\",\"role\":\"PROCESSOR\"}]");
                    return workflowVersionRepository.save(defaultVersion);
                });

        // Create workflow instance
        WorkflowInstance instance = new WorkflowInstance();
        instance.setRequest(request);
        instance.setWorkflowDefinition(definition);
        instance.setWorkflowVersion(version);
        instance.setStatus(RequestStatus.IN_PROGRESS);
        instance = workflowInstanceRepository.save(instance);

        // Create Stage 1: Manager Approval
        WorkflowStageInstance stage1 = new WorkflowStageInstance();
        stage1.setWorkflowInstance(instance);
        stage1.setStageOrder(1);
        stage1.setStageName("Manager Approval");
        stage1.setStatus(RequestStatus.PENDING_APPROVAL);

        User manager = resolveApproverForStage(1, "MANAGER", request);
        stage1.setAssignedUser(manager);
        stage1 = workflowStageInstanceRepository.save(stage1);

        // Update request status
        request.setStatus(RequestStatus.PENDING_APPROVAL);
        request.setUpdatedAt(LocalDateTime.now());
        requestRepository.save(request);

        // Record initial timeline action
        ApprovalAction submitAction = new ApprovalAction(
                request,
                stage1,
                request.getCreatedBy(),
                "SUBMITTED",
                "Request Submission",
                "Request submitted and assigned to Manager for approval"
        );
        approvalActionRepository.save(submitAction);

        // Create Task for manager
        if (manager != null) {
            taskService.createTask(
                    stage1,
                    "Review Request " + request.getRequestNumber(),
                    "Review and approve " + request.getTitle() + " submitted by " + request.getCreatedBy().getFirstName() + " " + request.getCreatedBy().getLastName(),
                    manager
            );

            notificationService.createNotification(
                    manager,
                    "New Approval Required",
                    "Request " + request.getRequestNumber() + " (" + request.getTitle() + ") is pending your approval."
            );
        }

        // Audit log
        auditService.log(
                request.getCreatedBy(),
                "WORKFLOW_STARTED",
                "Workflow started for request " + request.getRequestNumber() + " with definition: " + definition.getName()
        );

        return instance;
    }

    /**
     * Resolve the approver for a specific stage.
     */
    public User resolveApproverForStage(int stageOrder, String roleRequired, Request request) {
        if (stageOrder == 1 || "MANAGER".equalsIgnoreCase(roleRequired)) {
            // First look for a manager in requester's department
            if (request.getDepartment() != null) {
                List<User> deptManagers = userRepository.findByRolesNameAndDepartmentId(RoleName.MANAGER, request.getDepartment().getId());
                if (!deptManagers.isEmpty()) {
                    return deptManagers.get(0);
                }
            }
            // Fall back to any manager
            List<User> anyManagers = userRepository.findByRolesName(RoleName.MANAGER);
            if (!anyManagers.isEmpty()) {
                return anyManagers.get(0);
            }
        } else if (stageOrder == 2 || "DEPARTMENT_HEAD".equalsIgnoreCase(roleRequired)) {
            // Look for IT department head or any department head
            Optional<Department> itDept = departmentRepository.findByCode("IT");
            if (itDept.isPresent() && itDept.get().getHeadUser() != null) {
                return itDept.get().getHeadUser();
            }
            List<User> heads = userRepository.findByRolesName(RoleName.DEPARTMENT_HEAD);
            if (!heads.isEmpty()) {
                return heads.get(0);
            }
        } else if (stageOrder == 3 || "PROCESSOR".equalsIgnoreCase(roleRequired)) {
            // Look for IT processor
            List<User> processors = userRepository.findByRolesName(RoleName.PROCESSOR);
            if (!processors.isEmpty()) {
                return processors.get(0);
            }
        }

        // Fallback to super admin if specific role not found
        List<User> admins = userRepository.findByRolesName(RoleName.SUPER_ADMIN);
        return admins.isEmpty() ? null : admins.get(0);
    }
}
