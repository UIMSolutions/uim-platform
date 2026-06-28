/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.credential_store.application.usecases.get.audit_logs;
// import uim.platform.credential_store.domain.ports.repositories.audit_logs;
// import uim.platform.credential_store.domain.entities.audit_log_entry;

// import uim.platform.credential_store.application.dto;
import uim.platform.credential_store;

// mixin(ShowModule!());

@safe:
class GetAuditLogsUseCase { // TODO: UIMUseCase {
  private AuditLogRepository repo;

  this(AuditLogRepository repo) {
    this.repo = repo;
  }

  AuditLogEntry[] listLogs(TenantId tenantId) {
    return repo.find(tenantId);
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
    return repo.count(tenantId);
  }

}
