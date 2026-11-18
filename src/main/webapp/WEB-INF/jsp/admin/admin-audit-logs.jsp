<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<c:set var="activePage" value="admin-audit" />
<c:set var="pageTitle" value="Audit Logs — FlowSphere Admin" />
<jsp:include page="../fragments/header.jsp" />
<jsp:include page="../fragments/sidebar.jsp" />

<main class="col-md-9 ms-sm-auto col-lg-10 px-md-4 py-4">
    <!-- Header -->
    <div class="d-flex justify-content-between flex-wrap flex-md-nowrap align-items-center pt-2 pb-3 mb-3 border-bottom">
        <div>
            <h1 class="h3 fw-bold mb-1"><i class="bi bi-journal-text me-2"></i>Audit Logs</h1>
            <p class="text-muted small mb-0">View system-wide activity and audit trail.</p>
        </div>
    </div>

    <!-- Search / Filter -->
    <div class="card card-custom mb-3 shadow-sm">
        <div class="card-body py-2">
            <div class="row align-items-center">
                <div class="col-md-6">
                    <div class="input-group input-group-sm">
                        <span class="input-group-text bg-white border-end-0"><i class="bi bi-search"></i></span>
                        <input type="text" class="form-control border-start-0" id="auditSearchInput"
                               placeholder="Search by user, action, or details..." />
                    </div>
                </div>
                <div class="col-md-6 text-end">
                    <span class="text-muted small" id="auditResultCount">${auditLogs.size()} entries</span>
                </div>
            </div>
        </div>
    </div>

    <!-- Audit Logs Table -->
    <div class="card card-custom mb-4 shadow-sm">
        <div class="card-header bg-white py-3 d-flex justify-content-between align-items-center">
            <h6 class="fw-bold text-dark mb-0">
                <i class="bi bi-clock-history me-2"></i> Activity Log
                <span class="badge bg-primary-subtle text-primary ms-2">${auditLogs.size()}</span>
            </h6>
        </div>
        <div class="table-responsive">
            <table class="table table-hover align-middle mb-0" id="auditTable">
                <thead class="table-light small">
                    <tr>
                        <th style="width: 180px;">Timestamp</th>
                        <th>User</th>
                        <th>Action</th>
                        <th>Details</th>
                    </tr>
                </thead>
                <tbody id="auditTableBody">
                    <c:choose>
                        <c:when test="${empty auditLogs}">
                            <tr>
                                <td colspan="4" class="text-center py-4 text-muted">
                                    <i class="bi bi-journal fs-2 d-block mb-2 text-secondary"></i>
                                    No audit log entries found.
                                </td>
                            </tr>
                        </c:when>
                        <c:otherwise>
                            <c:forEach items="${auditLogs}" var="log">
                                <tr class="audit-row">
                                    <td class="small text-muted font-monospace">
                                        <fmt:formatDate value="${log.timestamp}" pattern="yyyy-MM-dd HH:mm:ss" />
                                    </td>
                                    <td>
                                        <c:choose>
                                            <c:when test="${log.user != null}">
                                                <div class="fw-semibold small">${log.user.firstName} ${log.user.lastName}</div>
                                                <div class="text-muted" style="font-size: 0.75rem;">${log.user.email}</div>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="text-muted fst-italic small">System</span>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td>
                                        <span class="badge bg-dark-subtle text-dark">${log.action}</span>
                                    </td>
                                    <td class="small text-muted">${log.details}</td>
                                </tr>
                            </c:forEach>
                        </c:otherwise>
                    </c:choose>
                </tbody>
            </table>
        </div>
    </div>
</main>

<!-- Client-side search/filter script -->
<script>
document.addEventListener('DOMContentLoaded', function() {
    var searchInput = document.getElementById('auditSearchInput');
    var tableBody = document.getElementById('auditTableBody');
    var resultCount = document.getElementById('auditResultCount');
    var rows = tableBody.querySelectorAll('.audit-row');
    var totalRows = rows.length;

    searchInput.addEventListener('input', function() {
        var filter = this.value.toLowerCase().trim();
        var visibleCount = 0;

        rows.forEach(function(row) {
            var text = row.textContent.toLowerCase();
            if (filter === '' || text.indexOf(filter) > -1) {
                row.style.display = '';
                visibleCount++;
            } else {
                row.style.display = 'none';
            }
        });

        resultCount.textContent = visibleCount + ' of ' + totalRows + ' entries';
    });
});
</script>

<jsp:include page="../fragments/footer.jsp" />
