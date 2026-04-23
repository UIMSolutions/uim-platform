/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.workzone.domain.ports.repositories.workpages;

import uim.platform.workzone.domain.types;
import uim.platform.workzone.domain.entities.workpage;

interface WorkpageRepository : ITenantRepository!(Workpage, WorkpageId) {

  size_t countByWorkspace(TenantId tenantId, WorkspaceId workspaceId);
  Workpage[] findByWorkspace(TenantId tenantId, WorkspaceId workspaceId);
  void removeByWorkspace(TenantId tenantId, WorkspaceId workspaceId);

}
