/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.ai_launchpad.domain.ports.repositories.prompt_collections;

// import uim.platform.ai_launchpad.domain.types;
// import uim.platform.ai_launchpad.domain.entities.prompt_collection : PromptCollection;
import uim.platform.ai_launchpad;
mixin(ShowModule!());

@safe:

interface IPromptCollectionRepository : ITenantRepository!(PromptCollection, PromptCollectionId) {

  // bool existsById(TenantId tenantId, PromptCollectionId id);
  // PromptCollection findById(TenantId tenantId, PromptCollectionId id);
  // void removeById(TenantId tenantId, PromptCollectionId id);

  size_t countByWorkspace(TenantId tenantId, WorkspaceId workspaceId);
  PromptCollection[] findByWorkspace(TenantId tenantId, WorkspaceId workspaceId);
  void removeByWorkspace(TenantId tenantId, WorkspaceId workspaceId);

}
