package com.flowsphere.repository;

import com.flowsphere.entity.Role;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.Optional;

public interface RoleRepository extends JpaRepository<Role, Long> {
    Optional<Role> findByName(com.flowsphere.entity.RoleName name);
}
