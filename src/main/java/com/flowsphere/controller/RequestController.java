package com.flowsphere.controller;

import com.flowsphere.entity.*;
import com.flowsphere.repository.WorkflowDefinitionRepository;
import com.flowsphere.repository.WorkflowInstanceRepository;
import com.flowsphere.repository.WorkflowStageInstanceRepository;
import com.flowsphere.service.*;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.Authentication;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import java.util.List;
import java.util.Optional;

@Controller
@RequestMapping("/requests")
public class RequestController {

    @Autowired
    private RequestService requestService;

    @Autowired
    private UserService userService;

    @Autowired
    private ApprovalService approvalService;

    @Autowired
    private TaskService taskService;

    @Autowired
    private WorkflowDefinitionRepository workflowDefinitionRepository;

    @Autowired
    private WorkflowInstanceRepository workflowInstanceRepository;

    @Autowired
    private WorkflowStageInstanceRepository workflowStageInstanceRepository;

    @GetMapping
    public String listRequests(@RequestParam(value = "status", required = false) String statusFilter,
                               Authentication authentication, Model model) {
        User user = userService.findByEmail(authentication.getName()).orElseThrow();
        boolean isPrivileged = user.getRoles().stream().anyMatch(r -> 
                r.getName() == RoleName.SUPER_ADMIN || 
                r.getName() == RoleName.MANAGER || 
                r.getName() == RoleName.DEPARTMENT_HEAD || 
                r.getName() == RoleName.PROCESSOR);

        List<Request> requests;
        if (isPrivileged) {
            requests = requestService.getAllRequests();
        } else {
            requests = requestService.getRequestsByUser(user.getId());
        }

        if (statusFilter != null && !statusFilter.isBlank()) {
            try {
                RequestStatus rs = RequestStatus.valueOf(statusFilter.toUpperCase());
                requests = requests.stream().filter(r -> r.getStatus() == rs).toList();
                model.addAttribute("selectedStatus", statusFilter.toUpperCase());
            } catch (Exception ignored) {}
        }

        model.addAttribute("requests", requests);
        return "requests/request-list";
    }

    @GetMapping("/new")
    public String newRequestForm(Model model) {
        List<WorkflowDefinition> definitions = workflowDefinitionRepository.findByStatus(WorkflowStatus.ACTIVE);
        model.addAttribute("definitions", definitions);
        model.addAttribute("priorities", Priority.values());
        return "requests/request-form";
    }

    @PostMapping("/new")
    public String createRequest(@RequestParam("title") String title,
                                @RequestParam(value = "description", required = false) String description,
                                @RequestParam("requestType") String requestType,
                                @RequestParam(value = "priority", defaultValue = "MEDIUM") String priorityStr,
                                @RequestParam(value = "fieldValuesJson", required = false) String fieldValuesJson,
                                @RequestParam(value = "estimatedCost", required = false) String estimatedCost,
                                @RequestParam(value = "targetDate", required = false) String targetDate,
                                @RequestParam(value = "itemDetails", required = false) String itemDetails,
                                @RequestParam(value = "businessPurpose", required = false) String businessPurpose,
                                @RequestParam(value = "submitNow", defaultValue = "false") boolean submitNow,
                                Authentication authentication,
                                RedirectAttributes redirectAttributes) {
        try {
            User user = userService.findByEmail(authentication.getName()).orElseThrow();
            Priority priority = Priority.valueOf(priorityStr.toUpperCase());

            // Build clean human-readable specification payload instead of raw user JSON
            StringBuilder spec = new StringBuilder();
            if (itemDetails != null && !itemDetails.isBlank()) {
                spec.append("Item/Service: ").append(itemDetails.trim()).append("\n");
            }
            if (estimatedCost != null && !estimatedCost.isBlank()) {
                spec.append("Estimated Cost: ₹").append(estimatedCost.trim()).append("\n");
            }
            if (targetDate != null && !targetDate.isBlank()) {
                spec.append("Target/Required Date: ").append(targetDate.trim()).append("\n");
            }
            if (businessPurpose != null && !businessPurpose.isBlank()) {
                spec.append("Purpose: ").append(businessPurpose.trim()).append("\n");
            }
            if (fieldValuesJson != null && !fieldValuesJson.isBlank()) {
                spec.append("Additional Notes: ").append(fieldValuesJson.trim());
            }

            String finalSpec = spec.toString().trim();
            Request request = requestService.createRequest(title, description, requestType, priority, finalSpec, user);

            if (submitNow) {
                requestService.submitRequest(request.getId(), user);
                redirectAttributes.addFlashAttribute("successMessage", 
                        "Request " + request.getRequestNumber() + " submitted successfully and forwarded to the approval queue!");
            } else {
                redirectAttributes.addFlashAttribute("successMessage", 
                        "Draft request " + request.getRequestNumber() + " saved successfully.");
            }
            return "redirect:/requests/" + request.getId();
        } catch (Exception ex) {
            redirectAttributes.addFlashAttribute("errorMessage", "Error: " + ex.getMessage());
            return "redirect:/requests/new";
        }
    }

