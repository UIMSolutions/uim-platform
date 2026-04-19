/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.credential_store.application.usecases.get_audit_logs;

import uim.platform.credential_store.domain.ports.repositories.audit_logs;
import uim.platform.credential_store.domain.entities.audit_log_entry;
import uim.platform.credential_store.domain.types;
import uim.platform.credential_store.application.dto;

class GetAuditLogsUseCase { // TODO: UIMUseCase {
  private AuditLogRepository repo;

  this(AuditLogRepository repo) {
    this.repo = repo;
  }

  AuditLogEntry[] list(TenantId tenantId) {
    return repo.findByTenant(tenantId);
  }

  AuditLogEntry[] listByNamespace(TenantId tenantId, NamespaceId namespaceId) {
    return repo.findByNamespace(tenantId, namespaceId);
  }

  AuditLogEntry[] listByResourceType(TenantId tenantId, string resourceType) {
    return repo.findByResourceType(tenantId, parseResourceType(resourceType));
  }

  AuditLogEntry[] listByTimeRange(TenantId tenantId, long startTime, long endTime) {
    return repo.findByTimeRange(tenantId, startTime, endTime);
  }

  AuditLogEntry getById(AuditLogEntryId id) {
    return repo.findById(id);
  }

  size_t count(TenantId tenantId) {
    return repo.countByTenant(tenantId);
  }

  private static ResourceType parseResourceType(string rt) {
    switch (rt) {
    case "namespace":
      return ResourceType.namespace;
    case "password":
      return ResourceType.password;
    case "key":
      return ResourceType.key;
    case "keyring":
      return ResourceType.keyring;
    case "keyringVersion":
      return ResourceType.keyringVersion;
    case "serviceBinding":
      return ResourceType.serviceBinding;
    case "dek":
      return ResourceType.dek;
    default:
      return ResourceType.namespace;
    }
  }
}
