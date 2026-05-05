/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity.provisioning.domain.entities.proxy_system;

import uim.platform.identity.provisioning.domain.types;

/// A proxy system that acts as an intermediary between a source
/// and target system, applying transformations and access control.
struct ProxySystem {
  mixin TenantEntity!ProxySystemId;

  string name;
  string description;
  SystemType systemType = SystemType.scim;
  SystemStatus status = SystemStatus.configuring;
  string connectionConfig; // JSON: {url, authType, credentials...}
  SourceSystemId sourceSystemId;
  TargetSystemId targetSystemId;


  Json toJson() const {
    return entityToJson
      .set("name", name)
      .set("description", description)
      .set("systemType", systemType.to!string())
      .set("status", status.to!string())
      .set("connectionConfig", connectionConfig)
      .set("sourceSystemId", sourceSystemId)
      .set("targetSystemId", targetSystemId);
  }
}
