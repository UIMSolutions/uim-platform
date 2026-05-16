/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.ai_launchpad.infrastructure.persistence.memory.prompts;
// import uim.platform.ai_launchpad.domain.ports.repositories.prompts;
// import uim.platform.ai_launchpad.domain.entities.prompt : Prompt;
// import uim.platform.ai_launchpad.domain.types;
import uim.platform.ai_launchpad;

mixin(ShowModule!());

@safe:
class MemoryPromptRepository : TenantRepository!(Prompt, PromptId), IPromptRepository {

  // bool existsById(TenantId tenantId, PromptId id) {
  //   return findByTenant(tenantId).any!(p => p.id == id);
  // }

  // Prompt findById(TenantId tenantId, PromptId id) {
  //   foreach (p; findByTenant(tenantId)) {
  //     if (p.id == id)
  //       return p;
  //   }
  //   return Prompt.init;
  // }

  // void removeById(TenantId tenantId, PromptId id) {
  //   remove(findById(tenantId, id));
  // }

  size_t countByCollection(TenantId tenantId, PromptCollectionId collectionId) {
    return findByCollection(tenantId, collectionId).length;
  }

  Prompt[] findByCollection(TenantId tenantId, PromptCollectionId collectionId) {
    return filterByCollection(findByTenant(tenantId), collectionId);
  }

  void removeByCollection(TenantId tenantId, PromptCollectionId collectionId) {
    findByCollection(tenantId, collectionId).each!(p => remove(p));
  }

  size_t countByStatus(TenantId tenantId, PromptStatus status) {
    return findByStatus(tenantId, status).length;
  }

  Prompt[] findByStatus(TenantId tenantId, PromptStatus status) {
    return filterByStatus(findByTenant(tenantId), status);
  }

  void removeByStatus(TenantId tenantId, PromptStatus status) {
    findByStatus(tenantId, status).each!(p => remove(p));
  }

}
