<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>FlowSphere — Register Account</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">
    <style>
        body {
            background: linear-gradient(135deg, #0f172a 0%, #1e293b 100%);
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            font-family: 'Segoe UI', system-ui, -apple-system, sans-serif;
        }
        .reg-card {
            background: #ffffff;
            border-radius: 1rem;
            box-shadow: 0 25px 50px -12px rgba(0, 0, 0, 0.25);
            width: 100%;
            max-width: 500px;
        }
    </style>
</head>
<body class="p-3">

<div class="reg-card p-4 p-md-5 my-4">
    <div class="text-center mb-4">
        <div class="d-inline-flex align-items-center justify-content-center bg-primary text-white rounded-circle p-2 mb-2 shadow">
            <i class="bi bi-person-plus-fill fs-3"></i>
        </div>
        <h4 class="fw-bold text-slate-800 mb-1">Create Account</h4>
        <p class="text-muted small">Register as an employee in the FlowSphere EWMS</p>
    </div>

    <c:if test="${not empty errorMessage}">
        <div class="alert alert-danger py-2 small d-flex align-items-center mb-3" role="alert">
            <i class="bi bi-exclamation-triangle-fill me-2"></i>
            <div>${errorMessage}</div>
        </div>
    </c:if>

    <form action="${pageContext.request.contextPath}/register" method="post">
        <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}" />

        <div class="row g-2 mb-3">
            <div class="col-6">
                <label for="firstName" class="form-label small fw-semibold text-secondary">First Name</label>
                <input type="text" class="form-control" id="firstName" name="firstName" value="${firstName}" required autofocus />
            </div>
            <div class="col-6">
                <label for="lastName" class="form-label small fw-semibold text-secondary">Last Name</label>
                <input type="text" class="form-control" id="lastName" name="lastName" value="${lastName}" required />
            </div>
        </div>

        <div class="mb-3">
            <label for="email" class="form-label small fw-semibold text-secondary">Company Email</label>
            <div class="input-group">
                <span class="input-group-text bg-light text-muted"><i class="bi bi-envelope"></i></span>
                <input type="email" class="form-control" id="email" name="email" value="${email}" placeholder="user@company.com" required />
            </div>
        </div>

        <div class="row g-2 mb-3">
            <div class="col-md-6">
                <label for="departmentId" class="form-label small fw-semibold text-secondary">Department</label>
                <select class="form-select" id="departmentId" name="departmentId">
                    <option value="">-- Select Department --</option>
                    <c:forEach items="${departments}" var="dept">
                        <option value="${dept.id}">${dept.name} (${dept.code})</option>
                    </c:forEach>
                </select>
            </div>
            <div class="col-md-6">
                <label for="role" class="form-label small fw-semibold text-secondary">Organizational Role</label>
                <select class="form-select" id="role" name="role">
                    <option value="EMPLOYEE" selected>Employee (Staff Member)</option>
                    <option value="MANAGER">Department Manager / Team Lead</option>
                    <option value="DEPARTMENT_HEAD">Department Head (Director)</option>
                    <option value="PROCESSOR">IT / Operations Fulfillment Specialist</option>
                </select>
            </div>
        </div>

        <div class="mb-4">
            <label for="password" class="form-label small fw-semibold text-secondary">Password (min 6 characters)</label>
            <div class="input-group">
                <span class="input-group-text bg-light text-muted"><i class="bi bi-lock"></i></span>
                <input type="password" class="form-control" id="password" name="password" minlength="6" required />
            </div>
        </div>

        <button type="submit" class="btn btn-primary w-100 py-2 fw-semibold shadow-sm mb-3">
            Complete Registration <i class="bi bi-check-lg ms-1"></i>
        </button>

        <div class="text-center">
            <span class="text-muted small">Already have an account? </span>
            <a href="${pageContext.request.contextPath}/login" class="small fw-semibold text-primary text-decoration-none">
                Sign in here
            </a>
        </div>
    </form>
</div>

</body>
</html>
