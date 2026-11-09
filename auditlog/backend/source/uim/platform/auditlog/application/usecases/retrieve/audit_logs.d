/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.auditlog.application.usecases.retrieve.audit_logs;
import uim.platform.auditlog; 
mixin(ShowModule!());

@safe:
/// Interactor: read access to audit log entries.
class RetrieveAuditLogsUseCase : IRetrieveAuditLogsUseCase {
  protected IAuditLogRepository repository;

  this(IAuditLogRepository repository) {
    this.repository = repository;
  }

  AuditLogEntry[] queryAuditLogs(AuditLogQueryRequest req) {
    return repository.search(req.tenantId, req.categories, req.timeFrom, req.timeTo,
        req.limit, req.offset);
  }

  bool hasAuditLog(TenantId tenantId, AuditLogId id) {
    return repository.existsById(tenantId, id);
  }

  AuditLogEntry getAuditLog(TenantId tenantId, AuditLogId id) {
    return repository.findById(tenantId, id);
  }

  AuditLogEntry[] listAuditLogs(TenantId tenantId, AuditCategory category) {
    return repository.findByCategory(tenantId, category);
  }

  AuditLogEntry[] listAuditLogs(TenantId tenantId, UserId userId) {
    return repository.findByUser(tenantId, userId);
  }

  AuditLogEntry[] listAuditLogs(TenantId tenantId, string correlationId) {
    return repository.findByCorrelation(tenantId, correlationId);
  }

  size_t countAuditLogs(TenantId tenantId) {
    return repository.countByTenant(tenantId);
  }
}

///
unittest {
  mixin(ShowTest!("RetrieveAuditLogsUseCase"));

  auto repo = new AuditLogRepository();
  auto tenant = TenantId("t1");
  foreach (i; 0 .. 3) {
    auto e = AuditLogEntry(tenant);
    e.category = i == 0 ? AuditCategory.dataAccess : AuditCategory.configuration;
    e.timestamp = e.createdAt + i;
    repo.save(e);
  }
  auto uc = new RetrieveAuditLogsUseCase(repo);
  assert(uc.countAuditLogs(tenant) == 3);
  assert(uc.listAuditLogs(tenant, AuditCategory.configuration).length == 2);

  AuditLogQueryRequest q;
  q.tenantId = tenant;
  q.limit = 2;
  assert(uc.queryAuditLogs(q).length == 2);
}
