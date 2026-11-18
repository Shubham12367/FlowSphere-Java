package com.flowsphere.controller;

import com.flowsphere.entity.Task;
import com.flowsphere.entity.User;
import com.flowsphere.service.TaskService;
import com.flowsphere.service.UserService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.Authentication;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import java.util.List;

@Controller
@RequestMapping("/tasks")
public class TaskController {

    @Autowired
    private TaskService taskService;

    @Autowired
    private UserService userService;

    @GetMapping
    public String listTasks(Authentication authentication, Model model) {
        User user = userService.findByEmail(authentication.getName()).orElseThrow();
        List<Task> tasks = taskService.getTasksForUser(user.getId());
        model.addAttribute("tasks", tasks);
        return "tasks/task-list";
    }

    @PostMapping("/{id}/complete")
    public String completeTask(@PathVariable("id") Long id,
                               Authentication authentication,
                               RedirectAttributes redirectAttributes) {
        try {
            taskService.completeTask(id);
            redirectAttributes.addFlashAttribute("successMessage", "Task completed successfully.");
        } catch (Exception ex) {
            redirectAttributes.addFlashAttribute("errorMessage", "Error completing task: " + ex.getMessage());
        }
        return "redirect:/tasks";
    }
}
