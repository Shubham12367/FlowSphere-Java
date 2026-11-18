<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<c:set var="activePage" value="tasks" />
<c:set var="pageTitle" value="My Tasks — FlowSphere" />
<jsp:include page="../fragments/header.jsp" />
<jsp:include page="../fragments/sidebar.jsp" />

<main class="col-md-9 ms-sm-auto col-lg-10 px-md-4 py-4">
    <div class="d-flex justify-content-between flex-wrap flex-md-nowrap align-items-center pt-2 pb-3 mb-3 border-bottom">
        <div>
            <h1 class="h3 fw-bold mb-1"><i class="bi bi-check2-square me-2 text-primary"></i>My Tasks</h1>
            <p class="text-muted small mb-0">Track and manage tasks assigned to you</p>
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

    <!-- Tasks Table Card -->
    <div class="card card-custom shadow-sm">
        <div class="card-header bg-white py-3">
            <h6 class="fw-bold text-dark mb-0">
                <i class="bi bi-list-task me-2"></i> Assigned Tasks
                <c:if test="${not empty tasks}">
                    <span class="badge bg-primary ms-2">${tasks.size()}</span>
                </c:if>
            </h6>
        </div>
        <div class="table-responsive">
            <table class="table table-hover align-middle mb-0">
                <thead class="table-light small">
                    <tr>
                        <th>Title</th>
                        <th>Related Request</th>
                        <th>Status</th>
                        <th class="text-end">Action</th>
                    </tr>
                </thead>
                <tbody>
                    <c:choose>
                        <c:when test="${empty tasks}">
                            <tr>
                                <td colspan="4" class="text-center py-5 text-muted">
                                    <i class="bi bi-clipboard-check fs-2 d-block mb-2 text-success"></i>
                                    No tasks assigned. You're all caught up!
                                </td>
                            </tr>
                        </c:when>
                        <c:otherwise>
                            <c:forEach items="${tasks}" var="task">
                                <tr>
                                    <td>
                                        <div class="fw-semibold">${task.title}</div>
                                        <c:if test="${not empty task.description}">
                                            <div class="small text-muted text-truncate" style="max-width: 350px;">${task.description}</div>
                                        </c:if>
                                    </td>
                                    <td>
                                        <a href="${pageContext.request.contextPath}/requests/${task.stageInstance.workflowInstance.request.id}" class="text-decoration-none fw-bold font-monospace">
                                            ${task.stageInstance.workflowInstance.request.requestNumber}
                                        </a>
                                    </td>
                                    <td>
                                        <c:choose>
                                            <c:when test="${task.status == 'OPEN'}">
                                                <span class="badge bg-info text-dark">OPEN</span>
                                            </c:when>
                                            <c:when test="${task.status == 'IN_PROGRESS'}">
                                                <span class="badge bg-warning text-dark">IN PROGRESS</span>
                                            </c:when>
                                            <c:when test="${task.status == 'COMPLETED'}">
                                                <span class="badge bg-success">COMPLETED</span>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="badge bg-secondary">${task.status}</span>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td class="text-end">
                                        <c:choose>
                                            <c:when test="${task.status == 'OPEN' or task.status == 'IN_PROGRESS'}">
                                                <form action="${pageContext.request.contextPath}/tasks/${task.id}/complete" method="post" class="d-inline">
                                                    <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}" />
                                                    <button type="submit" class="btn btn-success btn-sm">
                                                        <i class="bi bi-check-lg me-1"></i> Complete
                                                    </button>
                                                </form>
                                            </c:when>
                                            <c:when test="${task.status == 'COMPLETED'}">
                                                <span class="text-success">
                                                    <i class="bi bi-check-circle-fill fs-5"></i>
                                                </span>
                                            </c:when>
                                        </c:choose>
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
