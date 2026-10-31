package com.flowsphere.repository;

import com.flowsphere.entity.WorkflowStageInstance;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;

public interface WorkflowStageInstanceRepository extends JpaRepository<WorkflowStageInstance, Long> {
    List<WorkflowStageInstance> findByWorkflowInstanceId(Long workflowInstanceId);
}
