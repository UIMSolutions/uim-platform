/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity.provisioning.domain.entities.proxy_system;

import uim.platform.identity.provisioning.domain.types;

/// A proxy system that acts as an intermediary between a source
/// and target system, applying transformations and access control.
struct ProxySystem
{
  ProxySystemId id;
  TenantId tenantId;
  string name;
  string description;
  SystemType systemType = SystemType.scim;
  SystemStatus status = SystemStatus.configuring;
  string connectionConfig; // JSON: {url, authType, credentials...}
  SourceSystemId sourceSystemId;
  TargetSystemId targetSystemId;
  UserId createdBy;
  long createdAt;
  long updatedAt;
}
