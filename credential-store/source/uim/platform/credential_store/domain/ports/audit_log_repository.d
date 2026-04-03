/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.credential_store.domain.ports.audit_log_repository;

import uim.platform.credential_store.domain.entities.audit_log_entry;
import uim.platform.credential_store.domain.types;

interface AuditLogRepository {
  AuditLogEntry findById(AuditLogEntryId id);
  AuditLogEntry[] findByTenant(TenantId tenantId);
  AuditLogEntry[] findByNamespace(TenantId tenantId, NamespaceId namespaceId);
  AuditLogEntry[] findByResourceType(TenantId tenantId, ResourceType resourceType);
  AuditLogEntry[] findByTimeRange(TenantId tenantId, long startTime, long endTime);
  void save(AuditLogEntry entry);
  long countByTenant(TenantId tenantId);
}
