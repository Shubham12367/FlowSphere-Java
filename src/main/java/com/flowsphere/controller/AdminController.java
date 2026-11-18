package com.flowsphere.controller;

import com.flowsphere.entity.*;
import com.flowsphere.repository.WorkflowDefinitionRepository;
import com.flowsphere.service.AuditService;
import com.flowsphere.service.UserService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.Authentication;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import java.util.HashSet;
import java.util.List;
import java.util.Set;

@Controller
@RequestMapping("/admin")
@PreAuthorize("hasRole('SUPER_ADMIN')")
public class AdminController {

    @Autowired
    private UserService userService;

    @Autowired
    private AuditService auditService;

    @Autowired
    private WorkflowDefinitionRepository workflowDefinitionRepository;

    @GetMapping("/users")
    public String listUsers(Model model) {
        model.addAttribute("users", userService.getAllUsers());
        model.addAttribute("departments", userService.getAllDepartments());
        model.addAttribute("roles", userService.getAllRoles());
        model.addAttribute("statuses", AccountStatus.values());
        return "admin/admin-users";
    }

    @PostMapping("/users/{id}/update")
    public String updateUser(@PathVariable("id") Long id,
                             @RequestParam(value = "departmentId", required = false) Long departmentId,
                             @RequestParam("status") String statusStr,
                             @RequestParam(value = "roleNames", required = false) List<String> roleNamesList,
                             Authentication authentication,
                             RedirectAttributes redirectAttributes) {
        try {
            User admin = userService.findByEmail(authentication.getName()).orElseThrow();
            AccountStatus status = AccountStatus.valueOf(statusStr.toUpperCase());
            Set<RoleName> roleNames = new HashSet<>();
            if (roleNamesList != null) {
                for (String r : roleNamesList) {
                    roleNames.add(RoleName.valueOf(r.toUpperCase()));
                }
            }

            userService.updateUserRolesAndStatus(id, roleNames, status, departmentId, admin);
            redirectAttributes.addFlashAttribute("successMessage", "User updated successfully.");
        } catch (Exception ex) {
            redirectAttributes.addFlashAttribute("errorMessage", "Error updating user: " + ex.getMessage());
        }
        return "redirect:/admin/users";
    }

    @GetMapping("/departments")
    public String listDepartments(Model model) {
        model.addAttribute("departments", userService.getAllDepartments());
        model.addAttribute("users", userService.getAllUsers());
        return "admin/admin-departments";
    }

    @PostMapping("/departments")
    public String createDepartment(@RequestParam("name") String name,
                                   @RequestParam("code") String code,
                                   @RequestParam(value = "headUserId", required = false) Long headUserId,
                                   RedirectAttributes redirectAttributes) {
        try {
            userService.createDepartment(name, code, headUserId);
            redirectAttributes.addFlashAttribute("successMessage", "Department created successfully.");
        } catch (Exception ex) {
            redirectAttributes.addFlashAttribute("errorMessage", "Error creating department: " + ex.getMessage());
        }
        return "redirect:/admin/departments";
    }

    @GetMapping("/workflows")
    public String listWorkflows(Model model) {
        model.addAttribute("workflows", workflowDefinitionRepository.findAll());
        return "admin/admin-workflows";
    }

    @PostMapping("/workflows/{id}/toggle-status")
    public String toggleWorkflowStatus(@PathVariable("id") Long id,
                                       RedirectAttributes redirectAttributes) {
        try {
            WorkflowDefinition def = workflowDefinitionRepository.findById(id).orElseThrow();
            def.setStatus(def.getStatus() == WorkflowStatus.ACTIVE ? WorkflowStatus.INACTIVE : WorkflowStatus.ACTIVE);
            workflowDefinitionRepository.save(def);
            redirectAttributes.addFlashAttribute("successMessage", "Workflow status updated to " + def.getStatus());
        } catch (Exception ex) {
            redirectAttributes.addFlashAttribute("errorMessage", "Error toggling status: " + ex.getMessage());
        }
        return "redirect:/admin/workflows";
    }

    @GetMapping("/audit-logs")
    public String viewAuditLogs(Model model) {
        model.addAttribute("auditLogs", auditService.getAllLogs());
        return "admin/admin-audit-logs";
    }
}
