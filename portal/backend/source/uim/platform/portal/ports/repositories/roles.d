/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.portal.ports.repositories.roles;

import uim.platform.portal;

mixin(ShowModule!());

@safe:

interface IRoleRepository : ITenantRepository!(PortalRole, PortalRoleId) {
  PortalRole findByName(TenantId tenantId, string name);
}
