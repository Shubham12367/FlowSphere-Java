<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="activePage" value="requests" />
<c:set var="pageTitle" value="All Requests — FlowSphere" />
<jsp:include page="../fragments/header.jsp" />
<jsp:include page="../fragments/sidebar.jsp" />

<main class="col-md-9 ms-sm-auto col-lg-10 px-md-4 py-4">
    <div class="d-flex justify-content-between flex-wrap flex-md-nowrap align-items-center pt-2 pb-3 mb-3 border-bottom">
        <div>
            <h1 class="h3 fw-bold mb-1">Workflow Requests</h1>
            <p class="text-muted small mb-0">Browse, filter, and track all submitted and draft requests</p>
        </div>
        <div>
            <a href="${pageContext.request.contextPath}/requests/new" class="btn btn-primary d-flex align-items-center shadow-sm">
                <i class="bi bi-plus-lg me-2"></i> New Request
            </a>
        </div>
    </div>

    <!-- Filter Pills -->
    <div class="mb-3 d-flex flex-wrap gap-2">
        <a href="${pageContext.request.contextPath}/requests" class="btn btn-sm ${empty selectedStatus ? 'btn-dark' : 'btn-outline-secondary'}">
            All (${requests.size()})
        </a>
        <a href="${pageContext.request.contextPath}/requests?status=PENDING_APPROVAL" class="btn btn-sm ${selectedStatus == 'PENDING_APPROVAL' ? 'btn-warning text-dark fw-bold' : 'btn-outline-warning text-dark'}">
            Pending Approval
        </a>
        <a href="${pageContext.request.contextPath}/requests?status=COMPLETED" class="btn btn-sm ${selectedStatus == 'COMPLETED' ? 'btn-success text-white fw-bold' : 'btn-outline-success'}">
            Completed
        </a>
        <a href="${pageContext.request.contextPath}/requests?status=CHANGES_REQUESTED" class="btn btn-sm ${selectedStatus == 'CHANGES_REQUESTED' ? 'btn-danger text-white fw-bold' : 'btn-outline-danger'}">
            Changes Requested
        </a>
        <a href="${pageContext.request.contextPath}/requests?status=DRAFT" class="btn btn-sm ${selectedStatus == 'DRAFT' ? 'btn-secondary text-white fw-bold' : 'btn-outline-secondary'}">
            Drafts
        </a>
    </div>

    <!-- Table Card -->
    <div class="card card-custom shadow-sm">
        <div class="table-responsive">
            <table class="table table-hover align-middle mb-0">
                <thead class="table-light small">
                    <tr>
                        <th>Request #</th>
                        <th>Title</th>
                        <th>Requester</th>
                        <th>Department</th>
                        <th>Type</th>
                        <th>Priority</th>
                        <th>Status</th>
                        <th>Submitted</th>
                        <th class="text-end">Action</th>
                    </tr>
                </thead>
                <tbody>
                    <c:choose>
                        <c:when test="${empty requests}">
                            <tr>
                                <td colspan="9" class="text-center py-5 text-muted">
                                    <i class="bi bi-folder-x fs-2 d-block mb-2 text-secondary"></i>
                                    No requests found matching current filter.
                                </td>
                            </tr>
                        </c:when>
                        <c:otherwise>
                            <c:forEach items="${requests}" var="req">
                                <tr>
                                    <td class="fw-bold font-monospace text-primary">
                                        <a href="${pageContext.request.contextPath}/requests/${req.id}" class="text-decoration-none">
                                            ${req.requestNumber}
                                        </a>
                                    </td>
                                    <td>${req.title}</td>
                                    <td class="small">${req.createdBy.firstName} ${req.createdBy.lastName}</td>
                                    <td><span class="badge bg-light text-secondary border">${req.department != null ? req.department.code : 'IT'}</span></td>
                                    <td><span class="badge bg-light text-dark border">${req.requestType}</span></td>
                                    <td>
                                        <span class="badge ${req.priority == 'HIGH' or req.priority == 'CRITICAL' or req.priority == 'URGENT' ? 'bg-danger' : 'bg-info text-dark'}">
                                            ${req.priority}
                                        </span>
                                    </td>
                                    <td><span class="badge-status status-${req.status}">${req.status}</span></td>
                                    <td class="small text-muted">${req.createdAt}</td>
                                    <td class="text-end">
                                        <div class="btn-group btn-group-sm">
                                            <a href="${pageContext.request.contextPath}/requests/${req.id}" class="btn btn-outline-primary">
                                                View
                                            </a>
                                            <c:if test="${req.status == 'DRAFT' or req.status == 'CHANGES_REQUESTED'}">
                                                <a href="${pageContext.request.contextPath}/requests/${req.id}/edit" class="btn btn-outline-secondary">
                                                    Edit
                                                </a>
                                            </c:if>
                                        </div>
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
