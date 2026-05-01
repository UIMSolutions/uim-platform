/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.credential_store.infrastructure.persistence.memory.audit_logs;

// import uim.platform.credential_store.domain.entities.audit_log_entry;
// import uim.platform.credential_store.domain.ports.repositories.audit_logs;
// import uim.platform.credential_store.domain.types;
// 
// import std.algorithm : filter;
// import std.array : array;

import uim.platform.credential_store;

mixin(ShowModule!());

@safe:
class MemoryAuditLogRepository : MemoryTenantRepository!(AuditLogEntry, AuditLogEntryId), AuditLogRepository {
  AuditLogEntry[] findByNamespace(TenantId tenantId, NamespaceId namespaceId) {
    return findByTenant(tenantId).filter!(e => e.namespaceId == namespaceId).array;
  }

  AuditLogEntry[] findByResourceType(TenantId tenantId, ResourceType resourceType) {
    return findByTenant(tenantId).filter!(e => e.resourceType == resourceType).array;
  }

  AuditLogEntry[] findByTimeRange(TenantId tenantId, long startTime, long endTime) {
    return findByTenant(tenantId).filter!(e => e.timestamp >= startTime && e.timestamp <= endTime)
      .array;
  }

}
