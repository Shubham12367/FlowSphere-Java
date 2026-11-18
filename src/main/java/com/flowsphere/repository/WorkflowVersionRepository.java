package com.flowsphere.repository;

import com.flowsphere.entity.WorkflowVersion;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;
import java.util.Optional;

public interface WorkflowVersionRepository extends JpaRepository<WorkflowVersion, Long> {
    List<WorkflowVersion> findByWorkflowDefinitionId(Long workflowDefinitionId);
    Optional<WorkflowVersion> findFirstByWorkflowDefinitionIdOrderByVersionNumberDesc(Long workflowDefinitionId);
}
