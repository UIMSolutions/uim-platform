/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.auditlog.application.usecases.retrieve_audit_logs;

// import uim.platform.auditlog.domain.types;
// import uim.platform.auditlog.domain.entities.audit_log_entry;
// import uim.platform.auditlog.domain.ports.repositories.audit_logs;
// import uim.platform.auditlog.application.dto;

import uim.platform.auditlog; 

mixin(ShowModule!());

@safe:
class RetrieveAuditLogsUseCase : UIMUseCase {
  private AuditLogRepository repo;

  this(AuditLogRepository repo) {
    this.repo = repo;
  }

  AuditLogEntry[] query(AuditLogQueryRequest req) {
    return repo.search(req.tenantId, req.categories, req.timeFrom, req.timeTo,
        req.limit, req.offset);
  }

  bool hasById(AuditLogId id, TenantId tenantId) {
    return repo.existsById(id, tenantId);
  }

  AuditLogEntry getById(AuditLogId id, TenantId tenantId) {
    return repo.findById(id, tenantId);
  }

  AuditLogEntry[] getByCategory(TenantId tenantId, AuditCategory category) {
    return repo.findByCategory(tenantId, category);
  }

  AuditLogEntry[] getByUser(TenantId tenantId, UserId userId) {
    return repo.findByUser(tenantId, userId);
  }

  AuditLogEntry[] getByCorrelation(string correlationId) {
    return repo.findByCorrelation(correlationId);
  }

  long count(TenantId tenantId) {
    return repo.countByTenant(tenantId);
  }
}
