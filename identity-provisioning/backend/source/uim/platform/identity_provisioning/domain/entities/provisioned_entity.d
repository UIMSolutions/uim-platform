/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity_provisioning.domain.entities.provisioned_entity;

import uim.platform.identity_provisioning;

mixin(ShowModule!());

@safe:

/// A user or group as last written to a target system. It is the delta
/// state of a (source, target) pair: unchanged checksums are skipped.
struct ProvisionedEntity {
  mixin TenantEntity!ProvisionedEntityId;

  string name; /// userName / group name
  EntityType entityType = EntityType.user;
  string externalId; /// id in the source system
  string targetId; /// id in the target system
  SourceSystemId sourceSystemId;
  TargetSystemId targetSystemId;
  string targetSystemName;
  ProvisioningJobId jobId; /// job of the last write
  Attribute[] attributes; /// as written (after transformations)
  string checksum;
  EntityStatus status = EntityStatus.pending;
  OperationType lastOperation = OperationType.create;
  string statusMessage;
  long lastSyncAt;
}
