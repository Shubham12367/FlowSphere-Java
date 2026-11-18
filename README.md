# FlowSphere — Enterprise Workflow Management System (EWMS)
### Java 17 + Spring Boot 4 + Spring Security + JPA / Hibernate + JSP / JSTL + MySQL

FlowSphere is a production-grade Enterprise Workflow Management System (EWMS) built to orchestrate multi-stage organizational approval pipelines (Employee → Manager → Department Head → IT Processor Fulfillment) with role-based access control, real-time audit logging, notifications, and task management.

---

## 1. Technology Stack

- **Platform**: Java 17 (Eclipse Temurin / OpenJDK)
- **Framework**: Spring Boot 4.0.0
- **Security**: Spring Security 7.0 (BCrypt strength 12, CSRF protected, Role-Based Access Control)
- **Persistence**: Spring Data JPA / Hibernate
- **Database**: MySQL 8.x (Production/Local) / H2 In-Memory (Automated Testing)
- **View Layer**: JSP (Jakarta EE 10 / Jakarta Standard Tag Library 3.0) + Bootstrap 5.3 + Bootstrap Icons
- **Build Tool**: Apache Maven 3.9+
- **Packaging**: WAR (`flowsphere.war`), runnable via embedded Tomcat or deployable to Apache Tomcat 11.0.x
- **Supported IDEs**: Apache NetBeans 31, IntelliJ IDEA, Eclipse

---

## 2. Default Seeded Accounts & Roles

Upon first startup, `DataInitializer` automatically provisions the 5 enterprise roles, 3 departments (IT, Finance, HR), a standard 3-stage workflow definition, and 5 demo accounts:

| Role | Email | Default Password | Scope / Permissions |
| :--- | :--- | :--- | :--- |
| **Super Admin** | `superadmin@flowsphere.local` | `Admin@123` | System admin, user management, department management, workflow toggle, audit logs, universal approval rights |
| **Operations Manager** | `manager@flowsphere.local` | `Manager@123` | Stage 1 approvals for department requests |
| **IT Department Head** | `depthead@flowsphere.local` | `DeptHead@123` | Stage 2 approvals for IT & equipment requests |
| **IT Processor** | `processor@flowsphere.local` | `Processor@123` | Stage 3 fulfillment, hardware/software provisioning, view all requests |
| **Employee** | `employee@flowsphere.local` | `Employee@123` | Create draft requests, submit into workflow, cancel, comment, resubmit |

> *Note: Seed credentials can be customized via environment variables (`SUPERADMIN_EMAIL`, `SUPERADMIN_PASS`, etc.)*.

---

## 3. Database Setup (MySQL)

1. Ensure MySQL Server 8.0+ is running.
2. Create the database:
   ```sql
   CREATE DATABASE IF NOT EXISTS flowsphere_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
   ```
3. Tables and initial seed data are automatically generated on first run (`spring.jpa.hibernate.ddl-auto=update`).

### Environment Variables (Optional)
If your MySQL password or port differs from standard defaults, configure these variables before launching:
```bash
# Windows PowerShell
$env:DB_URL = "jdbc:mysql://localhost:3306/flowsphere_db?createDatabaseIfNotExist=true&useSSL=false&serverTimezone=UTC&allowPublicKeyRetrieval=true"
$env:DB_USERNAME = "root"
$env:DB_PASSWORD = "YOUR_PASSWORD_HERE"

# Linux / macOS
export DB_URL="jdbc:mysql://localhost:3306/flowsphere_db?createDatabaseIfNotExist=true&useSSL=false&serverTimezone=UTC&allowPublicKeyRetrieval=true"
export DB_USERNAME="root"
export DB_PASSWORD="YOUR_PASSWORD_HERE"
```

---

## 4. How to Run the Application

### Option A: Standalone Maven / Spring Boot (Recommended for development)
From inside the `FlowSphere-Java` directory:

```powershell
# Windows PowerShell
& "C:\Program Files\Apache NetBeans\java\maven\bin\mvn.cmd" spring-boot:run
```
Or if `mvn` is on your PATH:
```bash
mvn spring-boot:run
```

Access the application in your browser:
**URL:** [http://localhost:8080/](http://localhost:8080/)
(Automatically redirects to `/dashboard` or `/login`).

---

### Option B: Run the Packaged WAR directly
1. Build the WAR:
   ```powershell
   & "C:\Program Files\Apache NetBeans\java\maven\bin\mvn.cmd" clean package -DskipTests
   ```
2. Run the generated WAR executable:
   ```powershell
   java -jar target/flowsphere.war
   ```
3. Open `http://localhost:8080` in your web browser.

---

### Option C: Deploy to External Apache Tomcat 11
1. Build the WAR file: `target/flowsphere.war`
2. Copy `flowsphere.war` to your Tomcat 11 installation's `webapps/` folder:
   ```powershell
   Copy-Item target/flowsphere.war "C:\path\to\apache-tomcat-11.x\webapps\"
   ```
3. Start Tomcat:
   ```powershell
   & "C:\path\to\apache-tomcat-11.x\bin\startup.bat"
   ```
4. Access the application at: `http://localhost:8080/flowsphere/`

---

### Option D: Run inside Apache NetBeans IDE
1. Open **Apache NetBeans 31**.
2. Select **File → Open Project...** and navigate to `FlowSphere-Java`.
3. NetBeans will load the project via `pom.xml`.
4. Right-click on `FlowSphere-Java` project in the Projects tree → click **Run** (or press `F6`).

---

## 5. Running Automated Tests

FlowSphere includes a comprehensive integration test suite using an in-memory **H2 database** (no MySQL required for running tests):
- `FlowsphereApplicationTests`: Application context loading verification.
- `AuthenticationTest`: User registration, BCrypt password verification, duplicate prevention, and Spring Security authority mapping.
- `AuthorizationTest`: Role-based security checks and permission barriers.
- `WorkflowIntegrationTest`: Complete 3-stage end-to-end lifecycle test (Employee creates → submits → Manager approves → Dept Head approves → Processor fulfills → Request completes).

To execute tests:
```powershell
& "C:\Program Files\Apache NetBeans\java\maven\bin\mvn.cmd" test
```

---

## 6. Enterprise Workflow Architecture

```
[Employee] ──(Creates & Submits Request)──> [Workflow Engine: Stage 1]
                                                    │
                                                    ▼
                                            [Manager Approval]
                                                    │ (Approve)
                                                    ▼
                                            [Workflow Engine: Stage 2]
                                                    │
                                                    ▼
                                            [Dept Head Approval]
                                                    │ (Approve)
                                                    ▼
                                            [Workflow Engine: Stage 3]
                                                    │
                                                    ▼
                                            [IT Processor Fulfillment]
                                                    │ (Approve/Fulfill)
                                                    ▼
                                            [Request Status: COMPLETED]
```

At any stage:
- **Reject**: Marks request and workflow as `REJECTED`, stores audit comment, notifies requester.
- **Request Changes**: Moves request to `CHANGES_REQUESTED`. Requester can edit and resubmit back into the workflow.
- **Audit Logs**: Every transition, submission, approval, and comment is logged immutably with timestamp and actor details.
