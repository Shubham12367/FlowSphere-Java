<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<c:set var="activePage" value="requests" />
<c:set var="pageTitle" value="Request ${request.requestNumber} — FlowSphere" />
<jsp:include page="../fragments/header.jsp" />
<jsp:include page="../fragments/sidebar.jsp" />

<main class="col-md-9 ms-sm-auto col-lg-10 px-md-4 py-4">

    <!-- Page Header -->
    <div class="d-flex justify-content-between flex-wrap flex-md-nowrap align-items-center pt-2 pb-3 mb-3 border-bottom">
        <div>
            <h1 class="h3 fw-bold mb-1">
                <i class="bi bi-file-earmark-text me-2 text-primary"></i>${request.title}
            </h1>
            <p class="text-muted small mb-0">
                <span class="font-monospace fw-bold text-primary">${request.requestNumber}</span>
                <span class="mx-2">•</span>
                <span class="badge-status status-${request.status}">${request.status}</span>
            </p>
        </div>
        <a href="${pageContext.request.contextPath}/requests" class="btn btn-outline-secondary btn-sm">
            <i class="bi bi-arrow-left me-1"></i> Back to Requests
        </a>
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

    <div class="row g-4">

        <!-- ============================================================ -->
        <!-- LEFT COLUMN: Request Info + Workflow Progress + Actions       -->
        <!-- ============================================================ -->
        <div class="col-lg-8">

            <!-- Request Info Card -->
            <div class="card card-custom shadow-sm mb-4">
                <div class="card-header bg-white py-3">
                    <h6 class="fw-bold text-dark mb-0"><i class="bi bi-info-circle me-2"></i>Request Details</h6>
                </div>
                <div class="card-body">
                    <div class="row g-3">
                        <div class="col-sm-6">
                            <div class="text-muted small fw-semibold text-uppercase mb-1">Request Number</div>
                            <div class="fw-bold font-monospace text-primary">${request.requestNumber}</div>
                        </div>
                        <div class="col-sm-6">
                            <div class="text-muted small fw-semibold text-uppercase mb-1">Status</div>
                            <span class="badge-status status-${request.status}">${request.status}</span>
                        </div>
                        <div class="col-sm-6">
                            <div class="text-muted small fw-semibold text-uppercase mb-1">Request Type</div>
                            <span class="badge bg-light text-dark border">${request.requestType}</span>
                        </div>
                        <div class="col-sm-6">
                            <div class="text-muted small fw-semibold text-uppercase mb-1">Priority</div>
                            <span class="badge ${request.priority == 'HIGH' or request.priority == 'CRITICAL' or request.priority == 'URGENT' ? 'bg-danger' : request.priority == 'LOW' ? 'bg-secondary' : 'bg-info text-dark'}">
                                <i class="bi ${request.priority == 'CRITICAL' or request.priority == 'URGENT' ? 'bi-exclamation-triangle-fill' : request.priority == 'HIGH' ? 'bi-arrow-up-circle-fill' : request.priority == 'LOW' ? 'bi-arrow-down-circle-fill' : 'bi-dash-circle'} me-1"></i>${request.priority}
                            </span>
                        </div>
                        <div class="col-sm-6">
                            <div class="text-muted small fw-semibold text-uppercase mb-1">Created By</div>
                            <div><i class="bi bi-person me-1"></i>${request.createdBy.firstName} ${request.createdBy.lastName}</div>
                        </div>
                        <div class="col-sm-6">
                            <div class="text-muted small fw-semibold text-uppercase mb-1">Department</div>
                            <div><i class="bi bi-building me-1"></i>${request.department != null ? request.department.name : 'N/A'}</div>
                        </div>
                        <div class="col-sm-6">
                            <div class="text-muted small fw-semibold text-uppercase mb-1">Created At</div>
                            <div class="small">${request.createdAt}</div>
                        </div>
                        <div class="col-sm-6">
                            <div class="text-muted small fw-semibold text-uppercase mb-1">Last Updated</div>
                            <div class="small">${request.updatedAt}</div>
                        </div>
                        <div class="col-12">
                            <div class="text-muted small fw-semibold text-uppercase mb-1">Description</div>
                            <p class="mb-0">${request.description}</p>
                        </div>
                        <c:if test="${not empty request.fieldValuesJson}">
                            <div class="col-12">
                                <div class="text-muted small fw-semibold text-uppercase mb-1">Specifications &amp; Item Details</div>
                                <div class="p-3 bg-light rounded border small" style="white-space: pre-line;">${request.fieldValuesJson}</div>
                            </div>
                        </c:if>
                        <c:if test="${not empty request.remarks}">
                            <div class="col-12">
                                <div class="text-muted small fw-semibold text-uppercase mb-1">Remarks</div>
                                <div class="alert alert-warning py-2 mb-0 small">
                                    <i class="bi bi-chat-left-text me-1"></i> ${request.remarks}
                                </div>
                            </div>
                        </c:if>
                    </div>
                </div>
            </div>

            <!-- Workflow Progress Card -->
            <c:if test="${not empty allStages}">
                <div class="card card-custom shadow-sm mb-4">
                    <div class="card-header bg-white py-3">
                        <h6 class="fw-bold text-dark mb-0"><i class="bi bi-diagram-3 me-2"></i>Workflow Progress</h6>
                    </div>
                    <div class="card-body">
                        <div class="position-relative">
                            <!-- Horizontal step indicator -->
                            <div class="d-flex align-items-start justify-content-between position-relative" style="overflow-x: auto;">
                                <!-- Connecting line -->
                                <div class="position-absolute" style="top: 20px; left: 30px; right: 30px; height: 3px; background: #e2e8f0; z-index: 0;"></div>
                                <c:forEach items="${allStages}" var="stage" varStatus="loop">
                                    <div class="text-center position-relative flex-fill px-2" style="z-index: 1; min-width: 120px;">
                                        <!-- Stage circle -->
                                        <c:choose>
                                            <c:when test="${stage.status == 'COMPLETED' or stage.status == 'APPROVED'}">
                                                <div class="rounded-circle d-inline-flex align-items-center justify-content-center mx-auto mb-2"
                                                     style="width: 42px; height: 42px; background-color: #dcfce7; border: 3px solid #16a34a;">
                                                    <i class="bi bi-check-lg text-success fw-bold"></i>
                                                </div>
                                            </c:when>
                                            <c:when test="${stage.status == 'REJECTED'}">
                                                <div class="rounded-circle d-inline-flex align-items-center justify-content-center mx-auto mb-2"
                                                     style="width: 42px; height: 42px; background-color: #fee2e2; border: 3px solid #dc2626;">
                                                    <i class="bi bi-x-lg text-danger fw-bold"></i>
                                                </div>
                                            </c:when>
                                            <c:when test="${stage.status == 'CHANGES_REQUESTED'}">
                                                <div class="rounded-circle d-inline-flex align-items-center justify-content-center mx-auto mb-2"
                                                     style="width: 42px; height: 42px; background-color: #ffedd5; border: 3px solid #ea580c;">
                                                    <i class="bi bi-arrow-repeat text-warning fw-bold"></i>
                                                </div>
                                            </c:when>
                                            <c:when test="${stage.status == 'IN_PROGRESS' or stage.status == 'PENDING_APPROVAL'}">
                                                <div class="rounded-circle d-inline-flex align-items-center justify-content-center mx-auto mb-2"
                                                     style="width: 42px; height: 42px; background-color: #e0f2fe; border: 3px solid #2563eb; animation: pulse 2s infinite;">
                                                    <i class="bi bi-hourglass-split text-primary fw-bold"></i>
                                                </div>
                                            </c:when>
                                            <c:otherwise>
                                                <div class="rounded-circle d-inline-flex align-items-center justify-content-center mx-auto mb-2"
                                                     style="width: 42px; height: 42px; background-color: #f1f5f9; border: 3px solid #cbd5e1;">
                                                    <span class="text-muted small fw-bold">${stage.stageOrder}</span>
                                                </div>
                                            </c:otherwise>
                                        </c:choose>
                                        <div class="small fw-semibold">${stage.stageName}</div>
                                        <div class="text-muted" style="font-size: 0.7rem;">
                                            <c:if test="${stage.assignedUser != null}">
                                                ${stage.assignedUser.firstName} ${stage.assignedUser.lastName}
                                            </c:if>
                                        </div>
                                        <span class="badge-status status-${stage.status}" style="font-size: 0.65rem;">${stage.status}</span>
                                    </div>
                                </c:forEach>
                            </div>
                        </div>
                    </div>
                </div>
            </c:if>

            <!-- ========================= -->
            <!-- Approval Actions Section  -->
            <!-- ========================= -->
            <c:if test="${canApproveCurrentStage and currentStage != null}">
                <div class="card card-custom shadow-sm mb-4 border-primary border-2">
                    <div class="card-header bg-primary bg-opacity-10 py-3">
                        <h6 class="fw-bold text-primary mb-0">
                            <i class="bi bi-shield-check me-2"></i>Approval Action Required — Stage: ${currentStage.stageName}
                        </h6>
                    </div>
                    <div class="card-body">
                        <p class="text-muted small mb-3">Review the request details above and take an action below. A comment is required for rejection or requesting changes.</p>
                        <div class="row g-3">
                            <!-- Approve -->
                            <div class="col-md-4">
                                <form action="${pageContext.request.contextPath}/approvals/${currentStage.id}/approve" method="post">
                                    <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}" />
                                    <div class="mb-2">
                                        <textarea class="form-control form-control-sm" name="comments" rows="2" placeholder="Optional approval comments..."></textarea>
                                    </div>
                                    <button type="submit" class="btn btn-success w-100 fw-semibold">
                                        <i class="bi bi-check-circle-fill me-1"></i> Approve
                                    </button>
                                </form>
                            </div>
                            <!-- Request Changes -->
                            <div class="col-md-4">
                                <form action="${pageContext.request.contextPath}/approvals/${currentStage.id}/request-changes" method="post">
                                    <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}" />
                                    <div class="mb-2">
                                        <textarea class="form-control form-control-sm" name="comments" rows="2" placeholder="What changes are needed?..." required></textarea>
                                    </div>
                                    <button type="submit" class="btn btn-warning w-100 fw-semibold">
                                        <i class="bi bi-arrow-repeat me-1"></i> Request Changes
                                    </button>
                                </form>
                            </div>
                            <!-- Reject -->
                            <div class="col-md-4">
                                <form action="${pageContext.request.contextPath}/approvals/${currentStage.id}/reject" method="post">
                                    <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}" />
                                    <div class="mb-2">
                                        <textarea class="form-control form-control-sm" name="comments" rows="2" placeholder="Reason for rejection..." required></textarea>
                                    </div>
                                    <button type="submit" class="btn btn-danger w-100 fw-semibold">
                                        <i class="bi bi-x-circle-fill me-1"></i> Reject
                                    </button>
                                </form>
                            </div>
                        </div>
                    </div>
                </div>
            </c:if>

            <!-- ========================= -->
            <!-- Creator Actions Section   -->
            <!-- ========================= -->
            <c:if test="${isCreator}">
                <div class="card card-custom shadow-sm mb-4">
                    <div class="card-header bg-white py-3">
                        <h6 class="fw-bold text-dark mb-0"><i class="bi bi-pencil-square me-2"></i>Your Actions</h6>
                    </div>
                    <div class="card-body">

                        <%-- DRAFT actions --%>
                        <c:if test="${request.status == 'DRAFT'}">
                            <div class="d-flex flex-wrap gap-2 align-items-center mb-3">
                                <a href="${pageContext.request.contextPath}/requests/${request.id}/edit" class="btn btn-outline-secondary">
                                    <i class="bi bi-pencil me-1"></i> Edit Request
                                </a>
                                <form action="${pageContext.request.contextPath}/requests/${request.id}/submit" method="post" class="d-inline">
                                    <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}" />
                                    <button type="submit" class="btn btn-primary fw-semibold">
                                        <i class="bi bi-send-fill me-1"></i> Submit into Workflow
                                    </button>
                                </form>
                            </div>
                        </c:if>

                        <%-- CHANGES_REQUESTED actions --%>
                        <c:if test="${request.status == 'CHANGES_REQUESTED'}">
                            <div class="mb-3">
                                <a href="${pageContext.request.contextPath}/requests/${request.id}/edit" class="btn btn-outline-secondary me-2">
                                    <i class="bi bi-pencil me-1"></i> Edit &amp; Resubmit
                                </a>
                            </div>
                            <form action="${pageContext.request.contextPath}/requests/${request.id}/resubmit" method="post">
                                <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}" />
                                <div class="mb-2">
                                    <label for="resubmitRemarks" class="form-label fw-semibold small">Remarks (describe changes made)</label>
                                    <textarea class="form-control form-control-sm" id="resubmitRemarks" name="remarks" rows="2"
                                              placeholder="Describe what was changed or corrected..."></textarea>
                                </div>
                                <button type="submit" class="btn btn-primary fw-semibold">
                                    <i class="bi bi-arrow-clockwise me-1"></i> Resubmit for Approval
                                </button>
                            </form>
                            <hr>
                        </c:if>

                        <%-- Cancel action (not COMPLETED or CANCELLED) --%>
                        <c:if test="${request.status != 'COMPLETED' and request.status != 'CANCELLED'}">
                            <form action="${pageContext.request.contextPath}/requests/${request.id}/cancel" method="post" class="mt-2">
                                <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}" />
                                <div class="mb-2">
                                    <label for="cancelReason" class="form-label fw-semibold small text-danger">Cancel Request</label>
                                    <textarea class="form-control form-control-sm" id="cancelReason" name="reason" rows="2"
                                              placeholder="Reason for cancellation..." required></textarea>
                                </div>
                                <button type="submit" class="btn btn-outline-danger btn-sm"
                                        onclick="return confirm('Are you sure you want to cancel this request? This action cannot be undone.');">
                                    <i class="bi bi-x-octagon me-1"></i> Cancel Request
                                </button>
                            </form>
                        </c:if>

                    </div>
                </div>
            </c:if>

            <!-- ========================= -->
            <!-- Approval Timeline/History -->
            <!-- ========================= -->
            <div class="card card-custom shadow-sm mb-4">
                <div class="card-header bg-white py-3">
                    <h6 class="fw-bold text-dark mb-0"><i class="bi bi-clock-history me-2"></i>Approval Timeline</h6>
                </div>
                <div class="card-body">
                    <c:choose>
                        <c:when test="${empty history}">
                            <div class="text-center py-4 text-muted">
                                <i class="bi bi-clock fs-2 d-block mb-2 text-secondary"></i>
                                No approval actions yet.
                            </div>
                        </c:when>
                        <c:otherwise>
                            <div class="position-relative ps-4">
                                <!-- Vertical timeline line -->
                                <div class="position-absolute" style="left: 15px; top: 0; bottom: 0; width: 2px; background: #e2e8f0;"></div>

                                <c:forEach items="${history}" var="entry">
                                    <div class="d-flex mb-4 position-relative">
                                        <!-- Timeline dot -->
                                        <c:choose>
                                            <c:when test="${entry.action == 'APPROVED' or entry.action == 'COMPLETED'}">
                                                <div class="position-absolute rounded-circle d-flex align-items-center justify-content-center"
                                                     style="left: -25px; top: 2px; width: 28px; height: 28px; background: #dcfce7; border: 2px solid #16a34a; z-index: 1;">
                                                    <i class="bi bi-check-lg text-success" style="font-size: 0.75rem;"></i>
                                                </div>
                                            </c:when>
                                            <c:when test="${entry.action == 'REJECTED'}">
                                                <div class="position-absolute rounded-circle d-flex align-items-center justify-content-center"
                                                     style="left: -25px; top: 2px; width: 28px; height: 28px; background: #fee2e2; border: 2px solid #dc2626; z-index: 1;">
                                                    <i class="bi bi-x-lg text-danger" style="font-size: 0.75rem;"></i>
                                                </div>
                                            </c:when>
                                            <c:when test="${entry.action == 'CHANGES_REQUESTED'}">
                                                <div class="position-absolute rounded-circle d-flex align-items-center justify-content-center"
                                                     style="left: -25px; top: 2px; width: 28px; height: 28px; background: #ffedd5; border: 2px solid #ea580c; z-index: 1;">
                                                    <i class="bi bi-arrow-repeat text-warning" style="font-size: 0.75rem;"></i>
                                                </div>
                                            </c:when>
                                            <c:when test="${entry.action == 'SUBMITTED' or entry.action == 'RESUBMITTED'}">
                                                <div class="position-absolute rounded-circle d-flex align-items-center justify-content-center"
                                                     style="left: -25px; top: 2px; width: 28px; height: 28px; background: #dbeafe; border: 2px solid #2563eb; z-index: 1;">
                                                    <i class="bi bi-send text-primary" style="font-size: 0.75rem;"></i>
                                                </div>
                                            </c:when>
                                            <c:otherwise>
                                                <div class="position-absolute rounded-circle d-flex align-items-center justify-content-center"
                                                     style="left: -25px; top: 2px; width: 28px; height: 28px; background: #f1f5f9; border: 2px solid #94a3b8; z-index: 1;">
                                                    <i class="bi bi-circle text-muted" style="font-size: 0.75rem;"></i>
                                                </div>
                                            </c:otherwise>
                                        </c:choose>

                                        <!-- Timeline content -->
                                        <div class="ms-3 flex-fill">
                                            <div class="d-flex justify-content-between align-items-start">
                                                <div>
                                                    <span class="fw-semibold">${entry.actionBy.firstName} ${entry.actionBy.lastName}</span>
                                                    <c:choose>
                                                        <c:when test="${entry.action == 'APPROVED'}">
                                                            <span class="badge bg-success ms-1">Approved</span>
                                                        </c:when>
                                                        <c:when test="${entry.action == 'REJECTED'}">
                                                            <span class="badge bg-danger ms-1">Rejected</span>
                                                        </c:when>
                                                        <c:when test="${entry.action == 'CHANGES_REQUESTED'}">
                                                            <span class="badge bg-warning text-dark ms-1">Changes Requested</span>
                                                        </c:when>
                                                        <c:when test="${entry.action == 'SUBMITTED'}">
                                                            <span class="badge bg-primary ms-1">Submitted</span>
                                                        </c:when>
                                                        <c:when test="${entry.action == 'RESUBMITTED'}">
                                                            <span class="badge bg-info text-dark ms-1">Resubmitted</span>
                                                        </c:when>
                                                        <c:when test="${entry.action == 'COMPLETED'}">
                                                            <span class="badge bg-success ms-1">Completed</span>
                                                        </c:when>
                                                        <c:when test="${entry.action == 'CANCELLED'}">
                                                            <span class="badge bg-secondary ms-1">Cancelled</span>
                                                        </c:when>
                                                        <c:otherwise>
                                                            <span class="badge bg-secondary ms-1">${entry.action}</span>
                                                        </c:otherwise>
                                                    </c:choose>
                                                </div>
                                                <small class="text-muted">${entry.timestamp}</small>
                                            </div>
                                            <c:if test="${not empty entry.stageName}">
                                                <div class="small text-muted mt-1">
                                                    <i class="bi bi-diagram-3 me-1"></i>Stage: ${entry.stageName}
                                                </div>
                                            </c:if>
                                            <c:if test="${not empty entry.comments}">
                                                <div class="bg-light rounded p-2 mt-1 small">
                                                    <i class="bi bi-chat-left-quote me-1 text-muted"></i>${entry.comments}
                                                </div>
                                            </c:if>
                                        </div>
                                    </div>
                                </c:forEach>
                            </div>
                        </c:otherwise>
                    </c:choose>
                </div>
            </div>

        </div>

        <!-- ============================================================ -->
        <!-- RIGHT COLUMN: Comments                                        -->
        <!-- ============================================================ -->
        <div class="col-lg-4">

            <!-- Comments Card -->
            <div class="card card-custom shadow-sm mb-4">
                <div class="card-header bg-white py-3">
                    <h6 class="fw-bold text-dark mb-0">
                        <i class="bi bi-chat-dots me-2"></i>Comments
                        <c:if test="${not empty comments}">
                            <span class="badge bg-secondary ms-1">${comments.size()}</span>
                        </c:if>
                    </h6>
                </div>
                <div class="card-body" style="max-height: 500px; overflow-y: auto;">
                    <c:choose>
                        <c:when test="${empty comments}">
                            <div class="text-center py-4 text-muted">
                                <i class="bi bi-chat fs-2 d-block mb-2 text-secondary"></i>
                                <span class="small">No comments yet. Be the first to comment.</span>
                            </div>
                        </c:when>
                        <c:otherwise>
                            <c:forEach items="${comments}" var="comment">
                                <div class="d-flex mb-3">
                                    <div class="flex-shrink-0">
                                        <div class="rounded-circle bg-primary-subtle text-primary d-flex align-items-center justify-content-center"
                                             style="width: 36px; height: 36px; font-size: 0.85rem; font-weight: 600;">
                                            ${comment.user.firstName.charAt(0)}${comment.user.lastName.charAt(0)}
                                        </div>
                                    </div>
                                    <div class="flex-grow-1 ms-2">
                                        <div class="bg-light rounded p-2">
                                            <div class="d-flex justify-content-between align-items-center mb-1">
                                                <span class="fw-semibold small">${comment.user.firstName} ${comment.user.lastName}</span>
                                                <small class="text-muted" style="font-size: 0.7rem;">${comment.createdAt}</small>
                                            </div>
                                            <p class="mb-0 small">${comment.content}</p>
                                        </div>
                                    </div>
                                </div>
                            </c:forEach>
                        </c:otherwise>
                    </c:choose>
                </div>
                <div class="card-footer bg-white">
                    <form action="${pageContext.request.contextPath}/requests/${request.id}/comment" method="post">
                        <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}" />
                        <div class="input-group">
                            <textarea class="form-control form-control-sm" name="content" rows="2"
                                      placeholder="Write a comment..." required style="resize: none;"></textarea>
                            <button type="submit" class="btn btn-primary btn-sm px-3">
                                <i class="bi bi-send"></i>
                            </button>
                        </div>
                    </form>
                </div>
            </div>

            <!-- Quick Info Summary Card -->
            <div class="card card-custom shadow-sm">
                <div class="card-header bg-white py-3">
                    <h6 class="fw-bold text-dark mb-0"><i class="bi bi-lightning me-2"></i>Quick Summary</h6>
                </div>
                <ul class="list-group list-group-flush">
                    <li class="list-group-item d-flex justify-content-between small">
                        <span class="text-muted">Total Stages</span>
                        <span class="fw-bold">${not empty allStages ? allStages.size() : 0}</span>
                    </li>
                    <li class="list-group-item d-flex justify-content-between small">
                        <span class="text-muted">Current Stage</span>
                        <span class="fw-bold">${currentStage != null ? currentStage.stageName : 'N/A'}</span>
                    </li>
                    <li class="list-group-item d-flex justify-content-between small">
                        <span class="text-muted">History Events</span>
                        <span class="fw-bold">${not empty history ? history.size() : 0}</span>
                    </li>
                    <li class="list-group-item d-flex justify-content-between small">
                        <span class="text-muted">Your Role</span>
                        <span class="fw-bold">
                            <c:choose>
                                <c:when test="${isCreator and canApproveCurrentStage}">Creator & Approver</c:when>
                                <c:when test="${isCreator}">Creator</c:when>
                                <c:when test="${canApproveCurrentStage}">Approver</c:when>
                                <c:otherwise>Viewer</c:otherwise>
                            </c:choose>
                        </span>
                    </li>
                </ul>
            </div>

        </div>
    </div>

</main>

<style>
    @keyframes pulse {
        0% { box-shadow: 0 0 0 0 rgba(37, 99, 235, 0.4); }
        70% { box-shadow: 0 0 0 8px rgba(37, 99, 235, 0); }
        100% { box-shadow: 0 0 0 0 rgba(37, 99, 235, 0); }
    }
</style>

<jsp:include page="../fragments/footer.jsp" />
