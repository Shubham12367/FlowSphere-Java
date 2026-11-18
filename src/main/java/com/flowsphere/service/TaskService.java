package com.flowsphere.service;

import com.flowsphere.entity.Task;
import com.flowsphere.entity.TaskStatus;
import com.flowsphere.entity.User;
import com.flowsphere.entity.WorkflowStageInstance;
import com.flowsphere.repository.TaskRepository;
import com.flowsphere.repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import java.util.List;

@Service
public class TaskService {

    @Autowired
    private TaskRepository taskRepository;

    @Autowired
    private UserRepository userRepository;

    @Transactional
    public Task createTask(WorkflowStageInstance stageInstance, String title, String description, User assignedUser) {
        Task task = new Task();
        task.setStageInstance(stageInstance);
        task.setTitle(title);
        task.setDescription(description);
        task.setAssignedUser(assignedUser);
        task.setStatus(TaskStatus.OPEN);
        return taskRepository.save(task);
    }

    public List<Task> getTasksByStageInstanceId(Long stageInstanceId) {
        return taskRepository.findByStageInstanceId(stageInstanceId);
    }

    public List<Task> getTasksForUser(Long userId) {
        return taskRepository.findByAssignedUserIdOrderByStatusAsc(userId);
    }

    public long getOpenTaskCountForUser(Long userId) {
        return taskRepository.countByAssignedUserIdAndStatus(userId, TaskStatus.OPEN);
    }

    @Transactional
    public void completeTask(Long taskId) {
        taskRepository.findById(taskId).ifPresent(task -> {
            task.setStatus(TaskStatus.COMPLETED);
            taskRepository.save(task);
        });
    }

    @Transactional
    public void completeTasksForStage(Long stageInstanceId) {
        List<Task> tasks = taskRepository.findByStageInstanceId(stageInstanceId);
        for (Task t : tasks) {
            if (t.getStatus() == TaskStatus.OPEN || t.getStatus() == TaskStatus.IN_PROGRESS) {
                t.setStatus(TaskStatus.COMPLETED);
            }
        }
        taskRepository.saveAll(tasks);
    }

    @Transactional
    public void assignTask(Long taskId, Long userId) {
        taskRepository.findById(taskId).ifPresent(task -> {
            userRepository.findById(userId).ifPresent(user -> {
                task.setAssignedUser(user);
                taskRepository.save(task);
            });
        });
    }
}
