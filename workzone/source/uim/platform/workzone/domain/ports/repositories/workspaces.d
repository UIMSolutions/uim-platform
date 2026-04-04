/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.workzone.domain.ports.repositories.workspaces;

import uim.platform.workzone.domain.types;
import uim.platform.workzone.domain.entities.workspace;

interface WorkspaceRepository {
  Workspace[] findByTenant(TenantId tenantId);
  Workspace* findById(WorkspaceId id, TenantId tenantId);
  Workspace* findByAlias(string alias_, TenantId tenantId);
  Workspace[] findByMember(UserId userId, TenantId tenantId);
  void save(Workspace workspace);
  void update(Workspace workspace);
  void remove(WorkspaceId id, TenantId tenantId);
}
