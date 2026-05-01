/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.credential_store.domain.ports.repositories.audit_logs;

// import uim.platform.credential_store.domain.entities.audit_log_entry;
// import uim.platform.credential_store.domain.types;

import uim.platform.credential_store;

mixin(ShowModule!());

@safe:

interface AuditLogRepository : ITenantRepository!(AuditLogEntry, AuditLogEntryId) {

  size_t countByNamespace(TenantId tenantId, NamespaceId namespaceId);
  AuditLogEntry[] findByNamespace(TenantId tenantId, NamespaceId namespaceId);
  void removeByNamespace(TenantId tenantId, NamespaceId namespaceId);

  size_t countByResourceType(TenantId tenantId, ResourceType resourceType);
  AuditLogEntry[] findByResourceType(TenantId tenantId, ResourceType resourceType);
  void removeByResourceType(TenantId tenantId, ResourceType resourceType);
  
  size_t countByTimeRange(TenantId tenantId, long startTime, long endTime);
  AuditLogEntry[] findByTimeRange(TenantId tenantId, long startTime, long endTime);
  void removeByTimeRange(TenantId tenantId, long startTime, long endTime);

}
