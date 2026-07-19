/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.ai_launchpad.infrastructure.persistence.repositories.prompt_collections;
// import uim.platform.ai_launchpad.domain.ports.repositories.prompt_collections;
// import uim.platform.ai_launchpad.domain.entities.prompt_collection : PromptCollection;
// import uim.platform.ai_launchpad.domain.types;
import uim.platform.ai_launchpad;

mixin(ShowModule!());

@safe:
class MemoryPromptCollectionRepository : TenantRepository!(PromptCollection, PromptCollectionId), IPromptCollectionRepository {

  // bool existsById(TenantId tenantId, PromptCollectionId id) {
  //   return findByTenant(tenantId).any!(pc => pc.id == id);
  // }
  // PromptCollection findById(TenantId tenantId, PromptCollectionId id) {
  //   foreach(pc; findByTenant(tenantId)) {
  //     if (pc.id == id) return pc;
  //   }
  //   return PromptCollection.init;
  // }
  // void removeById(TenantId tenantId, PromptCollectionId id) {
  //   remove(findById(tenantId, id));
  // }

  size_t countByWorkspace(TenantId tenantId, WorkspaceId workspaceId) {
    return findByWorkspace(tenantId, workspaceId).length;
  }
  PromptCollection[] filterByWorkspace(PromptCollection[] collections, WorkspaceId workspaceId) {
    return collections.filter!(pc => pc.workspaceId == workspaceId).array;
  }
  PromptCollection[] findByWorkspace(TenantId tenantId, WorkspaceId workspaceId) {
    return filterByWorkspace(findByTenant(tenantId), workspaceId);
  }
  void removeByWorkspace(TenantId tenantId, WorkspaceId workspaceId) {
    findByWorkspace(tenantId, workspaceId).each!(pc => remove(pc));
  }

}
