<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<c:set var="activePage" value="admin-users" />
<c:set var="pageTitle" value="User Management — FlowSphere Admin" />
<jsp:include page="../fragments/header.jsp" />
<jsp:include page="../fragments/sidebar.jsp" />

<main class="col-md-9 ms-sm-auto col-lg-10 px-md-4 py-4">
    <!-- Header -->
    <div class="d-flex justify-content-between flex-wrap flex-md-nowrap align-items-center pt-2 pb-3 mb-3 border-bottom">
        <div>
            <h1 class="h3 fw-bold mb-1"><i class="bi bi-people me-2"></i>User Management</h1>
            <p class="text-muted small mb-0">Manage user accounts, roles, departments, and account statuses.</p>
        </div>
    </div>

    <!-- Alert Messages -->
    <c:if test="${not empty successMessage}">
        <div class="alert alert-success alert-dismissible fade show py-2" role="alert">
            <i class="bi bi-check-circle-fill me-2"></i> ${successMessage}
            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
        </div>
    </c:if>
    <c:if test="${not empty errorMessage}">
        <div class="alert alert-danger alert-dismissible fade show py-2" role="alert">
            <i class="bi bi-exclamation-triangle-fill me-2"></i> ${errorMessage}
            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
        </div>
    </c:if>

    <!-- Users Table -->
    <div class="card card-custom mb-4 shadow-sm">
        <div class="card-header bg-white py-3 d-flex justify-content-between align-items-center">
            <h6 class="fw-bold text-dark mb-0">
                <i class="bi bi-person-lines-fill me-2"></i> All Users
                <span class="badge bg-primary-subtle text-primary ms-2">${users.size()}</span>
            </h6>
        </div>
        <div class="table-responsive">
            <table class="table table-hover align-middle mb-0">
                <thead class="table-light small">
                    <tr>
                        <th>Name</th>
                        <th>Email</th>
                        <th>Department</th>
                        <th>Roles</th>
                        <th>Status</th>
                        <th class="text-end">Actions</th>
                    </tr>
                </thead>
                <tbody>
                    <c:choose>
                        <c:when test="${empty users}">
                            <tr>
                                <td colspan="6" class="text-center py-4 text-muted">
                                    <i class="bi bi-people fs-2 d-block mb-2 text-secondary"></i>
                                    No users found.
                                </td>
                            </tr>
                        </c:when>
                        <c:otherwise>
                            <c:forEach items="${users}" var="user" varStatus="loop">
                                <tr>
                                    <td class="fw-semibold">${user.firstName} ${user.lastName}</td>
                                    <td class="text-muted small">${user.email}</td>
                                    <td>
                                        <c:choose>
                                            <c:when test="${user.department != null}">
                                                <span class="badge bg-light text-dark border">${user.department.name}</span>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="text-muted fst-italic small">Unassigned</span>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td>
                                        <c:forEach items="${user.roles}" var="role">
                                            <span class="badge bg-primary-subtle text-primary me-1">${role.name}</span>
                                        </c:forEach>
                                    </td>
                                    <td>
                                        <c:choose>
                                            <c:when test="${user.status == 'ACTIVE'}">
                                                <span class="badge bg-success-subtle text-success">ACTIVE</span>
                                            </c:when>
                                            <c:when test="${user.status == 'INACTIVE'}">
                                                <span class="badge bg-secondary-subtle text-secondary">INACTIVE</span>
                                            </c:when>
                                            <c:when test="${user.status == 'SUSPENDED'}">
                                                <span class="badge bg-danger-subtle text-danger">SUSPENDED</span>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="badge bg-light text-dark">${user.status}</span>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td class="text-end">
                                        <button class="btn btn-outline-primary btn-sm" type="button"
                                                data-bs-toggle="collapse" data-bs-target="#editRow-${user.id}"
                                                aria-expanded="false" aria-controls="editRow-${user.id}">
                                            <i class="bi bi-pencil-square me-1"></i> Edit
                                        </button>
                                    </td>
                                </tr>
                                <!-- Inline Edit Row -->
                                <tr class="collapse" id="editRow-${user.id}">
                                    <td colspan="6" class="bg-light border-top-0">
                                        <form action="${pageContext.request.contextPath}/admin/users/${user.id}/update" method="post">
                                            <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}" />
                                            <div class="row g-3 align-items-end p-2">
                                                <!-- Department -->
                                                <div class="col-md-3">
                                                    <label class="form-label small fw-semibold" for="dept-${user.id}">Department</label>
                                                    <select class="form-select form-select-sm" id="dept-${user.id}" name="departmentId">
                                                        <option value="">— Unassigned —</option>
                                                        <c:forEach items="${departments}" var="dept">
                                                            <option value="${dept.id}" ${user.department != null && user.department.id == dept.id ? 'selected' : ''}>${dept.name}</option>
                                                        </c:forEach>
                                                    </select>
                                                </div>
                                                <!-- Roles (checkboxes) -->
                                                <div class="col-md-4">
                                                    <label class="form-label small fw-semibold">Roles</label>
                                                    <div class="d-flex flex-wrap gap-2">
                                                        <c:forEach items="${roles}" var="role">
                                                            <div class="form-check">
                                                                <input class="form-check-input" type="checkbox"
                                                                       name="roleNames" value="${role.name}"
                                                                       id="role-${user.id}-${role.name}"
                                                                       <c:forEach items="${user.roles}" var="userRole">
                                                                           <c:if test="${userRole.name == role.name}">checked</c:if>
                                                                       </c:forEach>
                                                                />
                                                                <label class="form-check-label small" for="role-${user.id}-${role.name}">${role.name}</label>
                                                            </div>
                                                        </c:forEach>
                                                    </div>
                                                </div>
                                                <!-- Status -->
                                                <div class="col-md-2">
                                                    <label class="form-label small fw-semibold" for="status-${user.id}">Status</label>
                                                    <select class="form-select form-select-sm" id="status-${user.id}" name="status">
                                                        <c:forEach items="${statuses}" var="st">
                                                            <option value="${st}" ${user.status == st ? 'selected' : ''}>${st}</option>
                                                        </c:forEach>
                                                    </select>
                                                </div>
                                                <!-- Submit -->
                                                <div class="col-md-3 text-end">
                                                    <button type="submit" class="btn btn-primary btn-sm">
                                                        <i class="bi bi-save me-1"></i> Save Changes
                                                    </button>
                                                    <button type="button" class="btn btn-outline-secondary btn-sm"
                                                            data-bs-toggle="collapse" data-bs-target="#editRow-${user.id}">
                                                        Cancel
                                                    </button>
                                                </div>
                                            </div>
                                        </form>
                                    </td>
                                </tr>
                            </c:forEach>
                        </c:otherwise>
                    </c:choose>
                </tbody>
            </table>
        </div>
    </div>
</main>

<jsp:include page="../fragments/footer.jsp" />
