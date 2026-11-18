<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<c:set var="activePage" value="notifications" />
<c:set var="pageTitle" value="Notifications — FlowSphere" />
<jsp:include page="../fragments/header.jsp" />
<jsp:include page="../fragments/sidebar.jsp" />

<main class="col-md-9 ms-sm-auto col-lg-10 px-md-4 py-4">
    <div class="d-flex justify-content-between flex-wrap flex-md-nowrap align-items-center pt-2 pb-3 mb-3 border-bottom">
        <div>
            <h1 class="h3 fw-bold mb-1"><i class="bi bi-bell me-2 text-primary"></i>Notifications</h1>
            <p class="text-muted small mb-0">Stay updated on your workflow activities</p>
        </div>
        <div>
            <c:if test="${not empty notifications}">
                <form action="${pageContext.request.contextPath}/notifications/read-all" method="post" class="d-inline">
                    <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}" />
                    <button type="submit" class="btn btn-outline-primary btn-sm d-flex align-items-center shadow-sm">
                        <i class="bi bi-check2-all me-2"></i> Mark All Read
                    </button>
                </form>
            </c:if>
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

    <!-- Notifications List -->
    <c:choose>
        <c:when test="${empty notifications}">
            <div class="card card-custom shadow-sm">
                <div class="card-body text-center py-5 text-muted">
                    <i class="bi bi-bell-slash fs-2 d-block mb-2 text-secondary"></i>
                    No notifications yet. You'll be notified when there are updates.
                </div>
            </div>
        </c:when>
        <c:otherwise>
            <div class="d-flex flex-column gap-3">
                <c:forEach items="${notifications}" var="notification">
                    <div class="card card-custom shadow-sm ${!notification.read ? 'border-start border-primary border-4' : ''}">
                        <div class="card-body py-3">
                            <div class="d-flex justify-content-between align-items-start">
                                <div class="flex-grow-1">
                                    <div class="d-flex align-items-center mb-1">
                                        <c:choose>
                                            <c:when test="${!notification.read}">
                                                <i class="bi bi-circle-fill text-primary me-2" style="font-size: 0.5rem;"></i>
                                            </c:when>
                                            <c:otherwise>
                                                <i class="bi bi-circle text-muted me-2" style="font-size: 0.5rem;"></i>
                                            </c:otherwise>
                                        </c:choose>
                                        <h6 class="fw-bold mb-0 ${!notification.read ? 'text-dark' : 'text-muted'}">${notification.title}</h6>
                                    </div>
                                    <p class="mb-1 small ${!notification.read ? 'text-body' : 'text-muted'} ms-3">${notification.message}</p>
                                    <div class="ms-3">
                                        <small class="text-muted">
                                            <i class="bi bi-clock me-1"></i>${notification.createdAt}
                                        </small>
                                    </div>
                                </div>
                                <c:if test="${!notification.read}">
                                    <form action="${pageContext.request.contextPath}/notifications/${notification.id}/read" method="post" class="ms-3">
                                        <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}" />
                                        <button type="submit" class="btn btn-outline-secondary btn-sm" title="Mark as read">
                                            <i class="bi bi-check2"></i>
                                        </button>
                                    </form>
                                </c:if>
                            </div>
                        </div>
                    </div>
                </c:forEach>
            </div>
        </c:otherwise>
    </c:choose>
</main>

<jsp:include page="../fragments/footer.jsp" />
