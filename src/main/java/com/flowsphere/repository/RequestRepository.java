package com.flowsphere.repository;

import com.flowsphere.entity.Request;
import com.flowsphere.entity.RequestStatus;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;
import java.util.Optional;

public interface RequestRepository extends JpaRepository<Request, Long> {
    Optional<Request> findByRequestNumber(String requestNumber);
    List<Request> findByCreatedByIdOrderByCreatedAtDesc(Long userId);
    List<Request> findByDepartmentIdOrderByCreatedAtDesc(Long departmentId);
    List<Request> findByStatusOrderByCreatedAtDesc(RequestStatus status);
    List<Request> findAllByOrderByCreatedAtDesc();
    long countByStatus(RequestStatus status);
    long countByCreatedById(Long userId);
    long countByCreatedByIdAndStatus(Long userId, RequestStatus status);
}
