<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<div class="col-md-3 col-lg-2 d-md-block sidebar py-3 px-2 collapse d-md-block">
    <div class="nav flex-column">
        <div class="text-uppercase text-muted fw-bold px-3 py-2 small" style="font-size: 0.75rem; letter-spacing: 0.05em;">
            Workflows
        </div>
        <a class="sidebar-link ${activePage == 'dashboard' ? 'active' : ''}" href="${pageContext.request.contextPath}/dashboard">
            <i class="bi bi-speedometer2"></i> Dashboard
        </a>
        <a class="sidebar-link ${activePage == 'new-request' ? 'active' : ''}" href="${pageContext.request.contextPath}/requests/new">
            <i class="bi bi-plus-circle"></i> New Request
        </a>
        <a class="sidebar-link ${activePage == 'requests' ? 'active' : ''}" href="${pageContext.request.contextPath}/requests">
            <i class="bi bi-file-earmark-text"></i> All Requests
        </a>

        <!-- Approvals Queue: for Managers, Dept Heads, Processors, Super Admin -->
        <c:if test="${pageContext.request.isUserInRole('ROLE_MANAGER') or pageContext.request.isUserInRole('ROLE_DEPARTMENT_HEAD') or pageContext.request.isUserInRole('ROLE_PROCESSOR') or pageContext.request.isUserInRole('ROLE_SUPER_ADMIN')}">
            <div class="text-uppercase text-muted fw-bold px-3 pt-3 pb-2 small" style="font-size: 0.75rem; letter-spacing: 0.05em;">
                Approvals
            </div>
            <a class="sidebar-link ${activePage == 'approvals' ? 'active' : ''}" href="${pageContext.request.contextPath}/approvals">
                <i class="bi bi-inbox-fill"></i> Approval Queue
            </a>
        </c:if>

        <div class="text-uppercase text-muted fw-bold px-3 pt-3 pb-2 small" style="font-size: 0.75rem; letter-spacing: 0.05em;">
            My Workspace
        </div>
        <a class="sidebar-link ${activePage == 'tasks' ? 'active' : ''}" href="${pageContext.request.contextPath}/tasks">
            <i class="bi bi-check2-square"></i> Tasks
            <c:if test="${openTaskCount > 0}">
                <span class="badge bg-warning text-dark ms-auto">${openTaskCount}</span>
            </c:if>
        </a>
        <a class="sidebar-link ${activePage == 'notifications' ? 'active' : ''}" href="${pageContext.request.contextPath}/notifications">
            <i class="bi bi-bell"></i> Notifications
            <c:if test="${unreadNotificationCount > 0}">
                <span class="badge bg-danger ms-auto">${unreadNotificationCount}</span>
            </c:if>
        </a>

        <!-- Super Admin Panel -->
        <c:if test="${pageContext.request.isUserInRole('ROLE_SUPER_ADMIN')}">
            <div class="text-uppercase text-muted fw-bold px-3 pt-3 pb-2 small" style="font-size: 0.75rem; letter-spacing: 0.05em;">
                Administration
            </div>
            <a class="sidebar-link ${activePage == 'admin-users' ? 'active' : ''}" href="${pageContext.request.contextPath}/admin/users">
                <i class="bi bi-people"></i> Users
            </a>
            <a class="sidebar-link ${activePage == 'admin-departments' ? 'active' : ''}" href="${pageContext.request.contextPath}/admin/departments">
                <i class="bi bi-building"></i> Departments
            </a>
            <a class="sidebar-link ${activePage == 'admin-workflows' ? 'active' : ''}" href="${pageContext.request.contextPath}/admin/workflows">
                <i class="bi bi-diagram-3"></i> Workflows
            </a>
            <a class="sidebar-link ${activePage == 'admin-audit' ? 'active' : ''}" href="${pageContext.request.contextPath}/admin/audit-logs">
                <i class="bi bi-journal-text"></i> Audit Logs
            </a>
        </c:if>
    </div>
</div>