    @PostMapping("/{id}/submit")
    public String submitDraft(@PathVariable("id") Long id,
                              Authentication authentication,
                              RedirectAttributes redirectAttributes) {
        try {
            User user = userService.findByEmail(authentication.getName()).orElseThrow();
            Request request = requestService.submitRequest(id, user);
            redirectAttributes.addFlashAttribute("successMessage", 
                    "Request " + request.getRequestNumber() + " has been submitted for approval.");
        } catch (Exception ex) {
            redirectAttributes.addFlashAttribute("errorMessage", "Failed to submit request: " + ex.getMessage());
        }
        return "redirect:/requests/" + id;
    }

    @GetMapping("/{id}")
    public String viewRequestDetails(@PathVariable("id") Long id,
                                     Authentication authentication,
                                     Model model) {
        User user = userService.findByEmail(authentication.getName()).orElseThrow();
        Request request = requestService.getRequestById(id);

        // Security check: User can view if creator, manager, IT processor/head, or admin
        boolean isCreator = request.getCreatedBy().getId().equals(user.getId());
        boolean isSuperAdmin = user.getRoles().stream().anyMatch(r -> r.getName() == RoleName.SUPER_ADMIN);
        boolean isManager = user.getRoles().stream().anyMatch(r -> r.getName() == RoleName.MANAGER);
        boolean isAuthorizedStaff = user.getRoles().stream().anyMatch(r -> 
                r.getName() == RoleName.DEPARTMENT_HEAD || r.getName() == RoleName.PROCESSOR);

        if (!isCreator && !isSuperAdmin && !isManager && !isAuthorizedStaff) {
            return "redirect:/access-denied";
        }

        // Timeline history
        List<ApprovalAction> history = approvalService.getApprovalHistory(id);

        // Comments
        List<Comment> comments = requestService.getComments(id);

        // Current Stage & Workflow Instance
        Optional<WorkflowInstance> wfOpt = workflowInstanceRepository.findByRequestId(id);
        WorkflowStageInstance currentStage = null;
        boolean canApproveCurrentStage = false;

        if (wfOpt.isPresent()) {
            List<WorkflowStageInstance> stages = workflowStageInstanceRepository.findByWorkflowInstanceIdOrderByStageOrderAsc(wfOpt.get().getId());
            model.addAttribute("allStages", stages);

            currentStage = stages.stream()
                    .filter(s -> s.getStatus() == RequestStatus.PENDING_APPROVAL || s.getStatus() == RequestStatus.CHANGES_REQUESTED)
                    .findFirst().orElse(null);

            if (currentStage != null && currentStage.getStatus() == RequestStatus.PENDING_APPROVAL) {
                canApproveCurrentStage = approvalService.isAuthorized(currentStage, user);
            }
        }

        model.addAttribute("request", request);
        model.addAttribute("history", history);
        model.addAttribute("comments", comments);
        model.addAttribute("currentStage", currentStage);
        model.addAttribute("canApproveCurrentStage", canApproveCurrentStage);
        model.addAttribute("isCreator", isCreator);

        return "requests/request-detail";
    }

