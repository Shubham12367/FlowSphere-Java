package com.flowsphere.controller;

import com.flowsphere.entity.Department;
import com.flowsphere.service.UserService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;

import java.util.List;

@Controller
public class AuthController {

    @Autowired
    private UserService userService;

    @GetMapping("/login")
    public String loginPage(@RequestParam(value = "error", required = false) String error,
                            @RequestParam(value = "logout", required = false) String logout,
                            @RequestParam(value = "registered", required = false) String registered,
                            Model model) {
        if (error != null) {
            model.addAttribute("errorMessage", "Invalid email or password. Please try again.");
        }
        if (logout != null) {
            model.addAttribute("successMessage", "You have been logged out successfully.");
        }
        if (registered != null) {
            model.addAttribute("successMessage", "Registration successful! You may now sign in.");
        }
        return "login";
    }

    @GetMapping("/register")
    public String registerPage(Model model) {
        List<Department> departments = userService.getAllDepartments();
        model.addAttribute("departments", departments);
        return "register";
    }

    @PostMapping("/register")
    public String processRegistration(@RequestParam("email") String email,
                                      @RequestParam("password") String password,
                                      @RequestParam("firstName") String firstName,
                                      @RequestParam("lastName") String lastName,
                                      @RequestParam(value = "departmentId", required = false) Long departmentId,
                                      @RequestParam(value = "role", required = false, defaultValue = "EMPLOYEE") String roleStr,
                                      Model model) {
        try {
            com.flowsphere.entity.RoleName roleName = com.flowsphere.entity.RoleName.EMPLOYEE;
            try {
                if (roleStr != null && !roleStr.isBlank()) {
                    roleName = com.flowsphere.entity.RoleName.valueOf(roleStr.trim().toUpperCase());
                }
            } catch (Exception ignored) {}

            userService.registerUser(email, password, firstName, lastName, departmentId, roleName);
            return "redirect:/login?registered=true";
        } catch (Exception ex) {
            model.addAttribute("errorMessage", ex.getMessage());
            model.addAttribute("departments", userService.getAllDepartments());
            model.addAttribute("email", email);
            model.addAttribute("firstName", firstName);
            model.addAttribute("lastName", lastName);
            return "register";
        }
    }

    @GetMapping("/access-denied")
    public String accessDenied() {
        return "access-denied";
    }
}
