/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.credential_store.infrastructure.persistence.memory.audit_log_repo;

import uim.platform.credential_store.domain.entities.audit_log_entry;
import uim.platform.credential_store.domain.ports.audit_log_repository;
import uim.platform.credential_store.domain.types;

import std.algorithm : filter;
import std.array : array;

class MemoryAuditLogRepository : AuditLogRepository {
  private AuditLogEntry[] store;

  AuditLogEntry findById(AuditLogEntryId id) {
    foreach (ref e; store)
      if (e.id == id)
        return e;
    return AuditLogEntry.init;
  }

  AuditLogEntry[] findByTenant(TenantId tenantId) {
    return store.filter!(e => e.tenantId == tenantId).array;
  }

  AuditLogEntry[] findByNamespace(TenantId tenantId, NamespaceId namespaceId) {
    return store.filter!(e => e.tenantId == tenantId && e.namespaceId == namespaceId).array;
  }

  AuditLogEntry[] findByResourceType(TenantId tenantId, ResourceType resourceType) {
    return store.filter!(e => e.tenantId == tenantId && e.resourceType == resourceType).array;
  }

  AuditLogEntry[] findByTimeRange(TenantId tenantId, long startTime, long endTime) {
    return store.filter!(e => e.tenantId == tenantId && e.timestamp >= startTime && e.timestamp <= endTime)
      .array;
  }

  void save(AuditLogEntry entry) {
    store ~= entry;
  }

  long countByTenant(TenantId tenantId) {
    return cast(long) store.filter!(e => e.tenantId == tenantId).array.length;
  }
}
