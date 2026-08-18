/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.ai_launchpad.domain.ports.usecases.prompt_collections;

import uim.platform.ai_launchpad;

mixin(ShowModule!());

@safe:
interface IManagePromptCollectionsUseCase { 

  UsecaseResult createCollection(CreatePromptCollectionRequest r);
  
  PromptCollection getCollection(TenantId tenantId, PromptCollectionId id);

  PromptCollection[] listCollections(TenantId tenantId, WorkspaceId workspaceId);

  PromptCollection[] listCollections(TenantId tenantId);

  UsecaseResult patchCollection(PatchPromptCollectionRequest r);

  UsecaseResult deleteCollection(TenantId tenantId, PromptCollectionId id);
  
}
