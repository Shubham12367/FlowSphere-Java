package com.flowsphere.repository;

import com.flowsphere.entity.WorkflowInstance;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.Optional;

public interface WorkflowInstanceRepository extends JpaRepository<WorkflowInstance, Long> {
    Optional<WorkflowInstance> findByRequestId(Long requestId);
}
