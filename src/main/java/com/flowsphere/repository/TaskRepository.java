package com.flowsphere.repository;

import com.flowsphere.entity.Task;
import com.flowsphere.entity.TaskStatus;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;

public interface TaskRepository extends JpaRepository<Task, Long> {
    List<Task> findByStageInstanceId(Long stageInstanceId);
    List<Task> findByAssignedUserIdOrderByStatusAsc(Long userId);
    List<Task> findByAssignedUserId(Long userId);
    long countByAssignedUserIdAndStatus(Long userId, TaskStatus status);
}