    @GetMapping("/{id}/edit")
    public String editRequestForm(@PathVariable("id") Long id,
                                  Authentication authentication,
                                  Model model) {
        User user = userService.findByEmail(authentication.getName()).orElseThrow();
        Request request = requestService.getRequestById(id);

        boolean isCreator = request.getCreatedBy().getId().equals(user.getId());
        boolean isSuperAdmin = user.getRoles().stream().anyMatch(r -> r.getName() == RoleName.SUPER_ADMIN);

        if (!isCreator && !isSuperAdmin) {
            return "redirect:/access-denied";
        }

        if (request.getStatus() != RequestStatus.DRAFT && request.getStatus() != RequestStatus.CHANGES_REQUESTED) {
            return "redirect:/requests/" + id;
        }

        model.addAttribute("request", request);
        model.addAttribute("priorities", Priority.values());
        return "requests/request-edit";
    }

    @PostMapping("/{id}/edit")
    public String saveRequestEdit(@PathVariable("id") Long id,
                                  @RequestParam("title") String title,
                                  @RequestParam(value = "description", required = false) String description,
                                  @RequestParam("priority") String priorityStr,
                                  @RequestParam(value = "fieldValuesJson", required = false) String fieldValuesJson,
                                  Authentication authentication,
                                  RedirectAttributes redirectAttributes) {
        try {
            User user = userService.findByEmail(authentication.getName()).orElseThrow();
            Priority priority = Priority.valueOf(priorityStr.toUpperCase());
            requestService.updateDraft(id, title, description, priority, fieldValuesJson, user);
            redirectAttributes.addFlashAttribute("successMessage", "Request updated successfully.");
        } catch (Exception ex) {
            redirectAttributes.addFlashAttribute("errorMessage", "Failed to update: " + ex.getMessage());
        }
        return "redirect:/requests/" + id;
    }

    @PostMapping("/{id}/resubmit")
    public String resubmitRequest(@PathVariable("id") Long id,
                                  @RequestParam(value = "remarks", required = false) String remarks,
                                  Authentication authentication,
                                  RedirectAttributes redirectAttributes) {
        try {
            User user = userService.findByEmail(authentication.getName()).orElseThrow();
            approvalService.resubmitRequest(id, user, remarks);
            redirectAttributes.addFlashAttribute("successMessage", "Request resubmitted successfully for approval.");
        } catch (Exception ex) {
            redirectAttributes.addFlashAttribute("errorMessage", "Failed to resubmit: " + ex.getMessage());
        }
        return "redirect:/requests/" + id;
    }

    @PostMapping("/{id}/cancel")
    public String cancelRequest(@PathVariable("id") Long id,
                                @RequestParam(value = "reason", required = false) String reason,
                                Authentication authentication,
                                RedirectAttributes redirectAttributes) {
        try {
            User user = userService.findByEmail(authentication.getName()).orElseThrow();
            requestService.cancelRequest(id, user, reason);
            redirectAttributes.addFlashAttribute("successMessage", "Request has been cancelled.");
        } catch (Exception ex) {
            redirectAttributes.addFlashAttribute("errorMessage", "Failed to cancel: " + ex.getMessage());
        }
        return "redirect:/requests/" + id;
    }

    @PostMapping("/{id}/comment")
    public String addComment(@PathVariable("id") Long id,
                             @RequestParam("content") String content,
                             Authentication authentication,
                             RedirectAttributes redirectAttributes) {
        try {
            User user = userService.findByEmail(authentication.getName()).orElseThrow();
            requestService.addComment(id, user, content);
            redirectAttributes.addFlashAttribute("successMessage", "Comment posted.");
        } catch (Exception ex) {
            redirectAttributes.addFlashAttribute("errorMessage", "Failed to add comment: " + ex.getMessage());
        }
        return "redirect:/requests/" + id;
    }
}
