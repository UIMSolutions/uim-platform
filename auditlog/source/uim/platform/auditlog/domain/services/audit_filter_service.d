module uim.platform.auditlog.domain.services.audit_filter_service;

// import uim.platform.auditlog.domain.types;
// import uim.platform.auditlog.domain.entities.audit_log_entry;
// import uim.platform.auditlog.domain.ports.audit_log_repository;

import uim.platform.auditlog;

mixin(ShowModule!());

/// Domain service — provides search and filtering over audit logs.
@safe:
class AuditFilterService
{
  private AuditLogRepository repo;

  this(AuditLogRepository repo)
  {
    this.repo = repo;
  }

  /// Paginated search with optional category and time filters.
  AuditLogEntry[] search(TenantId tenantId, AuditCategory[] categories,
      long timeFrom, long timeTo, int limit, int offset)
  {
    return repo.search(tenantId, categories, timeFrom, timeTo, limit, offset);
  }

  /// Find all entries linked by a correlation id.
  AuditLogEntry[] findCorrelated(string correlationId)
  {
    return repo.findByCorrelation(correlationId);
  }

  /// Count total entries for a tenant.
  long countForTenant(TenantId tenantId)
  {
    return repo.countByTenant(tenantId);
  }
}
