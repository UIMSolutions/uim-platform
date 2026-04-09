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
  private AuditLogRepository repository;

  this(AuditLogRepository repository) {
    this.repository = repository;
  }

  AuditLogEntry[] query(AuditLogQueryRequest req) {
    return repository.search(req.tenantId, req.categories, req.timeFrom, req.timeTo,
        req.limit, req.offset);
  }

  bool existsById(TenantId tenantId, AuditLogId id) {
    return repository.existsById(tenantId, id);
  }

  AuditLogEntry getById(TenantId tenantId, AuditLogId id) {
    return repository.findById(tenantId, id);
  }

  AuditLogEntry[] getByCategory(TenantId tenantId, AuditCategory category) {
    return repository.findByCategory(tenantId, category);
  }

  AuditLogEntry[] getByUser(TenantId tenantId, UserId userId) {
    return repository.findByUser(tenantId, userId);
  }

  AuditLogEntry[] getByCorrelation(TenantId tenantId, string correlationId) {
    return repository.findByCorrelation(tenantId, correlationId);
  }

  size_t count(TenantId tenantId) {
    return repository.countByTenant(tenantId);
  }
}
