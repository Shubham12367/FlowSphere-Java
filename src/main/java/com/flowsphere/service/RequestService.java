package com.flowsphere.service;

import com.flowsphere.entity.*;
import com.flowsphere.repository.*;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Service
public class RequestService {

    @Autowired
    private RequestRepository requestRepository;

    @Autowired
    private CommentRepository commentRepository;

    @Autowired
    private WorkflowEngineService workflowEngineService;

    @Autowired
    private AuditService auditService;

    @Autowired
    private ApprovalActionRepository approvalActionRepository;

    /**
     * Create a new draft request.
     */
    @Transactional
    public Request createRequest(String title, String description, String requestType, Priority priority, 
                                 String fieldValuesJson, User creator) {
        if (title == null || title.isBlank()) {
            throw new IllegalArgumentException("Title is mandatory");
        }
        if (requestType == null || requestType.isBlank()) {
            throw new IllegalArgumentException("Request type is mandatory");
        }

        Request request = new Request();
        request.setTitle(title.trim());
        request.setDescription(description);
        request.setRequestType(requestType.trim());
        request.setPriority(priority != null ? priority : Priority.MEDIUM);
        request.setStatus(RequestStatus.DRAFT);
        request.setCreatedBy(creator);
        request.setDepartment(creator.getDepartment());
        request.setFieldValuesJson(fieldValuesJson);

        // Generate unique readable request number
        String timestamp = LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyyMMdd-HHmmss"));
        String shortId = UUID.randomUUID().toString().substring(0, 4).toUpperCase();
        request.setRequestNumber("REQ-" + timestamp + "-" + shortId);

        request = requestRepository.save(request);

        auditService.log(
                creator,
                "REQUEST_CREATED",
                "Draft request " + request.getRequestNumber() + " created: " + request.getTitle()
        );

        return request;
    }

    /**
     * Submit a draft or resubmit a request into workflow.
     */
    @Transactional
    public Request submitRequest(Long requestId, User user) {
        Request request = requestRepository.findById(requestId)
                .orElseThrow(() -> new IllegalArgumentException("Request not found: " + requestId));

        boolean isAdmin = user.getRoles().stream().anyMatch(r -> r.getName() == RoleName.SUPER_ADMIN);
        if (!isAdmin && !request.getCreatedBy().getId().equals(user.getId())) {
            throw new AccessDeniedException("You are not authorized to submit this request");
        }

        if (request.getStatus() != RequestStatus.DRAFT) {
            throw new IllegalStateException("Only DRAFT requests can be submitted (current status: " + request.getStatus() + ")");
        }

        request.setStatus(RequestStatus.SUBMITTED);
        request.setUpdatedAt(LocalDateTime.now());
        request = requestRepository.save(request);

        workflowEngineService.startWorkflow(request.getId());

        return request;
    }

    /**
     * Update an editable draft request.
     */
    @Transactional
    public Request updateDraft(Long requestId, String title, String description, Priority priority, 
                               String fieldValuesJson, User user) {
        Request request = requestRepository.findById(requestId)
                .orElseThrow(() -> new IllegalArgumentException("Request not found: " + requestId));

        boolean isAdmin = user.getRoles().stream().anyMatch(r -> r.getName() == RoleName.SUPER_ADMIN);
        if (!isAdmin && !request.getCreatedBy().getId().equals(user.getId())) {
            throw new AccessDeniedException("You are not authorized to edit this request");
        }

        if (request.getStatus() != RequestStatus.DRAFT && request.getStatus() != RequestStatus.CHANGES_REQUESTED) {
            throw new IllegalStateException("Only DRAFT or CHANGES_REQUESTED requests can be edited");
        }

        if (title != null && !title.isBlank()) {
            request.setTitle(title.trim());
        }
        if (description != null) {
            request.setDescription(description);
        }
        if (priority != null) {
            request.setPriority(priority);
        }
        if (fieldValuesJson != null) {
            request.setFieldValuesJson(fieldValuesJson);
        }

        request.setUpdatedAt(LocalDateTime.now());
        return requestRepository.save(request);
    }

    /**
     * Cancel an active request.
     */
    @Transactional
    public void cancelRequest(Long requestId, User user, String reason) {
        Request request = requestRepository.findById(requestId)
                .orElseThrow(() -> new IllegalArgumentException("Request not found: " + requestId));

        boolean isAdmin = user.getRoles().stream().anyMatch(r -> r.getName() == RoleName.SUPER_ADMIN);
        if (!isAdmin && !request.getCreatedBy().getId().equals(user.getId())) {
            throw new AccessDeniedException("You are not authorized to cancel this request");
        }

        if (request.getStatus() == RequestStatus.COMPLETED || request.getStatus() == RequestStatus.CANCELLED) {
            throw new IllegalStateException("Request cannot be cancelled in status: " + request.getStatus());
        }

        request.setStatus(RequestStatus.CANCELLED);
        request.setRemarks("Cancelled: " + (reason != null ? reason : "Cancelled by user"));
        request.setUpdatedAt(LocalDateTime.now());
        requestRepository.save(request);

        ApprovalAction action = new ApprovalAction(
                request,
                null,
                user,
                "CANCELLED",
                "Cancellation",
                reason != null ? reason : "Cancelled by requester"
        );
        approvalActionRepository.save(action);

        auditService.log(user, "REQUEST_CANCELLED", "Request " + request.getRequestNumber() + " cancelled");
    }

    /**
     * Add a discussion comment to a request.
     */
    @Transactional
    public Comment addComment(Long requestId, User user, String content) {
        if (content == null || content.isBlank()) {
            throw new IllegalArgumentException("Comment content cannot be empty");
        }

        Request request = requestRepository.findById(requestId)
                .orElseThrow(() -> new IllegalArgumentException("Request not found: " + requestId));

        Comment comment = new Comment(request, user, content.trim());
        comment = commentRepository.save(comment);

        auditService.log(user, "COMMENT_ADDED", "Comment added to request " + request.getRequestNumber());
        return comment;
    }

    public List<Comment> getComments(Long requestId) {
        return commentRepository.findByRequestIdOrderByCreatedAtAsc(requestId);
    }

    public Request getRequestById(Long id) {
        return requestRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("Request not found with id: " + id));
    }

    public Optional<Request> getRequestByNumber(String requestNumber) {
        return requestRepository.findByRequestNumber(requestNumber);
    }

    public List<Request> getRequestsByUser(Long userId) {
        return requestRepository.findByCreatedByIdOrderByCreatedAtDesc(userId);
    }

    public List<Request> getAllRequests() {
        return requestRepository.findAllByOrderByCreatedAtDesc();
    }

    public List<Request> getRequestsByDepartment(Long departmentId) {
        return requestRepository.findByDepartmentIdOrderByCreatedAtDesc(departmentId);
    }

    public List<Request> getRequestsByStatus(RequestStatus status) {
        return requestRepository.findByStatusOrderByCreatedAtDesc(status);
    }

    public long countAllRequests() {
        return requestRepository.count();
    }

    public long countRequestsByStatus(RequestStatus status) {
        return requestRepository.countByStatus(status);
    }

    public long countUserRequests(Long userId) {
        return requestRepository.countByCreatedById(userId);
    }
}
