package com.flowsphere.service;

import com.flowsphere.entity.Task;
import com.flowsphere.repository.TaskRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import java.util.List;

@Service
public class TaskService {

    @Autowired
    private TaskRepository taskRepository;

    public Task createTask(Task task) {
        return taskRepository.save(task);
    }

    public List<Task> getTasksByStageInstanceId(Long stageInstanceId) {
        return taskRepository.findByStageInstanceId(stageInstanceId);
    }

    @Autowired
    private com.flowsphere.repository.UserRepository userRepository;

    public void assignTask(Long taskId, Long userId) {
        var taskOpt = taskRepository.findById(taskId);
        var userOpt = userRepository.findById(userId);
        if (taskOpt.isPresent() && userOpt.isPresent()) {
            var task = taskOpt.get();
            task.setAssignedUser(userOpt.get());
            taskRepository.save(task);
        }
    }
}
