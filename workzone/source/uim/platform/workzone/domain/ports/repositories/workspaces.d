/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.workzone.domain.ports.repositories.workspaces;

// import uim.platform.workzone.domain.types;
// import uim.platform.workzone.domain.entities.workspace;
import uim.platform.workzone;

mixin(ShowModule!());

@safe:
interface WorkspaceRepository : ITenantRepository!(Workspace, WorkspaceId) {

  bool existsByAlias(TenantId tenantId, string alias_);
  Workspace findByAlias(TenantId tenantId, string alias_);
  void removeByAlias(TenantId tenantId, string alias_);

  size_t countByMember(TenantId tenantId, UserId userId);
  Workspace[] findByMember(TenantId tenantId, UserId userId);
  void removeByMember(TenantId tenantId, UserId userId);

}
