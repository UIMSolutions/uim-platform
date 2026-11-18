/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity_provisioning.domain.enumerations.identities;

import uim.platform.identity_provisioning;

mixin(ShowModule!());

@safe:

/// Kind of identity being provisioned.
enum EntityType {
  user,
  group,
}

/// Status of a provisioned entity in the target system.
enum EntityStatus {
  active, /// provisioned and active
  inactive, /// provisioned, deactivated in the source ("active" = false)
  pending, /// planned, not yet written
  error, /// last write failed
}
