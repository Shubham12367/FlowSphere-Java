package com.flowsphere.config;

import com.flowsphere.entity.*;
import com.flowsphere.repository.*;
import jakarta.annotation.PostConstruct;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;
import java.util.EnumSet;
import java.util.Optional;

@Component
public class DataInitializer {

    @Autowired
    private RoleRepository roleRepository;

    @Autowired
    private DepartmentRepository departmentRepository;

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private WorkflowDefinitionRepository workflowDefinitionRepository;

    @Autowired
    private WorkflowVersionRepository workflowVersionRepository;

    @Autowired
    private PasswordEncoder passwordEncoder;

    @PostConstruct
    @Transactional
    public void init() {
        // 1. Seed Roles
        for (RoleName rn : EnumSet.allOf(RoleName.class)) {
            roleRepository.findByName(rn).orElseGet(() -> {
                Role role = new Role();
                role.setName(rn);
                return roleRepository.save(role);
            });
        }

        // 2. Seed Departments
        Department itDept = departmentRepository.findByCode("IT").orElseGet(() -> {
            Department d = new Department();
            d.setName("IT & Engineering");
            d.setCode("IT");
            return departmentRepository.save(d);
        });

        departmentRepository.findByCode("FIN").orElseGet(() -> {
            Department d = new Department();
            d.setName("Finance & Operations");
            d.setCode("FIN");
            return departmentRepository.save(d);
        });

        departmentRepository.findByCode("HR").orElseGet(() -> {
            Department d = new Department();
            d.setName("Human Resources");
            d.setCode("HR");
            return departmentRepository.save(d);
        });

        // 3. Seed Users for each of the 5 roles with env var overrides or safe local defaults
        User superAdmin = createOrGetUser("SUPERADMIN_EMAIL", "superadmin@flowsphere.local",
                                          "SUPERADMIN_PASS", "Admin@123",
                                          "Super", "Admin", RoleName.SUPER_ADMIN, itDept);

        User manager = createOrGetUser("MANAGER_EMAIL", "manager@flowsphere.local",
                                       "MANAGER_PASS", "Manager@123",
                                       "Operations", "Manager", RoleName.MANAGER, itDept);

        User deptHead = createOrGetUser("DEPTHEAD_EMAIL", "depthead@flowsphere.local",
                                        "DEPTHEAD_PASS", "DeptHead@123",
                                        "IT", "Head", RoleName.DEPARTMENT_HEAD, itDept);

        User processor = createOrGetUser("PROCESSOR_EMAIL", "processor@flowsphere.local",
                                         "PROCESSOR_PASS", "Processor@123",
                                         "IT", "Processor", RoleName.PROCESSOR, itDept);

        User employee = createOrGetUser("EMPLOYEE_EMAIL", "employee@flowsphere.local",
                                        "EMPLOYEE_PASS", "Employee@123",
                                        "Alex", "Employee", RoleName.EMPLOYEE, itDept);

        // Assign IT department head
        if (itDept.getHeadUser() == null && deptHead != null) {
            itDept.setHeadUser(deptHead);
            departmentRepository.save(itDept);
        }

        // 4. Seed Default Workflow Definitions and Versions across enterprise categories
        seedWorkflowDefinition("Standard IT & Equipment Request", "IT_SERVICE",
                "[{\"order\":1,\"name\":\"Manager Approval\",\"role\":\"MANAGER\"}," +
                 "{\"order\":2,\"name\":\"IT Department Head Approval\",\"role\":\"DEPARTMENT_HEAD\"}," +
                 "{\"order\":3,\"name\":\"IT Processor Fulfillment\",\"role\":\"PROCESSOR\"}]");

        seedWorkflowDefinition("Software License & Cloud Sandbox Access", "IT_SOFTWARE",
                "[{\"order\":1,\"name\":\"Line Manager Verification\",\"role\":\"MANAGER\"}," +
                 "{\"order\":2,\"name\":\"IT Head Security Clearance\",\"role\":\"DEPARTMENT_HEAD\"}," +
                 "{\"order\":3,\"name\":\"Cloud Infrastructure Provisioning\",\"role\":\"PROCESSOR\"}]");

        seedWorkflowDefinition("Expense Reimbursement & Travel Claim", "FINANCE",
                "[{\"order\":1,\"name\":\"Manager Budget Review\",\"role\":\"MANAGER\"}," +
                 "{\"order\":2,\"name\":\"Finance Department Head Approval\",\"role\":\"DEPARTMENT_HEAD\"}," +
                 "{\"order\":3,\"name\":\"Accounts Payable Disbursal\",\"role\":\"PROCESSOR\"}]");

        seedWorkflowDefinition("Leave & Work-From-Home Application", "HUMAN_RESOURCES",
                "[{\"order\":1,\"name\":\"Direct Manager Approval\",\"role\":\"MANAGER\"}," +
                 "{\"order\":2,\"name\":\"HR Department Head Acknowledgement\",\"role\":\"DEPARTMENT_HEAD\"}," +
                 "{\"order\":3,\"name\":\"Attendance & Payroll Record Update\",\"role\":\"PROCESSOR\"}]");

        seedWorkflowDefinition("Procurement & Vendor Purchase Order", "OPERATIONS",
                "[{\"order\":1,\"name\":\"Department Manager Endorsement\",\"role\":\"MANAGER\"}," +
                 "{\"order\":2,\"name\":\"Department Head Budget Allocation\",\"role\":\"DEPARTMENT_HEAD\"}," +
                 "{\"order\":3,\"name\":\"Procurement Operations Execution\",\"role\":\"PROCESSOR\"}]");
    }

