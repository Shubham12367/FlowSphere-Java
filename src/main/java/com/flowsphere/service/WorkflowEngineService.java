package com.flowsphere.service;

import com.flowsphere.entity.RoleName;
import com.flowsphere.repository.*;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import java.time.LocalDateTime;
import java.util.Collections;

@Service
public class WorkflowEngineService {

package com.flowsphere.service;

import com.flowsphere.entity.RoleName;
import com.flowsphere.repository.*;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import jakarta.persistence.EntityManager;
import jakarta.persistence.PersistenceContext;

@Service
public class WorkflowEngineService {

    @Autowired
    private RequestRepository requestRepository;

    @Autowired
    private WorkflowDefinitionRepository workflowDefinitionRepository;

    @Autowired
    private WorkflowInstanceRepository workflowInstanceRepository;

    @Autowired
    private WorkflowStageInstanceRepository workflowStageInstanceRepository;

    @Autowired
    private NotificationService notificationService;

    @Autowired
    private AuditLogRepository auditLogRepository;

    @PersistenceContext
    private EntityManager entityManager;

    /**
     * Starts a workflow for the given request. It creates a WorkflowInstance linked to the request,
     * creates the first WorkflowStageInstance according to the first stage defined in the workflow version,
     * assigns it to the appropriate user (e.g., manager), and records audit & notification.
     */
    @Transactional
    public void startWorkflow(Long requestId) {
        Request request = requestRepository.findById(requestId)
                .orElseThrow(() -> new IllegalArgumentException("Request not found: " + requestId));
        // For simplicity, pick the first workflow definition (demo)
        WorkflowDefinition definition = workflowDefinitionRepository.findAll()
                .stream().findFirst()
                .orElseThrow(() -> new IllegalStateException("No workflow definition available"));
        // Use latest version (assume versionNumber ordering)
        WorkflowVersion version = definition.getVersions()
                .stream().max((v1, v2) -> Integer.compare(v1.getVersionNumber(), v2.getVersionNumber()))
                .orElseThrow(() -> new IllegalStateException("No workflow version defined"));

        // Create instance
        WorkflowInstance instance = new WorkflowInstance();
        instance.setRequest(request);
        instance.setWorkflowDefinition(definition);
        instance.setWorkflowVersion(version);
        instance.setStatus(RequestStatus.IN_PROGRESS);
        workflowInstanceRepository.save(instance);

        // Create first stage instance – placeholder stage named "MANAGER_APPROVAL"
        WorkflowStageInstance stage = new WorkflowStageInstance();
        stage.setWorkflowInstance(instance);
        stage.setStageName("MANAGER_APPROVAL");
        stage.setStageOrder(1);
        stage.setStatus(RequestStatus.PENDING_APPROVAL);
        // Assign to manager of the requester's department (simplified)
        User manager = findManagerForDepartment(request.getDepartment());
        stage.setAssignedUser(manager);
        workflowStageInstanceRepository.save(stage);

        // Update request status
        request.setStatus(RequestStatus.PENDING_APPROVAL);
        requestRepository.save(request);

        // Notification to manager
        notificationService.createNotification(manager,
                "New Request Pending Approval",
                "Request " + request.getRequestNumber() + " is awaiting your approval.");

        // Audit log
        AuditLog audit = new AuditLog();
        audit.setUser(request.getCreatedBy());
        audit.setAction("WORKFLOW_STARTED");
        audit.setDetails("Workflow instance " + instance.getId() + " created for request " + request.getRequestNumber());
        auditLogRepository.save(audit);
    }

    private User findManagerForDepartment(Department department) {
        // Simplified: find any user with Role MANAGER in the same department
        return entityManager.createQuery("SELECT u FROM User u JOIN u.roles r WHERE r.name = :role AND u.department = :dept", User.class)
                .setParameter("role", RoleName.MANAGER)
                .setParameter("dept", department)
                .setMaxResults(1)
                .getSingleResult();
    }
}
