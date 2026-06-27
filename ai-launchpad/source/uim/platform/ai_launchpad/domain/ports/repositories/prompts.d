/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.ai_launchpad.domain.ports.repositories.prompts;

// import uim.platform.ai_launchpad.domain.types;
// import uim.platform.ai_launchpad.domain.entities.prompt : Prompt;
import uim.platform.ai_launchpad;

// mixin(ShowModule!());

@safe:

interface IPromptRepository : ITenantRepository!(Prompt, PromptId) {

  // bool existsById(TenantId tenantId, PromptId id);
  // Prompt findById(TenantId tenantId, PromptId id);
  // void removeById(TenantId tenantId, PromptId id);

  size_t countByCollection(TenantId tenantId, PromptCollectionId collectionId);
  Prompt[] findByCollection(TenantId tenantId, PromptCollectionId collectionId);
  void removeByCollection(TenantId tenantId, PromptCollectionId collectionId);

  size_t countByStatus(TenantId tenantId, PromptStatus status);
  Prompt[] findByStatus(TenantId tenantId, PromptStatus status);
  void removeByStatus(TenantId tenantId, PromptStatus status);

}
