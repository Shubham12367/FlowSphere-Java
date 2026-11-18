<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>FlowSphere — Sign In</title>
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
        .login-card {
            background: #ffffff;
            border-radius: 1rem;
            box-shadow: 0 25px 50px -12px rgba(0, 0, 0, 0.25);
            width: 100%;
            max-width: 440px;
        }
        .demo-card {
            background: #1e293b;
            color: #cbd5e1;
            border-radius: 1rem;
            max-width: 440px;
            width: 100%;
        }
        .demo-pill {
            cursor: pointer;
            transition: all 0.2s ease;
        }
        .demo-pill:hover {
            background-color: #334155 !important;
            transform: translateY(-1px);
        }
    </style>
</head>
<body class="p-3">

<div class="d-flex flex-column align-items-center w-100">
    <!-- Brand Title -->
    <div class="text-center text-white mb-4">
        <div class="d-inline-flex align-items-center justify-content-center bg-primary text-white rounded-circle p-3 mb-2 shadow">
            <i class="bi bi-diagram-3-fill fs-2"></i>
        </div>
        <h2 class="fw-bold tracking-tight mb-0">FlowSphere</h2>
        <p class="text-secondary small mb-0">Enterprise Workflow Management System</p>
    </div>

    <!-- Login Form Card -->
    <div class="login-card p-4 p-md-5 mb-4">
        <h4 class="fw-bold text-slate-800 mb-1">Sign In</h4>
        <p class="text-muted small mb-4">Enter your credentials to access your workflow dashboard</p>

        <c:if test="${not empty errorMessage}">
            <div class="alert alert-danger py-2 small d-flex align-items-center" role="alert">
                <i class="bi bi-exclamation-triangle-fill me-2"></i>
                <div>${errorMessage}</div>
            </div>
        </c:if>

        <c:if test="${not empty successMessage}">
            <div class="alert alert-success py-2 small d-flex align-items-center" role="alert">
                <i class="bi bi-check-circle-fill me-2"></i>
                <div>${successMessage}</div>
            </div>
        </c:if>

        <form action="${pageContext.request.contextPath}/login" method="post">
            <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}" />

            <div class="mb-3">
                <label for="username" class="form-label small fw-semibold text-secondary">Email Address</label>
                <div class="input-group">
                    <span class="input-group-text bg-light border-end-0 text-muted"><i class="bi bi-envelope"></i></span>
                    <input type="email" class="form-control border-start-0" id="username" name="username" 
                           placeholder="name@company.com" required autofocus />
                </div>
            </div>

            <div class="mb-4">
                <label for="password" class="form-label small fw-semibold text-secondary">Password</label>
                <div class="input-group">
                    <span class="input-group-text bg-light border-end-0 text-muted"><i class="bi bi-lock"></i></span>
                    <input type="password" class="form-control border-start-0" id="password" name="password" 
                           placeholder="••••••••" required />
                </div>
            </div>

            <button type="submit" class="btn btn-primary w-100 py-2 fw-semibold shadow-sm mb-3">
                Sign In <i class="bi bi-arrow-right ms-1"></i>
            </button>

            <div class="text-center">
                <span class="text-muted small">Don't have an account? </span>
                <a href="${pageContext.request.contextPath}/register" class="small fw-semibold text-primary text-decoration-none">
                    Register here
                </a>
            </div>
        </form>
    </div>

    <!-- Demo Accounts Quick Reference -->
    <div class="demo-card p-4 shadow">
        <div class="d-flex align-items-center justify-content-between mb-2">
            <span class="fw-bold text-white small"><i class="bi bi-key-fill text-warning me-1"></i> Pre-configured Demo Accounts</span>
            <span class="badge bg-secondary">Click to fill</span>
        </div>
        <div class="row g-2 mt-1">
            <div class="col-12">
                <div class="demo-pill p-2 bg-dark rounded border border-secondary small d-flex justify-content-between align-items-center"
                     onclick="fillCredentials('employee@flowsphere.local', 'Employee@123')">
                    <div>
                        <strong class="text-info">Employee:</strong> employee@flowsphere.local
                    </div>
                    <span class="badge bg-primary">Employee@123</span>
                </div>
            </div>
            <div class="col-12">
                <div class="demo-pill p-2 bg-dark rounded border border-secondary small d-flex justify-content-between align-items-center"
                     onclick="fillCredentials('manager@flowsphere.local', 'Manager@123')">
                    <div>
                        <strong class="text-warning">Manager:</strong> manager@flowsphere.local
                    </div>
                    <span class="badge bg-primary">Manager@123</span>
                </div>
            </div>
            <div class="col-12">
                <div class="demo-pill p-2 bg-dark rounded border border-secondary small d-flex justify-content-between align-items-center"
                     onclick="fillCredentials('depthead@flowsphere.local', 'DeptHead@123')">
                    <div>
                        <strong class="text-primary">Dept Head:</strong> depthead@flowsphere.local
                    </div>
                    <span class="badge bg-primary">DeptHead@123</span>
                </div>
            </div>
            <div class="col-12">
                <div class="demo-pill p-2 bg-dark rounded border border-secondary small d-flex justify-content-between align-items-center"
                     onclick="fillCredentials('processor@flowsphere.local', 'Processor@123')">
                    <div>
                        <strong class="text-success">IT Processor:</strong> processor@flowsphere.local
                    </div>
                    <span class="badge bg-primary">Processor@123</span>
                </div>
            </div>
            <div class="col-12">
                <div class="demo-pill p-2 bg-dark rounded border border-secondary small d-flex justify-content-between align-items-center"
                     onclick="fillCredentials('superadmin@flowsphere.local', 'Admin@123')">
                    <div>
                        <strong class="text-danger">Super Admin:</strong> superadmin@flowsphere.local
                    </div>
                    <span class="badge bg-primary">Admin@123</span>
                </div>
            </div>
        </div>
    </div>
</div>

<script>
    function fillCredentials(email, pass) {
        document.getElementById('username').value = email;
        document.getElementById('password').value = pass;
    }
</script>

</body>
</html>
