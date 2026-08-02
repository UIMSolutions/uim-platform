/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.credential_store.application.usecases.get.audit_logs;

import uim.platform.credential_store;

mixin(ShowModule!());

@safe:
class GetAuditLogsUseCase { // TODO: UIMUseCase {
  private IAuditLogRepository repo;

  this(IAuditLogRepository repo) {
    this.repo = repo;
  }

  AuditLogEntry[] listLogs(TenantId tenantId) {
    return repo.findByTenant(tenantId);
  }

  AuditLogEntry[] listLogs(TenantId tenantId, NamespaceId namespaceId) {
    return repo.findByNamespace(tenantId, namespaceId);
  }

  AuditLogEntry[] listLogs(TenantId tenantId, string resourceType) {
    return repo.findByResourceType(tenantId, toResourceType(resourceType));
  }

  AuditLogEntry[] listLogs(TenantId tenantId, long startTime, long endTime) {
    return repo.findByTimeRange(tenantId, startTime, endTime);
  }

  AuditLogEntry getLog(TenantId tenantId, AuditLogEntryId id) {
    return repo.findById(tenantId, id);
  }

  size_t countLogs(TenantId tenantId) {
    return repo.countByTenant(tenantId);
  }

}

///
unittest {
    auto repo = new AuditLogRepository();
    auto usecase = new GetAuditLogsUseCase(repo);
    auto tenantId = TenantId("test-tenant");

    // Test list
    auto items = usecase.listLogs(tenantId);
    assert(items !is null);

}
