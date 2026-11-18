<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<c:set var="activePage" value="approvals" />
<c:set var="pageTitle" value="Approval Queue — FlowSphere" />
<jsp:include page="../fragments/header.jsp" />
<jsp:include page="../fragments/sidebar.jsp" />

<main class="col-md-9 ms-sm-auto col-lg-10 px-md-4 py-4">
    <div class="d-flex justify-content-between flex-wrap flex-md-nowrap align-items-center pt-2 pb-3 mb-3 border-bottom">
        <div>
            <h1 class="h3 fw-bold mb-1"><i class="bi bi-inbox-fill me-2 text-primary"></i>Approval Queue</h1>
            <p class="text-muted small mb-0">Review and act on requests pending your approval</p>
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

    <!-- Approvals Table Card -->
    <div class="card card-custom shadow-sm">
        <div class="card-header bg-white py-3">
            <h6 class="fw-bold text-dark mb-0">
                <i class="bi bi-hourglass-split me-2"></i> Pending Approvals
                <c:if test="${not empty pendingApprovals}">
                    <span class="badge bg-warning text-dark ms-2">${pendingApprovals.size()}</span>
                </c:if>
            </h6>
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
                        <th>Created</th>
                        <th class="text-end">Action</th>
                    </tr>
                </thead>
                <tbody>
                    <c:choose>
                        <c:when test="${empty pendingApprovals}">
                            <tr>
                                <td colspan="8" class="text-center py-5 text-muted">
                                    <i class="bi bi-check-circle fs-2 d-block mb-2 text-success"></i>
                                    No pending approvals. You're all caught up!
                                </td>
                            </tr>
                        </c:when>
                        <c:otherwise>
                            <c:forEach items="${pendingApprovals}" var="stage">
                                <tr>
                                    <td class="fw-bold font-monospace text-primary">
                                        <a href="${pageContext.request.contextPath}/requests/${stage.workflowInstance.request.id}" class="text-decoration-none">
                                            ${stage.workflowInstance.request.requestNumber}
                                        </a>
                                    </td>
                                    <td>${stage.workflowInstance.request.title}</td>
                                    <td class="small">${stage.workflowInstance.request.createdBy.firstName} ${stage.workflowInstance.request.createdBy.lastName}</td>
                                    <td>
                                        <span class="badge bg-light text-secondary border">
                                            ${stage.workflowInstance.request.department != null ? stage.workflowInstance.request.department.code : 'N/A'}
                                        </span>
                                        <span class="small text-muted d-none d-lg-inline ms-1">
                                            ${stage.workflowInstance.request.department != null ? stage.workflowInstance.request.department.name : ''}
                                        </span>
                                    </td>
                                    <td>
                                        <span class="badge ${stage.workflowInstance.request.priority == 'HIGH' or stage.workflowInstance.request.priority == 'CRITICAL' or stage.workflowInstance.request.priority == 'URGENT' ? 'bg-danger' : 'bg-info text-dark'}">
                                            ${stage.workflowInstance.request.priority}
                                        </span>
                                    </td>
                                    <td><span class="badge bg-secondary">${stage.stageName}</span></td>
                                    <td class="small text-muted">${stage.workflowInstance.request.createdAt}</td>
                                    <td class="text-end">
                                        <a href="${pageContext.request.contextPath}/requests/${stage.workflowInstance.request.id}" class="btn btn-primary btn-sm">
                                            Review <i class="bi bi-chevron-right ms-1"></i>
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

<jsp:include page="../fragments/footer.jsp" />
