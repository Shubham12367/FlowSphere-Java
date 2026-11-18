package com.flowsphere.repository;

import com.flowsphere.entity.RoleName;
import com.flowsphere.entity.User;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;
import java.util.Optional;

public interface UserRepository extends JpaRepository<User, Long> {
    Optional<User> findByEmail(String email);
    boolean existsByEmail(String email);
    List<User> findByDepartmentId(Long departmentId);
    List<User> findByRolesName(RoleName roleName);
    List<User> findByRolesNameAndDepartmentId(RoleName roleName, Long departmentId);
}
