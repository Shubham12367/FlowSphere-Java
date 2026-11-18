package com.flowsphere.controller;

import com.flowsphere.entity.User;
import com.flowsphere.entity.WorkflowStageInstance;
import com.flowsphere.repository.WorkflowStageInstanceRepository;
import com.flowsphere.service.ApprovalService;
import com.flowsphere.service.UserService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.Authentication;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import java.util.List;

@Controller
@RequestMapping("/approvals")
public class ApprovalController {

    @Autowired
    private ApprovalService approvalService;

    @Autowired
    private UserService userService;

    @Autowired
    private WorkflowStageInstanceRepository workflowStageInstanceRepository;

    @GetMapping
    public String approvalQueue(Authentication authentication, Model model) {
        User user = userService.findByEmail(authentication.getName()).orElseThrow();
        List<WorkflowStageInstance> pendingApprovals = approvalService.getPendingApprovalsForUser(user);
        model.addAttribute("pendingApprovals", pendingApprovals);
        return "approvals/approval-queue";
    }

    @PostMapping("/{stageId}/approve")
    public String approve(@PathVariable("stageId") Long stageId,
                          @RequestParam(value = "comments", required = false) String comments,
                          Authentication authentication,
                          RedirectAttributes redirectAttributes) {
        try {
            User user = userService.findByEmail(authentication.getName()).orElseThrow();
            WorkflowStageInstance stage = workflowStageInstanceRepository.findById(stageId)
                    .orElseThrow(() -> new IllegalArgumentException("Stage not found: " + stageId));
            Long requestId = stage.getWorkflowInstance().getRequest().getId();

            approvalService.approveStage(requestId, stageId, user, comments);
            redirectAttributes.addFlashAttribute("successMessage", 
                    "Successfully approved stage: " + stage.getStageName());
            return "redirect:/requests/" + requestId;
        } catch (Exception ex) {
            redirectAttributes.addFlashAttribute("errorMessage", "Approval failed: " + ex.getMessage());
            return "redirect:/approvals";
        }
    }

    @PostMapping("/{stageId}/reject")
    public String reject(@PathVariable("stageId") Long stageId,
                         @RequestParam(value = "comments", required = false) String comments,
                         Authentication authentication,
                         RedirectAttributes redirectAttributes) {
        try {
            User user = userService.findByEmail(authentication.getName()).orElseThrow();
            WorkflowStageInstance stage = workflowStageInstanceRepository.findById(stageId)
                    .orElseThrow(() -> new IllegalArgumentException("Stage not found: " + stageId));
            Long requestId = stage.getWorkflowInstance().getRequest().getId();

            approvalService.rejectStage(requestId, stageId, user, comments);
            redirectAttributes.addFlashAttribute("successMessage", 
                    "Request has been rejected at stage: " + stage.getStageName());
            return "redirect:/requests/" + requestId;
        } catch (Exception ex) {
            redirectAttributes.addFlashAttribute("errorMessage", "Rejection failed: " + ex.getMessage());
            return "redirect:/approvals";
        }
    }

    @PostMapping("/{stageId}/request-changes")
    public String requestChanges(@PathVariable("stageId") Long stageId,
                                 @RequestParam(value = "comments", required = false) String comments,
                                 Authentication authentication,
                                 RedirectAttributes redirectAttributes) {
        try {
            User user = userService.findByEmail(authentication.getName()).orElseThrow();
            WorkflowStageInstance stage = workflowStageInstanceRepository.findById(stageId)
                    .orElseThrow(() -> new IllegalArgumentException("Stage not found: " + stageId));
            Long requestId = stage.getWorkflowInstance().getRequest().getId();

            approvalService.requestChanges(requestId, stageId, user, comments);
            redirectAttributes.addFlashAttribute("successMessage", 
                    "Changes have been requested from the applicant.");
            return "redirect:/requests/" + requestId;
        } catch (Exception ex) {
            redirectAttributes.addFlashAttribute("errorMessage", "Failed to request changes: " + ex.getMessage());
            return "redirect:/approvals";
        }
    }
}
