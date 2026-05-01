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
class MemoryAuditLogRepository : TenantRepository!(AuditLogEntry, AuditLogEntryId), AuditLogRepository {

  size_t countByNamespace(TenantId tenantId, NamespaceId namespaceId) {
    return findByNamespace(tenantId, namespaceId).length;
  }
  AuditLogEntry[] findByNamespace(TenantId tenantId, NamespaceId namespaceId) {
    return findByTenant(tenantId).filter!(e => e.namespaceId == namespaceId).array;
  }
  void removeByNamespace(TenantId tenantId, NamespaceId namespaceId) {
    findByNamespace(tenantId, namespaceId).each!(e => remove(e));
  }

  size_t countByResourceType(TenantId tenantId, ResourceType resourceType) {
    return findByResourceType(tenantId, resourceType).length;
  }
  AuditLogEntry[] findByResourceType(TenantId tenantId, ResourceType resourceType) {
    return findByTenant(tenantId).filter!(e => e.resourceType == resourceType).array;
  }
  void removeByResourceType(TenantId tenantId, ResourceType resourceType) {
    findByResourceType(tenantId, resourceType).each!(e => remove(e));
  }

  size_t countByTimeRange(TenantId tenantId, long startTime, long endTime) {
    return findByTimeRange(tenantId, startTime, endTime).length;
  }
  AuditLogEntry[] findByTimeRange(TenantId tenantId, long startTime, long endTime) {
    return findByTenant(tenantId).filter!(e => e.timestamp >= startTime && e.timestamp <= endTime)
      .array;
  }
  void removeByTimeRange(TenantId tenantId, long startTime, long endTime) {
    findByTimeRange(tenantId, startTime, endTime).each!(e => remove(e));
  }

}
