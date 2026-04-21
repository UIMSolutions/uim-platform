/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity.provisioning.domain.entities.provisioned_entity;

import uim.platform.identity.provisioning.domain.types;

/// A tracked identity entity (user or group) that has been
/// provisioned from a source to a target system.
struct ProvisionedEntity {
  mixin TenantEntity!(ProvisionedEntityId);
  
  string externalId; // id in the external system
  EntityType entityType = EntityType.user;
  SourceSystemId sourceSystemId;
  TargetSystemId targetSystemId;
  string attributes; // JSON: provisioned attribute snapshot
  EntityStatus status = EntityStatus.pending;
  long lastSyncAt;

  Json toJson() const {
    return Json.entityToJson
      .set("externalId", externalId)
      .set("entityType", entityType.to!string)
      .set("sourceSystemId", sourceSystemId)
      .set("targetSystemId", targetSystemId)
      .set("attributes", attributes)
      .set("status", status.to!string)
      .set("lastSyncAt", lastSyncAt);
  }
}
