<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<c:set var="activePage" value="admin-workflows" />
<c:set var="pageTitle" value="Workflow Management — FlowSphere Admin" />
<jsp:include page="../fragments/header.jsp" />
<jsp:include page="../fragments/sidebar.jsp" />

<main class="col-md-9 ms-sm-auto col-lg-10 px-md-4 py-4">
    <!-- Header -->
    <div class="d-flex justify-content-between flex-wrap flex-md-nowrap align-items-center pt-2 pb-3 mb-3 border-bottom">
        <div>
            <h1 class="h3 fw-bold mb-1"><i class="bi bi-diagram-3 me-2"></i>Workflow Definitions</h1>
            <p class="text-muted small mb-0">Manage workflow templates and their activation status.</p>
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

    <!-- Workflows Table -->
    <div class="card card-custom mb-4 shadow-sm">
        <div class="card-header bg-white py-3 d-flex justify-content-between align-items-center">
            <h6 class="fw-bold text-dark mb-0">
                <i class="bi bi-collection me-2"></i> All Workflow Definitions
                <span class="badge bg-primary-subtle text-primary ms-2">${workflows.size()}</span>
            </h6>
        </div>
        <div class="table-responsive">
            <table class="table table-hover align-middle mb-0">
                <thead class="table-light small">
                    <tr>
                        <th>Name</th>
                        <th>Category</th>
                        <th>Status</th>
                        <th>Version</th>
                        <th class="text-end">Action</th>
                    </tr>
                </thead>
                <tbody>
                    <c:choose>
                        <c:when test="${empty workflows}">
                            <tr>
                                <td colspan="5" class="text-center py-4 text-muted">
                                    <i class="bi bi-diagram-3 fs-2 d-block mb-2 text-secondary"></i>
                                    No workflow definitions found.
                                </td>
                            </tr>
                        </c:when>
                        <c:otherwise>
                            <c:forEach items="${workflows}" var="wf">
                                <tr>
                                    <td class="fw-semibold">${wf.name}</td>
                                    <td><span class="badge bg-light text-dark border">${wf.category}</span></td>
                                    <td>
                                        <c:choose>
                                            <c:when test="${wf.status == 'ACTIVE'}">
                                                <span class="badge bg-success-subtle text-success">
                                                    <i class="bi bi-check-circle-fill me-1"></i>ACTIVE
                                                </span>
                                            </c:when>
                                            <c:when test="${wf.status == 'INACTIVE'}">
                                                <span class="badge bg-secondary-subtle text-secondary">
                                                    <i class="bi bi-pause-circle-fill me-1"></i>INACTIVE
                                                </span>
                                            </c:when>
                                            <c:when test="${wf.status == 'DEPRECATED'}">
                                                <span class="badge bg-warning-subtle text-warning">
                                                    <i class="bi bi-exclamation-triangle-fill me-1"></i>DEPRECATED
                                                </span>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="badge bg-light text-dark">${wf.status}</span>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td>
                                        <span class="badge bg-info-subtle text-info font-monospace">
                                            v${wf.currentVersion != null ? wf.currentVersion.versionNumber : '—'}
                                        </span>
                                    </td>
                                    <td class="text-end">
                                        <form action="${pageContext.request.contextPath}/admin/workflows/${wf.id}/toggle-status" method="post" class="d-inline">
                                            <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}" />
                                            <c:choose>
                                                <c:when test="${wf.status == 'ACTIVE'}">
                                                    <button type="submit" class="btn btn-outline-danger btn-sm"
                                                            onclick="return confirm('Are you sure you want to deactivate this workflow?')">
                                                        <i class="bi bi-pause-circle me-1"></i> Deactivate
                                                    </button>
                                                </c:when>
                                                <c:otherwise>
                                                    <button type="submit" class="btn btn-outline-success btn-sm"
                                                            onclick="return confirm('Are you sure you want to activate this workflow?')">
                                                        <i class="bi bi-play-circle me-1"></i> Activate
                                                    </button>
                                                </c:otherwise>
                                            </c:choose>
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
