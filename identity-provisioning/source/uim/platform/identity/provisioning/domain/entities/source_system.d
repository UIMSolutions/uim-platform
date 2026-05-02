/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity.provisioning.domain.entities.source_system;

import uim.platform.identity.provisioning.domain.types;

/// A source system from which identities (users/groups) are read
/// during provisioning runs.
struct SourceSystem {
  mixin TenantEntity!(SourceSystemId);
  
  string name;
  string description;
  SystemType systemType = SystemType.scim;
  SystemStatus status = SystemStatus.configuring;
  string connectionConfig; // JSON: {url, authType, credentials...}
  long lastSyncAt;

  Json toJson() const {
    return entityToJson()
      .set("name", name)
      .set("description", description)
      .set("systemType", systemType.to!string)
      .set("status", status.to!string)
      .set("connectionConfig", connectionConfig)
      .set("lastSyncAt", lastSyncAt);
  }
}
