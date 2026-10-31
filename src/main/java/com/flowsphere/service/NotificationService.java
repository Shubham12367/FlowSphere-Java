package com.flowsphere.service;

import com.flowsphere.entity.Notification;
import com.flowsphere.entity.User;
import com.flowsphere.repository.NotificationRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import java.util.List;

@Service
public class NotificationService {

    @Autowired
    private NotificationRepository notificationRepository;

    public Notification createNotification(User user, String title, String message) {
        Notification n = new Notification();
        n.setUser(user);
        n.setTitle(title);
        n.setMessage(message);
        return notificationRepository.save(n);
    }

    public List<Notification> getUnreadNotifications(User user) {
        return notificationRepository.findByUserIdAndReadFalse(user.getId());
    }

    public void markAsRead(Notification notification) {
        notification.setRead(true);
        notificationRepository.save(notification);
    }
}
