/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.buildcode.domain.ports.repositories.projects;

import uim.platform.buildcode;

// mixin(ShowModule!());

@safe:

interface ProjectRepository : ITentRepository!(Project, ProjectId) {
  Project[]  findByStatus(TenantId tenantId, ProjectStatus status);
  Project[]  findByType(TenantId tenantId, ProjectType type);
  Project[]  findByOwner(TenantId tenantId, string ownerEmail);
  bool       nameExists(TenantId tenantId, string name);
}
