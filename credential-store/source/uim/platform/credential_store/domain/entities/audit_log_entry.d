/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.credential_store.domain.entities.audit_log_entry;

import uim.platform.credential_store.domain.types;

struct AuditLogEntry {
  AuditLogEntryId id;
  TenantId tenantId;
  NamespaceId namespaceId;
  OperationType operation;
  ResourceType resourceType;
  string resourceName;
  string performedBy;
  long timestamp;
  string details;
  string sourceIp;
  bool success;
}
