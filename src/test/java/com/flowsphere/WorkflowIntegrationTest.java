package com.flowsphere;

import com.flowsphere.entity.*;
import com.flowsphere.repository.*;
import com.flowsphere.service.*;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

import static org.junit.jupiter.api.Assertions.*;

@SpringBootTest
class WorkflowIntegrationTest {

    @Autowired
    private UserService userService;

    @Autowired
    private RequestService requestService;

    @Autowired
    private ApprovalService approvalService;

    @Autowired
    private WorkflowEngineService workflowEngineService;

    @Autowired
    private RequestRepository requestRepository;

    @Autowired
    private WorkflowStageInstanceRepository workflowStageInstanceRepository;

    @Test
    @Transactional
    void testEndToEndWorkflowApprovalCycle() {
        // Find seeded users
        User employee = userService.findByEmail("employee@flowsphere.local").orElse(null);
        if (employee == null) {
            employee = userService.findByEmail("employee@test.local").orElseThrow();
        }

        User manager = userService.findByEmail("manager@flowsphere.local").orElse(null);
        if (manager == null) {
            manager = userService.findByEmail("manager@test.local").orElseThrow();
        }

        User deptHead = userService.findByEmail("depthead@flowsphere.local").orElse(null);
        if (deptHead == null) {
            deptHead = userService.findByEmail("depthead@test.local").orElseThrow();
        }

        User processor = userService.findByEmail("processor@flowsphere.local").orElse(null);
        if (processor == null) {
            processor = userService.findByEmail("processor@test.local").orElseThrow();
        }

        // 1. Employee creates a draft request
        Request request = requestService.createRequest(
                "MacBook Pro M3 for Software Development",
                "Need updated laptop for Docker and IDE workflows",
                "IT_SERVICE",
                Priority.HIGH,
                "{\"device\":\"MacBook Pro\",\"specs\":\"36GB RAM\"}",
                employee
        );

        assertNotNull(request.getId());
        assertEquals(RequestStatus.DRAFT, request.getStatus());
        assertTrue(request.getRequestNumber().startsWith("REQ-"));

        // 2. Employee submits the request -> kicks off workflow engine
        Request submitted = requestService.submitRequest(request.getId(), employee);
        assertEquals(RequestStatus.PENDING_APPROVAL, submitted.getStatus());

        // Stage 1 (Manager) should be pending
        List<WorkflowStageInstance> managerApprovals = approvalService.getPendingApprovalsForUser(manager);
        assertFalse(managerApprovals.isEmpty(), "Manager should have pending approval");
        WorkflowStageInstance stage1 = managerApprovals.stream()
                .filter(s -> s.getWorkflowInstance().getRequest().getId().equals(request.getId()))
                .findFirst()
                .orElseThrow(() -> new AssertionError("Stage 1 not found for request"));

        assertEquals(1, stage1.getStageOrder());
        assertEquals(RequestStatus.PENDING_APPROVAL, stage1.getStatus());

        // 3. Manager approves Stage 1
        approvalService.approveStage(request.getId(), stage1.getId(), manager, "Approved by Manager. Forwarding to Dept Head.");

        // Stage 2 (Dept Head) should now be pending
        List<WorkflowStageInstance> deptHeadApprovals = approvalService.getPendingApprovalsForUser(deptHead);
        WorkflowStageInstance stage2 = deptHeadApprovals.stream()
                .filter(s -> s.getWorkflowInstance().getRequest().getId().equals(request.getId()))
                .findFirst()
                .orElseThrow(() -> new AssertionError("Stage 2 not found for request"));

        assertEquals(2, stage2.getStageOrder());
        assertEquals(RequestStatus.PENDING_APPROVAL, stage2.getStatus());

        // 4. Dept Head approves Stage 2
        approvalService.approveStage(request.getId(), stage2.getId(), deptHead, "Budget allocated. Forwarding to IT processor.");

        // Stage 3 (Processor) should now be pending
        List<WorkflowStageInstance> processorApprovals = approvalService.getPendingApprovalsForUser(processor);
        WorkflowStageInstance stage3 = processorApprovals.stream()
                .filter(s -> s.getWorkflowInstance().getRequest().getId().equals(request.getId()))
                .findFirst()
                .orElseThrow(() -> new AssertionError("Stage 3 not found for request"));

        assertEquals(3, stage3.getStageOrder());
        assertEquals(RequestStatus.PENDING_APPROVAL, stage3.getStatus());

        // 5. Processor fulfills / completes Stage 3
        approvalService.approveStage(request.getId(), stage3.getId(), processor, "Laptop provisioned and issued.");

        // Request should now be COMPLETED
        Request completedRequest = requestService.getRequestById(request.getId());
        assertEquals(RequestStatus.COMPLETED, completedRequest.getStatus());

        // History verification
        List<ApprovalAction> history = approvalService.getApprovalHistory(request.getId());
        assertEquals(5, history.size()); // SUBMITTED, STAGE 1 APPROVED, STAGE 2 APPROVED, STAGE 3 APPROVED, COMPLETED
    }
}
