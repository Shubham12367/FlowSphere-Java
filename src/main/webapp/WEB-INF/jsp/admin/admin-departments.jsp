<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<c:set var="activePage" value="admin-departments" />
<c:set var="pageTitle" value="Department Management — FlowSphere Admin" />
<jsp:include page="../fragments/header.jsp" />
<jsp:include page="../fragments/sidebar.jsp" />

<main class="col-md-9 ms-sm-auto col-lg-10 px-md-4 py-4">
    <!-- Header -->
    <div class="d-flex justify-content-between flex-wrap flex-md-nowrap align-items-center pt-2 pb-3 mb-3 border-bottom">
        <div>
            <h1 class="h3 fw-bold mb-1"><i class="bi bi-building me-2"></i>Department Management</h1>
            <p class="text-muted small mb-0">Create and manage organizational departments.</p>
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

    <!-- Departments Table -->
    <div class="card card-custom mb-4 shadow-sm">
        <div class="card-header bg-white py-3 d-flex justify-content-between align-items-center">
            <h6 class="fw-bold text-dark mb-0">
                <i class="bi bi-diagram-2 me-2"></i> All Departments
                <span class="badge bg-primary-subtle text-primary ms-2">${departments.size()}</span>
            </h6>
        </div>
        <div class="table-responsive">
            <table class="table table-hover align-middle mb-0">
                <thead class="table-light small">
                    <tr>
                        <th>Department Name</th>
                        <th>Code</th>
                        <th>Head User</th>
                        <th class="text-center"># of Users</th>
                    </tr>
                </thead>
                <tbody>
                    <c:choose>
                        <c:when test="${empty departments}">
                            <tr>
                                <td colspan="4" class="text-center py-4 text-muted">
                                    <i class="bi bi-building fs-2 d-block mb-2 text-secondary"></i>
                                    No departments found. Create one below.
                                </td>
                            </tr>
                        </c:when>
                        <c:otherwise>
                            <c:forEach items="${departments}" var="dept">
                                <tr>
                                    <td class="fw-semibold">${dept.name}</td>
                                    <td><span class="badge bg-light text-dark border font-monospace">${dept.code}</span></td>
                                    <td>
                                        <c:choose>
                                            <c:when test="${dept.headUser != null}">
                                                <i class="bi bi-person-badge me-1 text-primary"></i>
                                                ${dept.headUser.firstName} ${dept.headUser.lastName}
                                            </c:when>
                                            <c:otherwise>
                                                <span class="text-muted fst-italic small">Not assigned</span>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td class="text-center">
                                        <span class="badge bg-secondary">${dept.users != null ? dept.users.size() : 0}</span>
                                    </td>
                                </tr>
                            </c:forEach>
                        </c:otherwise>
                    </c:choose>
                </tbody>
            </table>
        </div>
    </div>

    <!-- Create Department Form -->
    <div class="card card-custom shadow-sm">
        <div class="card-header bg-white py-3">
            <h6 class="fw-bold text-dark mb-0">
                <i class="bi bi-plus-circle me-2"></i> Create New Department
            </h6>
        </div>
        <div class="card-body">
            <form action="${pageContext.request.contextPath}/admin/departments" method="post">
                <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}" />
                <div class="row g-3 align-items-end">
                    <!-- Name -->
                    <div class="col-md-4">
                        <label class="form-label small fw-semibold" for="deptName">Department Name <span class="text-danger">*</span></label>
                        <input type="text" class="form-control" id="deptName" name="name" placeholder="e.g. Human Resources" required />
                    </div>
                    <!-- Code -->
                    <div class="col-md-3">
                        <label class="form-label small fw-semibold" for="deptCode">Code <span class="text-danger">*</span></label>
                        <input type="text" class="form-control" id="deptCode" name="code" placeholder="e.g. HR" required />
                    </div>
                    <!-- Head User -->
                    <div class="col-md-3">
                        <label class="form-label small fw-semibold" for="headUserId">Head User <span class="text-muted">(optional)</span></label>
                        <select class="form-select" id="headUserId" name="headUserId">
                            <option value="">— None —</option>
                            <c:forEach items="${users}" var="u">
                                <option value="${u.id}">${u.firstName} ${u.lastName}</option>
                            </c:forEach>
                        </select>
                    </div>
                    <!-- Submit -->
                    <div class="col-md-2">
                        <button type="submit" class="btn btn-primary w-100">
                            <i class="bi bi-plus-lg me-1"></i> Create
                        </button>
                    </div>
                </div>
            </form>
        </div>
    </div>
</main>

<jsp:include page="../fragments/footer.jsp" />
