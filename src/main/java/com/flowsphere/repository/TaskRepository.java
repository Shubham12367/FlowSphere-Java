package com.flowsphere.repository;

import com.flowsphere.entity.Task;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;

public interface TaskRepository extends JpaRepository<Task, Long> {
    List<Task> findByStageInstanceId(Long stageInstanceId);
}
