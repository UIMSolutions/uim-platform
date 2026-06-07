/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.marketrates.application.usecases.manage.audit_logs;
import uim.platform.marketrates;

// mixin(ShowModule!());

@safe:

class ManageAuditLogsUseCase {
  private AuditLogRepository repo;

  this(AuditLogRepository repo) {
    this.repo = repo;
  }

  AuditLog[] list(TenantId tenantId) {
    return repo.findByTenant(tenantId);
  }

  AuditLog[] listByOperation(TenantId tenantId, AuditOperation op) {
    return repo.findByOperation(tenantId, op);
  }

  AuditLog[] listByProvider(TenantId tenantId, string providerCode) {
    return repo.findByProvider(tenantId, providerCode);
  }

  AuditLog[] listByStatus(TenantId tenantId, OperationStatus status) {
    return repo.findByStatus(tenantId, status);
  }

  AuditLog getById(TenantId tenantId, AuditLogId id) {
    return repo.findById(tenantId, id);
  }
}
