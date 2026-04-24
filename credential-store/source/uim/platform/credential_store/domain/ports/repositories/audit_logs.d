/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.credential_store.domain.ports.repositories.audit_logs;

import uim.platform.credential_store.domain.entities.audit_log_entry;
import uim.platform.credential_store.domain.types;

interface AuditLogRepository : ITenantRepository!(AuditLogEntry, AuditLogEntryId) {
  AuditLogEntry[] findByNamespace(TenantId tenantId, NamespaceId namespaceId);
  AuditLogEntry[] findByResourceType(TenantId tenantId, ResourceType resourceType);
  AuditLogEntry[] findByTimeRange(TenantId tenantId, long startTime, long endTime);
  size_t countByTenant(TenantId tenantId);
}
