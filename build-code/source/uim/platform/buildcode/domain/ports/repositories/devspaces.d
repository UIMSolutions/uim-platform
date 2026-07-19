/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.buildcode.domain.ports.repositories.devspaces;

import uim.platform.buildcode;
mixin(ShowModule!());

@safe:

interface DevSpaceRepository : ITenantRepository!(DevSpace, DevSpaceId) {
  DevSpace[]  findByProject(TenantId tenantId, string projectId);
  DevSpace[]  findByStatus(TenantId tenantId, DevSpaceStatus status);
}
