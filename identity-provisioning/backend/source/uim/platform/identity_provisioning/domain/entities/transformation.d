/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity_provisioning.domain.entities.transformation;

import uim.platform.identity_provisioning;

mixin(ShowModule!());

@safe:

/// Attribute mappings and entity filters of one system. Read transformations
/// (role source) run first, then the write transformations of the target.
struct Transformation {
  mixin TenantEntity!TransformationId;

  string name;
  string description;
  SystemRole systemRole = SystemRole.target;
  string systemId; /// id of the source, target or proxy system
  string systemName; /// derived
  EntityScope scope_ = EntityScope.all;
  int sequence = 10; /// order within the system (ascending)
  bool active = true;
  AttributeMapping[] mappings; /// empty = pass all attributes through
  EntityCondition[] conditions; /// all must hold, otherwise the entity is skipped
}
