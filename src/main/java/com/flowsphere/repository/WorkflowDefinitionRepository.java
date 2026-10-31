package com.flowsphere.repository;

import com.flowsphere.entity.WorkflowDefinition;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.Optional;

public interface WorkflowDefinitionRepository extends JpaRepository<WorkflowDefinition, Long> {
    Optional<WorkflowDefinition> findByName(String name);
}
