<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="pageTitle" value="Access Denied — FlowSphere" />
<jsp:include page="fragments/header.jsp" />
<jsp:include page="fragments/sidebar.jsp" />

<main class="col-md-9 ms-sm-auto col-lg-10 px-md-4 py-5">
    <div class="text-center py-5">
        <div class="d-inline-flex p-4 rounded-circle bg-danger-subtle text-danger mb-4 shadow-sm">
            <i class="bi bi-shield-x fs-1"></i>
        </div>
        <h1 class="h2 fw-bold text-dark">403 — Access Denied</h1>
        <p class="text-muted fs-6 mb-4 col-md-6 mx-auto">
            You do not have permission to view or execute actions on this resource. 
            Ensure you are logged in with the appropriate role (Manager, Department Head, IT Processor, or Super Admin).
        </p>
        <a href="${pageContext.request.contextPath}/dashboard" class="btn btn-primary px-4 py-2">
            <i class="bi bi-arrow-left me-2"></i> Return to Dashboard
        </a>
    </div>
</main>

<jsp:include page="fragments/footer.jsp" />
