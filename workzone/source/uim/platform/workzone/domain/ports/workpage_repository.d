/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.workzone.domain.ports.workpage_repository;

import uim.platform.workzone.domain.types;
import uim.platform.workzone.domain.entities.workpage;

interface WorkpageRepository
{
  Workpage[] findByWorkspace(WorkspaceId workspaceId, TenantId tenantId);
  Workpage* findById(WorkpageId id, TenantId tenantId);
  void save(Workpage page);
  void update(Workpage page);
  void remove(WorkpageId id, TenantId tenantId);
}
