<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<c:set var="activePage" value="requests" />
<c:set var="pageTitle" value="Edit Request ${request.requestNumber} — FlowSphere" />
<jsp:include page="../fragments/header.jsp" />
<jsp:include page="../fragments/sidebar.jsp" />

<main class="col-md-9 ms-sm-auto col-lg-10 px-md-4 py-4">

    <!-- Page Header -->
    <div class="d-flex justify-content-between flex-wrap flex-md-nowrap align-items-center pt-2 pb-3 mb-3 border-bottom">
        <div>
            <h1 class="h3 fw-bold mb-1">
                <i class="bi bi-pencil-square me-2 text-primary"></i>Edit Request
            </h1>
            <p class="text-muted small mb-0">
                <span class="font-monospace fw-bold text-primary">${request.requestNumber}</span>
                <span class="mx-2">•</span>
                <span class="badge-status status-${request.status}">${request.status}</span>
            </p>
        </div>
        <a href="${pageContext.request.contextPath}/requests/${request.id}" class="btn btn-outline-secondary btn-sm">
            <i class="bi bi-arrow-left me-1"></i> Back to Request
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

    <!-- Changes Requested Notice -->
    <c:if test="${request.status == 'CHANGES_REQUESTED'}">
        <div class="alert alert-warning py-2 d-flex align-items-center" role="alert">
            <i class="bi bi-exclamation-triangle-fill me-2 fs-5"></i>
            <div>
                <strong>Changes have been requested.</strong> Please update the fields below and save. After saving,
                you can resubmit this request for approval using the form at the bottom of this page.
            </div>
        </div>
        <c:if test="${not empty request.remarks}">
            <div class="alert alert-info py-2 small" role="alert">
                <i class="bi bi-chat-left-text me-2"></i><strong>Reviewer Remarks:</strong> ${request.remarks}
            </div>
        </c:if>
    </c:if>

    <!-- Edit Form Card -->
    <div class="card card-custom p-4 shadow-sm col-lg-9 col-xl-8 mx-auto">
        <form action="${pageContext.request.contextPath}/requests/${request.id}/edit" method="post">
            <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}" />

            <div class="mb-3">
                <label for="title" class="form-label fw-semibold">Request Title <span class="text-danger">*</span></label>
                <input type="text" class="form-control" id="title" name="title"
                       value="${request.title}" placeholder="e.g. Developer Laptop & Cloud Sandbox Access" required autofocus />
                <div class="form-text">A concise summary of what is being requested.</div>
            </div>

            <div class="mb-3">
                <label for="description" class="form-label fw-semibold">Business Justification &amp; Description</label>
                <textarea class="form-control" id="description" name="description" rows="4"
                          placeholder="Explain the business need, project context, or requirements...">${request.description}</textarea>
            </div>

            <div class="mb-3">
                <label for="priority" class="form-label fw-semibold">Priority Level</label>
                <select class="form-select" id="priority" name="priority">
                    <c:forEach items="${priorities}" var="p">
                        <option value="${p}" ${p == request.priority ? 'selected' : ''}>${p}</option>
                    </c:forEach>
                </select>
            </div>

            <div class="mb-4">
                <label for="fieldValuesJson" class="form-label fw-semibold">Specifications &amp; Item Details</label>
                <textarea class="form-control" id="fieldValuesJson" name="fieldValuesJson" rows="3"
                          placeholder="Item details, specifications, estimated cost, due date, vendor notes...">${request.fieldValuesJson}</textarea>
                <div class="form-text">Specifications, item breakdown, or requirements.</div>
            </div>

            <hr class="my-4">

            <div class="d-flex justify-content-between align-items-center">
                <a href="${pageContext.request.contextPath}/requests/${request.id}" class="btn btn-outline-secondary">
                    <i class="bi bi-x-lg me-1"></i> Cancel
                </a>
                <button type="submit" class="btn btn-primary px-4 fw-semibold shadow-sm">
                    <i class="bi bi-save me-1"></i> Save Changes
                </button>
            </div>
        </form>
    </div>

    <!-- Resubmit Section (only for CHANGES_REQUESTED) -->
    <c:if test="${request.status == 'CHANGES_REQUESTED'}">
        <div class="card card-custom p-4 shadow-sm col-lg-9 col-xl-8 mx-auto mt-4 border-warning border-2">
            <div class="d-flex align-items-center mb-3">
                <i class="bi bi-arrow-clockwise text-warning fs-4 me-2"></i>
                <h6 class="fw-bold mb-0">Resubmit for Approval</h6>
            </div>
            <p class="text-muted small mb-3">
                After saving your changes above, use this form to resubmit the request back into the approval workflow.
            </p>
            <form action="${pageContext.request.contextPath}/requests/${request.id}/resubmit" method="post">
                <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}" />
                <div class="mb-3">
                    <label for="resubmitRemarks" class="form-label fw-semibold small">Remarks (describe what was changed)</label>
                    <textarea class="form-control form-control-sm" id="resubmitRemarks" name="remarks" rows="2"
                              placeholder="Describe the corrections or changes made..."></textarea>
                </div>
                <button type="submit" class="btn btn-warning fw-semibold">
                    <i class="bi bi-send-fill me-1"></i> Resubmit Request
                </button>
            </form>
        </div>
    </c:if>

</main>

<jsp:include page="../fragments/footer.jsp" />
