/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity_provisioning.domain.entities.source_system;

import uim.platform.identity_provisioning;

mixin(ShowModule!());

@safe:

/// A system identities (users, groups) are read from — HR system, directory, IAS.
struct SourceSystem {
  mixin TenantEntity!SourceSystemId;
  mixin ConnectedSystem;
}
