package com.flowsphere.config;

import com.flowsphere.entity.*;
import com.flowsphere.repository.*;
import jakarta.annotation.PostConstruct;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Component;
import java.util.EnumSet;

@Component
public class DataInitializer {

    @Autowired
    private RoleRepository roleRepository;

    @Autowired
    private DepartmentRepository departmentRepository;

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private PasswordEncoder passwordEncoder;

    @PostConstruct
    public void init() {
        // Initialize roles
        EnumSet<RoleName> roles = EnumSet.allOf(RoleName.class);
        for (RoleName rn : roles) {
            roleRepository.findByName(rn).orElseGet(() -> {
                Role role = new Role();
                role.setName(rn);
                return roleRepository.save(role);
            });
        }

        // Initialize a demo department if missing
        Department dept = departmentRepository.findAll().stream().findFirst().orElseGet(() -> {
            Department d = new Department();
            d.setName("IT Department");
            d.setCode("IT");
            return departmentRepository.save(d);
        });

        // Initialize demo users based on environment variables (fallback values for local dev)
        createDemoUser("SUPERADMIN_EMAIL", "SUPERADMIN_PASS", RoleName.SUPER_ADMIN, dept);
        createDemoUser("MANAGER_EMAIL", "MANAGER_PASS", RoleName.MANAGER, dept);
        createDemoUser("EMPLOYEE_EMAIL", "EMPLOYEE_PASS", RoleName.EMPLOYEE, dept);
    }

    private void createDemoUser(String emailEnv, String passEnv, RoleName roleName, Department dept) {
        String email = System.getenv(emailEnv);
        String rawPass = System.getenv(passEnv);
        if (email == null || rawPass == null) {
            // Skip creation if env vars not set – developer can set them manually
            return;
        }
        if (userRepository.findByEmail(email).isPresent()) {
            return;
        }
        User user = new User();
        user.setEmail(email);
        user.setPasswordHash(passwordEncoder.encode(rawPass));
        user.setFirstName(roleName.name() + " Demo");
        user.setLastName("User");
        user.setStatus(AccountStatus.ACTIVE);
        user.setDepartment(dept);
        // Assign role
        Role role = roleRepository.findByName(roleName).orElseThrow();
        user.getRoles().add(role);
        userRepository.save(user);
    }
}
