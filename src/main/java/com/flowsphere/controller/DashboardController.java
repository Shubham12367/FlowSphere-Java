package com.flowsphere.controller;

import com.flowsphere.entity.*;
import com.flowsphere.service.*;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.Authentication;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;

import java.util.List;

@Controller
public class DashboardController {

    @Autowired
    private UserService userService;

    @Autowired
    private RequestService requestService;

    @Autowired
    private ApprovalService approvalService;

    @Autowired
    private TaskService taskService;

    @Autowired
    private NotificationService notificationService;

    @GetMapping("/")
    public String index() {
        return "redirect:/dashboard";
    }

    @GetMapping("/dashboard")
    public String dashboard(Authentication authentication, Model model) {
        if (authentication == null || !authentication.isAuthenticated()) {
            return "redirect:/login";
        }

        User user = userService.findByEmail(authentication.getName()).orElse(null);
        if (user == null) {
            return "redirect:/login";
        }

        boolean isSuperAdmin = user.getRoles().stream().anyMatch(r -> r.getName() == RoleName.SUPER_ADMIN);
        boolean isManager = user.getRoles().stream().anyMatch(r -> r.getName() == RoleName.MANAGER);
        boolean isDeptHead = user.getRoles().stream().anyMatch(r -> r.getName() == RoleName.DEPARTMENT_HEAD);
        boolean isProcessor = user.getRoles().stream().anyMatch(r -> r.getName() == RoleName.PROCESSOR);
        boolean isPrivileged = isSuperAdmin || isManager || isDeptHead || isProcessor;

        // Fetch relevant requests
        List<Request> userRequests = requestService.getRequestsByUser(user.getId());
        List<Request> allRequests = requestService.getAllRequests();
        List<Request> recentRequests = isPrivileged ? allRequests : userRequests;
        if (recentRequests.size() > 8) {
            recentRequests = recentRequests.subList(0, 8);
        }

        // Fetch pending approvals for this user
        List<WorkflowStageInstance> pendingApprovals = approvalService.getPendingApprovalsForUser(user);

        // Fetch tasks
        List<Task> openTasks = taskService.getTasksForUser(user.getId());

        // Calculate summary counts
        long totalCount = isPrivileged ? requestService.countAllRequests() : userRequests.size();
        long pendingCount = isPrivileged ? requestService.countRequestsByStatus(RequestStatus.PENDING_APPROVAL)
                : userRequests.stream().filter(r -> r.getStatus() == RequestStatus.PENDING_APPROVAL).count();
        long completedCount = isPrivileged ? requestService.countRequestsByStatus(RequestStatus.COMPLETED)
                : userRequests.stream().filter(r -> r.getStatus() == RequestStatus.COMPLETED).count();
        long changesReqCount = isPrivileged ? requestService.countRequestsByStatus(RequestStatus.CHANGES_REQUESTED)
                : userRequests.stream().filter(r -> r.getStatus() == RequestStatus.CHANGES_REQUESTED).count();

        model.addAttribute("totalCount", totalCount);
        model.addAttribute("pendingCount", pendingCount);
        model.addAttribute("completedCount", completedCount);
        model.addAttribute("changesReqCount", changesReqCount);
        model.addAttribute("recentRequests", recentRequests);
        model.addAttribute("pendingApprovals", pendingApprovals);
        model.addAttribute("openTasks", openTasks);

        model.addAttribute("isSuperAdmin", isSuperAdmin);
        model.addAttribute("isManager", isManager);
        model.addAttribute("isDeptHead", isDeptHead);
        model.addAttribute("isProcessor", isProcessor);

        return "dashboard";
    }
}
