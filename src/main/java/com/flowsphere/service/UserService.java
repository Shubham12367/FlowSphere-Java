package com.flowsphere.service;

import com.flowsphere.entity.*;
import com.flowsphere.repository.*;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import java.util.*;

@Service
public class UserService {

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private RoleRepository roleRepository;

    @Autowired
    private DepartmentRepository departmentRepository;

    @Autowired
    private PasswordEncoder passwordEncoder;

    @Autowired
    private AuditService auditService;

    @Transactional
    public User registerUser(String email, String rawPassword, String firstName, String lastName, Long departmentId, RoleName requestedRole) {
        if (email == null || email.isBlank()) {
            throw new IllegalArgumentException("Email is required");
        }
        if (rawPassword == null || rawPassword.length() < 6) {
            throw new IllegalArgumentException("Password must be at least 6 characters");
        }
        if (userRepository.existsByEmail(email.trim().toLowerCase())) {
            throw new IllegalArgumentException("Email already in use: " + email);
        }

        User user = new User();
        user.setEmail(email.trim().toLowerCase());
        user.setPasswordHash(passwordEncoder.encode(rawPassword));
        user.setFirstName(firstName != null ? firstName.trim() : "");
        user.setLastName(lastName != null ? lastName.trim() : "");
        user.setStatus(AccountStatus.ACTIVE);

        if (departmentId != null) {
            departmentRepository.findById(departmentId).ifPresent(user::setDepartment);
        }

        // Determine assigned role (default to EMPLOYEE if not specified or invalid)
        RoleName roleToAssign = (requestedRole != null && requestedRole != RoleName.SUPER_ADMIN) ? requestedRole : RoleName.EMPLOYEE;
        Role userRole = roleRepository.findByName(roleToAssign)
                .orElseGet(() -> {
                    Role r = new Role();
                    r.setName(roleToAssign);
                    return roleRepository.save(r);
                });
        user.getRoles().add(userRole);

        // Also add EMPLOYEE role base capability if role is MANAGER or DEPARTMENT_HEAD
        if (roleToAssign != RoleName.EMPLOYEE) {
            roleRepository.findByName(RoleName.EMPLOYEE).ifPresent(user.getRoles()::add);
        }

        user = userRepository.save(user);

        // If registered as DEPARTMENT_HEAD and department exists, associate as head if not set
        if (roleToAssign == RoleName.DEPARTMENT_HEAD && user.getDepartment() != null) {
            Department dept = user.getDepartment();
            if (dept.getHeadUser() == null) {
                dept.setHeadUser(user);
                departmentRepository.save(dept);
            }
        }

        auditService.log(user, "USER_REGISTERED", "New user registered with email: " + user.getEmail() + " as " + roleToAssign);
        return user;
    }

    public User registerUser(String email, String rawPassword, String firstName, String lastName, Long departmentId) {
        return registerUser(email, rawPassword, firstName, lastName, departmentId, RoleName.EMPLOYEE);
    }

    public Optional<User> findByEmail(String email) {
        return userRepository.findByEmail(email != null ? email.trim().toLowerCase() : "");
    }

    public User getById(Long id) {
        return userRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("User not found with id: " + id));
    }

    public List<User> getAllUsers() {
        return userRepository.findAll();
    }

    public List<Department> getAllDepartments() {
        return departmentRepository.findAll();
    }

    public Optional<Department> getDepartmentById(Long id) {
        return departmentRepository.findById(id);
    }

    @Transactional
    public Department createDepartment(String name, String code, Long headUserId) {
        Department dept = new Department();
        dept.setName(name);
        dept.setCode(code.toUpperCase());
        if (headUserId != null) {
            userRepository.findById(headUserId).ifPresent(dept::setHeadUser);
        }
        return departmentRepository.save(dept);
    }

    @Transactional
    public User updateUserRolesAndStatus(Long userId, Set<RoleName> roleNames, AccountStatus status, Long departmentId, User adminUser) {
        User user = getById(userId);

        if (status != null) {
            user.setStatus(status);
        }

        if (departmentId != null) {
            departmentRepository.findById(departmentId).ifPresent(user::setDepartment);
        }

        if (roleNames != null && !roleNames.isEmpty()) {
            Set<Role> newRoles = new HashSet<>();
            for (RoleName rn : roleNames) {
                roleRepository.findByName(rn).ifPresent(newRoles::add);
            }
            if (!newRoles.isEmpty()) {
                user.setRoles(newRoles);
            }
        }

        user = userRepository.save(user);
        auditService.log(adminUser, "USER_UPDATED", "Updated profile for user: " + user.getEmail());
        return user;
    }

    public List<Role> getAllRoles() {
        return roleRepository.findAll();
    }
}
