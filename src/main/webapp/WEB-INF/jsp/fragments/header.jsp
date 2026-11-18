<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>${pageTitle != null ? pageTitle : 'FlowSphere — Enterprise Workflow Management'}</title>
    <!-- Bootstrap 5 CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <!-- Bootstrap Icons -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">
    <style>
        :root {
            --fs-primary: #1e40af;
            --fs-secondary: #0f172a;
            --fs-accent: #3b82f6;
            --fs-bg: #f8fafc;
            --fs-card-bg: #ffffff;
            --fs-border: #e2e8f0;
        }
        body {
            background-color: var(--fs-bg);
            font-family: 'Segoe UI', system-ui, -apple-system, sans-serif;
            color: #1e293b;
        }
        .navbar-custom {
            background: linear-gradient(135deg, #0f172a 0%, #1e293b 100%);
            box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1);
        }
        .sidebar {
            background-color: #ffffff;
            border-right: 1px solid var(--fs-border);
            min-height: calc(100vh - 60px);
        }
        .sidebar-link {
            display: flex;
            align-items: center;
            padding: 0.75rem 1.25rem;
            color: #475569;
            text-decoration: none;
            font-weight: 500;
            border-radius: 0.5rem;
            margin: 0.2rem 0.5rem;
            transition: all 0.2s ease;
        }
        .sidebar-link:hover, .sidebar-link.active {
            background-color: #eff6ff;
            color: var(--fs-primary);
        }
        .sidebar-link i {
            margin-right: 0.75rem;
            font-size: 1.1rem;
        }
        .card-custom {
            border: 1px solid var(--fs-border);
            border-radius: 0.75rem;
            box-shadow: 0 1px 3px 0 rgba(0, 0, 0, 0.05);
            background-color: var(--fs-card-bg);
        }
        .badge-status {
            font-size: 0.8rem;
            font-weight: 600;
            padding: 0.35rem 0.65rem;
            border-radius: 2rem;
        }
        .status-DRAFT { background-color: #f1f5f9; color: #475569; }
        .status-SUBMITTED, .status-PENDING_APPROVAL { background-color: #fef3c7; color: #92400e; }
        .status-IN_PROGRESS { background-color: #e0f2fe; color: #0369a1; }
        .status-APPROVED, .status-COMPLETED { background-color: #dcfce7; color: #166534; }
        .status-REJECTED, .status-CANCELLED { background-color: #fee2e2; color: #991b1b; }
        .status-CHANGES_REQUESTED { background-color: #ffedd5; color: #9a3412; }
    </style>
</head>
<body>

<nav class="navbar navbar-expand-lg navbar-dark navbar-custom sticky-top py-2">
    <div class="container-fluid px-3">
        <a class="navbar-brand fw-bold d-flex align-items-center" href="${pageContext.request.contextPath}/dashboard">
            <i class="bi bi-diagram-3-fill text-primary me-2 fs-4"></i>
            <span>FlowSphere</span>
            <span class="badge bg-primary-subtle text-primary ms-2 fs-6">EWMS</span>
        </a>

        <div class="d-flex align-items-center ms-auto">
            <c:if test="${currentUser != null}">
                <!-- Tasks Pill -->
                <a href="${pageContext.request.contextPath}/tasks" class="btn btn-outline-light btn-sm position-relative me-3 border-0">
                    <i class="bi bi-check2-circle fs-5"></i>
                    <c:if test="${openTaskCount > 0}">
                        <span class="position-absolute top-0 start-100 translate-middle badge rounded-pill bg-warning text-dark">
                            ${openTaskCount}
                        </span>
                    </c:if>
                </a>

                <!-- Notifications Pill -->
                <a href="${pageContext.request.contextPath}/notifications" class="btn btn-outline-light btn-sm position-relative me-3 border-0">
                    <i class="bi bi-bell fs-5"></i>
                    <c:if test="${unreadNotificationCount > 0}">
                        <span class="position-absolute top-0 start-100 translate-middle badge rounded-pill bg-danger">
                            ${unreadNotificationCount}
                        </span>
                    </c:if>
                </a>

                <!-- User Profile & Logout -->
                <div class="dropdown">
                    <button class="btn btn-dark btn-sm dropdown-toggle d-flex align-items-center" type="button" data-bs-toggle="dropdown">
                        <i class="bi bi-person-circle fs-5 me-2"></i>
                        <span class="d-none d-md-inline fw-semibold">${currentUser.firstName} ${currentUser.lastName}</span>
                        <c:forEach items="${currentUser.roles}" var="role">
                            <span class="badge bg-secondary ms-2">${role.name}</span>
                        </c:forEach>
                    </button>
                    <ul class="dropdown-menu dropdown-menu-end shadow">
                        <li class="dropdown-header text-muted small">${currentUser.email}</li>
                        <c:if test="${currentUser.department != null}">
                            <li class="dropdown-header text-muted small">Dept: ${currentUser.department.name}</li>
                        </c:if>
                        <li><hr class="dropdown-divider"></li>
                        <li>
                            <form action="${pageContext.request.contextPath}/logout" method="post" class="px-2">
                                <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}" />
                                <button type="submit" class="dropdown-item text-danger d-flex align-items-center">
                                    <i class="bi bi-box-arrow-right me-2"></i> Sign Out
                                </button>
                            </form>
                        </li>
                    </ul>
                </div>
            </c:if>
        </div>
    </div>
</nav>

<div class="container-fluid">
    <div class="row">
