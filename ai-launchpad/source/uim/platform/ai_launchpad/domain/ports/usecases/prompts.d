/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.ai_launchpad.domain.ports.usecases.prompts;
// import uim.platform.ai_launchpad.domain.ports.repositories.prompts;
// import uim.platform.ai_launchpad.domain.entities.prompt;
// import uim.platform.ai_launchpad.domain.services.prompt_enricher;
// import uim.platform.ai_launchpad.domain.types;
// import uim.platform.ai_launchpad.application.dto;


import uim.platform.ai_launchpad;

mixin(ShowModule!());

@safe:
interface IManagePromptsUseCase { 

  UsecaseResult createPrompt(CreatePromptRequest r);
   
  Prompt getPrompt(TenantId tenantId, PromptId id);

  Prompt[] listPrompts(TenantId tenantId, PromptCollectionId collectionId);

  Prompt[] listPrompts(TenantId tenantId);

  UsecaseResult patchPrompt(PatchPromptRequest r);

  UsecaseResult deletePrompt(TenantId tenantId, PromptId id);

}
