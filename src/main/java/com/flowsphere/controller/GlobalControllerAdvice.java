package com.flowsphere.controller;

import com.flowsphere.entity.User;
import com.flowsphere.service.NotificationService;
import com.flowsphere.service.TaskService;
import com.flowsphere.service.UserService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.ControllerAdvice;
import org.springframework.web.bind.annotation.ModelAttribute;
import java.util.Optional;

@ControllerAdvice
public class GlobalControllerAdvice {

    @Autowired
    private UserService userService;

    @Autowired
    private NotificationService notificationService;

    @Autowired
    private TaskService taskService;

    @ModelAttribute("currentUser")
    public User getCurrentUser(Authentication authentication) {
        if (authentication != null && authentication.isAuthenticated() && 
            !"anonymousUser".equals(authentication.getPrincipal())) {
            Optional<User> user = userService.findByEmail(authentication.getName());
            return user.orElse(null);
        }
        return null;
    }

    @ModelAttribute("unreadNotificationCount")
    public long getUnreadNotificationCount(Authentication authentication) {
        if (authentication != null && authentication.isAuthenticated() && 
            !"anonymousUser".equals(authentication.getPrincipal())) {
            return userService.findByEmail(authentication.getName())
                    .map(u -> notificationService.getUnreadCount(u.getId()))
                    .orElse(0L);
        }
        return 0L;
    }

    @ModelAttribute("openTaskCount")
    public long getOpenTaskCount(Authentication authentication) {
        if (authentication != null && authentication.isAuthenticated() && 
            !"anonymousUser".equals(authentication.getPrincipal())) {
            return userService.findByEmail(authentication.getName())
                    .map(u -> taskService.getOpenTaskCountForUser(u.getId()))
                    .orElse(0L);
        }
        return 0L;
    }
}
