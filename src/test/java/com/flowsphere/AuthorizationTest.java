package com.flowsphere;

import com.flowsphere.entity.Priority;
import com.flowsphere.entity.Request;
import com.flowsphere.entity.RoleName;
import com.flowsphere.entity.User;
import com.flowsphere.repository.RequestRepository;
import com.flowsphere.service.ApprovalService;
import com.flowsphere.service.RequestService;
import com.flowsphere.service.UserService;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.transaction.annotation.Transactional;

import static org.junit.jupiter.api.Assertions.*;

@SpringBootTest
class AuthorizationTest {

    @Autowired
    private UserService userService;

    @Autowired
    private RequestService requestService;

    @Autowired
    private ApprovalService approvalService;

    @Autowired
    private RequestRepository requestRepository;

    @Test
    @Transactional
    void testUnauthorizedUserCannotSubmitOthersRequest() {
        User employee1 = userService.findByEmail("employee@flowsphere.local").orElse(null);
        if (employee1 == null) {
            employee1 = userService.findByEmail("employee@test.local").orElseThrow();
        }

        // Register a second employee
        User employee2 = userService.registerUser("other.employee@flowsphere.local", "Password@123", "Other", "Emp", null);

        // Employee 1 creates a draft
        Request request = requestService.createRequest("Confidential Asset Request", "Testing authorization", "IT_SERVICE", Priority.LOW, null, employee1);

        // Employee 2 attempts to submit employee 1's draft -> should fail with AccessDeniedException
        assertThrows(AccessDeniedException.class, () -> {
            requestService.submitRequest(request.getId(), employee2);
        });
    }

    @Test
    @Transactional
    void testEmployeeCannotApproveWorkflowStage() {
        User employee = userService.findByEmail("employee@flowsphere.local").orElse(null);
        if (employee == null) {
            employee = userService.findByEmail("employee@test.local").orElseThrow();
        }

        // Create and submit
        Request request = requestService.createRequest("Printer Cartridge Request", "Need toner", "IT_SERVICE", Priority.LOW, null, employee);
        requestService.submitRequest(request.getId(), employee);

        // Employee should NOT have any pending approvals in their queue
        var approvals = approvalService.getPendingApprovalsForUser(employee);
        assertTrue(approvals.isEmpty());
    }
}
