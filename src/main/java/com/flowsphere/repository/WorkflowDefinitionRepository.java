package com.flowsphere.repository;

import com.flowsphere.entity.WorkflowDefinition;
import com.flowsphere.entity.WorkflowStatus;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;
import java.util.Optional;

public interface WorkflowDefinitionRepository extends JpaRepository<WorkflowDefinition, Long> {
    Optional<WorkflowDefinition> findByName(String name);
    List<WorkflowDefinition> findByStatus(WorkflowStatus status);
}
