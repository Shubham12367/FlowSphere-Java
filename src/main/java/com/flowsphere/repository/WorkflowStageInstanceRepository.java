package com.flowsphere.repository;

import com.flowsphere.entity.RequestStatus;
import com.flowsphere.entity.WorkflowStageInstance;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;
import java.util.Optional;

public interface WorkflowStageInstanceRepository extends JpaRepository<WorkflowStageInstance, Long> {
    List<WorkflowStageInstance> findByWorkflowInstanceId(Long workflowInstanceId);
    List<WorkflowStageInstance> findByWorkflowInstanceIdOrderByStageOrderAsc(Long workflowInstanceId);
    List<WorkflowStageInstance> findByAssignedUserIdAndStatus(Long userId, RequestStatus status);
    Optional<WorkflowStageInstance> findFirstByWorkflowInstanceIdAndStatusOrderByStageOrderAsc(Long workflowInstanceId, RequestStatus status);
    List<WorkflowStageInstance> findByStatus(RequestStatus status);
    long countByAssignedUserIdAndStatus(Long userId, RequestStatus status);
}
