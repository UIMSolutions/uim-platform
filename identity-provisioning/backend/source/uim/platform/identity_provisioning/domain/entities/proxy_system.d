/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity_provisioning.domain.entities.proxy_system;

import uim.platform.identity_provisioning;

mixin(ShowModule!());

@safe:

/// A proxy system exposes the provisioning engine to an external identity
/// management system, which reads and writes through it (SCIM).
struct ProxySystem {
  mixin TenantEntity!ProxySystemId;
  mixin ConnectedSystem;
}