    private void seedWorkflowDefinition(String name, String category, String stagesJson) {
        workflowDefinitionRepository.findByName(name).orElseGet(() -> {
            WorkflowDefinition def = new WorkflowDefinition();
            def.setName(name);
            def.setCategory(category);
            def.setStatus(WorkflowStatus.ACTIVE);
            def = workflowDefinitionRepository.save(def);

            WorkflowVersion ver = new WorkflowVersion();
            ver.setWorkflowDefinition(def);
            ver.setVersionNumber(1);
            ver.setStagesJson(stagesJson);
            ver.setTransitionsJson("[{\"from\":1,\"to\":2,\"action\":\"APPROVE\"}," +
                                   "{\"from\":2,\"to\":3,\"action\":\"APPROVE\"}," +
                                   "{\"from\":3,\"to\":\"COMPLETED\",\"action\":\"APPROVE\"}]");
            ver = workflowVersionRepository.save(ver);

            def.setCurrentVersion(ver);
            return workflowDefinitionRepository.save(def);
        });
    }

    private User createOrGetUser(String emailEnv, String defaultEmail,
                                 String passEnv, String defaultPass,
                                 String firstName, String lastName,
                                 RoleName roleName, Department dept) {
        String envEmail = System.getenv(emailEnv);
        String email = (envEmail != null && !envEmail.isBlank()) ? envEmail.trim() : defaultEmail;

        Optional<User> existing = userRepository.findByEmail(email.toLowerCase());
        if (existing.isPresent()) {
            return existing.get();
        }

        String envPass = System.getenv(passEnv);
        String rawPass = (envPass != null && !envPass.isBlank()) ? envPass : defaultPass;

        User user = new User();
        user.setEmail(email.toLowerCase());
        user.setPasswordHash(passwordEncoder.encode(rawPass));
        user.setFirstName(firstName);
        user.setLastName(lastName);
        user.setStatus(AccountStatus.ACTIVE);
        user.setDepartment(dept);

        Role role = roleRepository.findByName(roleName).orElseThrow();
        user.getRoles().add(role);

        return userRepository.save(user);
    }
}
