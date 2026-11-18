<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<c:set var="activePage" value="dashboard" />
<c:set var="pageTitle" value="Dashboard — FlowSphere" />
<jsp:include page="fragments/header.jsp" />
<jsp:include page="fragments/sidebar.jsp" />

<main class="col-md-9 ms-sm-auto col-lg-10 px-md-4 py-4">
    <!-- Header row -->
    <div class="d-flex justify-content-between flex-wrap flex-md-nowrap align-items-center pt-2 pb-3 mb-3 border-bottom">
        <div>
            <h1 class="h3 fw-bold mb-1">Welcome back, ${currentUser.firstName}!</h1>
            <p class="text-muted small mb-0">
                Department: <span class="fw-semibold text-dark">${currentUser.department != null ? currentUser.department.name : 'General'}</span> | 
                Role: 
                <c:forEach items="${currentUser.roles}" var="role">
                    <span class="badge bg-primary-subtle text-primary fw-bold">${role.name}</span>
                </c:forEach>
            </p>
        </div>
        <div class="btn-toolbar mb-2 mb-md-0">
            <a href="${pageContext.request.contextPath}/requests/new" class="btn btn-primary d-flex align-items-center shadow-sm">
                <i class="bi bi-plus-lg me-2"></i> Submit Request
            </a>
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

    <!-- Stat Cards -->
    <div class="row g-3 mb-4">
        <div class="col-12 col-sm-6 col-xl-3">
            <div class="card card-custom p-3 border-start border-primary border-4">
                <div class="d-flex align-items-center justify-content-between">
                    <div>
                        <div class="text-muted small fw-semibold text-uppercase">Total Requests</div>
                        <div class="fs-3 fw-bold text-dark mt-1">${totalCount}</div>
                    </div>
                    <div class="p-3 bg-primary-subtle text-primary rounded-circle">
                        <i class="bi bi-folder2-open fs-4"></i>
                    </div>
                </div>
            </div>
        </div>

        <div class="col-12 col-sm-6 col-xl-3">
            <div class="card card-custom p-3 border-start border-warning border-4">
                <div class="d-flex align-items-center justify-content-between">
                    <div>
                        <div class="text-muted small fw-semibold text-uppercase">Pending Approval</div>
                        <div class="fs-3 fw-bold text-dark mt-1">${pendingCount}</div>
                    </div>
                    <div class="p-3 bg-warning-subtle text-warning rounded-circle">
                        <i class="bi bi-hourglass-split fs-4"></i>
                    </div>
                </div>
            </div>
        </div>

        <div class="col-12 col-sm-6 col-xl-3">
            <div class="card card-custom p-3 border-start border-success border-4">
                <div class="d-flex align-items-center justify-content-between">
                    <div>
                        <div class="text-muted small fw-semibold text-uppercase">Completed</div>
                        <div class="fs-3 fw-bold text-dark mt-1">${completedCount}</div>
                    </div>
                    <div class="p-3 bg-success-subtle text-success rounded-circle">
                        <i class="bi bi-check-circle fs-4"></i>
                    </div>
                </div>
            </div>
        </div>

        <div class="col-12 col-sm-6 col-xl-3">
            <div class="card card-custom p-3 border-start border-danger border-4">
                <div class="d-flex align-items-center justify-content-between">
                    <div>
                        <div class="text-muted small fw-semibold text-uppercase">Changes Requested</div>
                        <div class="fs-3 fw-bold text-dark mt-1">${changesReqCount}</div>
                    </div>
                    <div class="p-3 bg-danger-subtle text-danger rounded-circle">
                        <i class="bi bi-arrow-repeat fs-4"></i>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- Approvals Queue Section (if any pending for user) -->
    <c:if test="${not empty pendingApprovals}">
        <div class="card card-custom mb-4 shadow-sm">
            <div class="card-header bg-white py-3 d-flex justify-content-between align-items-center">
                <h6 class="fw-bold text-primary mb-0">
                    <i class="bi bi-inbox-fill me-2"></i> Action Required — Pending Your Approval (${pendingApprovals.size()})
                </h6>
                <a href="${pageContext.request.contextPath}/approvals" class="btn btn-outline-primary btn-sm">View Full Queue</a>
            </div>
            <div class="table-responsive">
                <table class="table table-hover align-middle mb-0">
                    <thead class="table-light small">
                        <tr>
                            <th>Request #</th>
                            <th>Title</th>
                            <th>Requester</th>
                            <th>Department</th>
                            <th>Priority</th>
                            <th>Stage</th>
                            <th class="text-end">Action</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach items="${pendingApprovals}" var="stage">
                            <tr>
                                <td class="fw-bold font-monospace">${stage.workflowInstance.request.requestNumber}</td>
                                <td>${stage.workflowInstance.request.title}</td>
                                <td>${stage.workflowInstance.request.createdBy.firstName} ${stage.workflowInstance.request.createdBy.lastName}</td>
                                <td>${stage.workflowInstance.request.department != null ? stage.workflowInstance.request.department.code : 'IT'}</td>
                                <td>
                                    <span class="badge ${stage.workflowInstance.request.priority == 'HIGH' or stage.workflowInstance.request.priority == 'CRITICAL' or stage.workflowInstance.request.priority == 'URGENT' ? 'bg-danger' : 'bg-info text-dark'}">
                                        ${stage.workflowInstance.request.priority}
                                    </span>
                                </td>
                                <td><span class="badge bg-secondary">${stage.stageName}</span></td>
                                <td class="text-end">
                                    <a href="${pageContext.request.contextPath}/requests/${stage.workflowInstance.request.id}" class="btn btn-primary btn-sm">
                                        Review &amp; Decide <i class="bi bi-chevron-right ms-1"></i>
                                    </a>
                                </td>
                            </tr>
                        </c:forEach>
                    </tbody>
                </table>
            </div>
        </div>
    </c:if>

    <!-- Recent Requests Section -->
    <div class="card card-custom mb-4 shadow-sm">
        <div class="card-header bg-white py-3 d-flex justify-content-between align-items-center">
            <h6 class="fw-bold text-dark mb-0">
                <i class="bi bi-clock-history me-2"></i> ${isSuperAdmin ? 'All System Requests' : 'My Recent Requests'}
            </h6>
            <a href="${pageContext.request.contextPath}/requests" class="btn btn-outline-secondary btn-sm">View All</a>
        </div>
        <div class="table-responsive">
            <table class="table table-hover align-middle mb-0">
                <thead class="table-light small">
                    <tr>
                        <th>Request #</th>
                        <th>Title</th>
                        <th>Type</th>
                        <th>Priority</th>
                        <th>Status</th>
                        <th>Created</th>
                        <th class="text-end">Details</th>
                    </tr>
                </thead>
                <tbody>
                    <c:choose>
                        <c:when test="${empty recentRequests}">
                            <tr>
                                <td colspan="7" class="text-center py-4 text-muted">
                                    <i class="bi bi-inbox fs-2 d-block mb-2 text-secondary"></i>
                                    No requests found. Click <strong>Submit Request</strong> to get started.
                                </td>
                            </tr>
                        </c:when>
                        <c:otherwise>
                            <c:forEach items="${recentRequests}" var="req">
                                <tr>
                                    <td class="fw-bold font-monospace text-primary">
                                        <a href="${pageContext.request.contextPath}/requests/${req.id}" class="text-decoration-none">
                                            ${req.requestNumber}
                                        </a>
                                    </td>
                                    <td>${req.title}</td>
                                    <td><span class="badge bg-light text-dark border">${req.requestType}</span></td>
                                    <td>
                                        <span class="badge ${req.priority == 'HIGH' or req.priority == 'CRITICAL' or req.priority == 'URGENT' ? 'bg-danger' : 'bg-info text-dark'}">
                                            ${req.priority}
                                        </span>
                                    </td>
                                    <td><span class="badge-status status-${req.status}">${req.status}</span></td>
                                    <td class="small text-muted">${req.createdAt}</td>
                                    <td class="text-end">
                                        <a href="${pageContext.request.contextPath}/requests/${req.id}" class="btn btn-outline-secondary btn-sm">
                                            View <i class="bi bi-arrow-right"></i>
                                        </a>
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

<jsp:include page="fragments/footer.jsp" />
