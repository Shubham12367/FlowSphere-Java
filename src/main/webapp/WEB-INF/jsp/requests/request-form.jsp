<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="activePage" value="new-request" />
<c:set var="pageTitle" value="Create Request — FlowSphere" />
<jsp:include page="../fragments/header.jsp" />
<jsp:include page="../fragments/sidebar.jsp" />

<main class="col-md-9 ms-sm-auto col-lg-10 px-md-4 py-4">
    <div class="d-flex justify-content-between flex-wrap flex-md-nowrap align-items-center pt-2 pb-3 mb-3 border-bottom">
        <div>
            <h1 class="h3 fw-bold mb-1">Submit New Workflow Request</h1>
            <p class="text-muted small mb-0">Fill in the details below to initiate a multi-stage approval workflow</p>
        </div>
        <a href="${pageContext.request.contextPath}/requests" class="btn btn-outline-secondary btn-sm">
            <i class="bi bi-arrow-left me-1"></i> Back to Requests
        </a>
    </div>

    <c:if test="${not empty errorMessage}">
        <div class="alert alert-danger py-2 small" role="alert">
            <i class="bi bi-exclamation-triangle-fill me-2"></i> ${errorMessage}
        </div>
    </c:if>

    <div class="card card-custom p-4 shadow-sm col-lg-9 col-xl-8 mx-auto">
        <form action="${pageContext.request.contextPath}/requests/new" method="post">
            <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}" />

            <div class="mb-3">
                <label for="title" class="form-label fw-semibold">Request Title <span class="text-danger">*</span></label>
                <input type="text" class="form-control" id="title" name="title" 
                       placeholder="e.g. Developer Laptop &amp; Cloud Sandbox Access" required autofocus />
                <div class="form-text">A concise summary of what is being requested.</div>
            </div>

            <div class="row g-3 mb-3">
                <div class="col-md-6">
                    <label for="requestType" class="form-label fw-semibold">Workflow Category / Department Process <span class="text-danger">*</span></label>
                    <select class="form-select" id="requestType" name="requestType" required>
                        <c:choose>
                            <c:when test="${not empty definitions}">
                                <c:forEach items="${definitions}" var="def">
                                    <option value="${def.name}">${def.name} (${def.category})</option>
                                </c:forEach>
                            </c:when>
                            <c:otherwise>
                                <option value="Standard IT &amp; Equipment Request">Standard IT &amp; Equipment Request (IT_SERVICE)</option>
                                <option value="Software License &amp; Cloud Sandbox Access">Software License &amp; Cloud Sandbox Access (IT_SOFTWARE)</option>
                                <option value="Expense Reimbursement &amp; Travel Claim">Expense Reimbursement &amp; Travel Claim (FINANCE)</option>
                                <option value="Leave &amp; Work-From-Home Application">Leave &amp; Work-From-Home Application (HUMAN_RESOURCES)</option>
                                <option value="Procurement &amp; Vendor Purchase Order">Procurement &amp; Vendor Purchase Order (OPERATIONS)</option>
                            </c:otherwise>
                        </c:choose>
                    </select>
                    <div class="form-text">Directs your request into the appropriate multi-tier review channel.</div>
                </div>

                <div class="col-md-6">
                    <label for="priority" class="form-label fw-semibold">Priority &amp; Urgency</label>
                    <select class="form-select" id="priority" name="priority">
                        <c:forEach items="${priorities}" var="p">
                            <option value="${p}" ${p == 'MEDIUM' ? 'selected' : ''}>${p}</option>
                        </c:forEach>
                    </select>
                    <div class="form-text">Urgent/High requests are highlighted in approver queues.</div>
                </div>
            </div>

            <div class="mb-3">
                <label for="description" class="form-label fw-semibold">Business Justification &amp; Purpose <span class="text-danger">*</span></label>
                <textarea class="form-control" id="description" name="description" rows="3" 
                          placeholder="Explain why this request is required, the project it supports, and impact..." required></textarea>
            </div>

            <!-- Structured Business Specifications (Replacing Raw JSON) -->
            <div class="card bg-light border-0 p-3 mb-4 rounded-3">
                <h6 class="fw-bold text-dark mb-2"><i class="bi bi-card-checklist me-2 text-primary"></i>Request Specifications &amp; Details</h6>
                <div class="row g-2">
                    <div class="col-md-6">
                        <label for="itemDetails" class="form-label small fw-semibold text-secondary">Specific Item / Software / Service Requested</label>
                        <input type="text" class="form-control form-control-sm" id="itemDetails" name="itemDetails" 
                               placeholder="e.g. MacBook Pro M3, JetBrains All Products Pack, AWS Sandbox" />
                    </div>
                    <div class="col-md-3">
                        <label for="estimatedCost" class="form-label small fw-semibold text-secondary">Estimated Amount (₹ / $)</label>
                        <input type="text" class="form-control form-control-sm" id="estimatedCost" name="estimatedCost" 
                               placeholder="e.g. 85000" />
                    </div>
                    <div class="col-md-3">
                        <label for="targetDate" class="form-label small fw-semibold text-secondary">Target / Due Date</label>
                        <input type="date" class="form-control form-control-sm" id="targetDate" name="targetDate" />
                    </div>
                    <div class="col-12 mt-2">
                        <label for="fieldValuesJson" class="form-label small fw-semibold text-secondary">Additional Notes / Vendor / Justification URL (Optional)</label>
                        <input type="text" class="form-control form-control-sm" id="fieldValuesJson" name="fieldValuesJson" 
                               placeholder="e.g. Quote #1042 attached, needed for Sprint 24 development" />
                    </div>
                </div>
            </div>

            <hr class="my-4">

            <div class="d-flex justify-content-end gap-2">
                <button type="submit" name="submitNow" value="false" class="btn btn-outline-secondary px-3">
                    <i class="bi bi-save me-1"></i> Save as Draft
                </button>
                <button type="submit" name="submitNow" value="true" class="btn btn-primary px-4 fw-semibold shadow-sm">
                    <i class="bi bi-send-fill me-1"></i> Submit into Workflow
                </button>
            </div>
        </form>
    </div>
</main>

<jsp:include page="../fragments/footer.jsp" />
