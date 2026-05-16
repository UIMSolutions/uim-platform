/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.ai_launchpad.application.usecases.manage.prompt_collections;
// import uim.platform.ai_launchpad.domain.ports.repositories.prompt_collections;
// import uim.platform.ai_launchpad.domain.entities.prompt_collection : PromptCollection;
// import uim.platform.ai_launchpad.domain.types;
// import uim.platform.ai_launchpad.application.dto;
// import std.uuid : randomUUID;

import uim.platform.ai_launchpad;

mixin(ShowModule!());

@safe:
class ManagePromptCollectionsUseCase { // TODO: UIMUseCase {
  private IPromptcollections collections;

  this(IPromptcollections repo) {
    this.collections = repo;
  }

  CommandResult createCollection(CreatePromptCollectionRequest r) {
    if (r.name.length == 0)
      return CommandResult(false, "", "Collection name is required");

    PromptCollection pc;
    pc.initEntity(r.tenantId, r.createdBy);

    pc.name = r.name;
    pc.description = r.description;
    pc.scenarioId = r.scenarioId;
    pc.workspaceId = r.workspaceId;
    pc.promptCount = 0;

    collections.save(pc);
    return CommandResult(true, pc.id.value, "");
  }

  PromptCollection getCollection(TenantId tenantId, PromptCollectionId id) {
    return collections.findById(tenantId, id);
  }

  PromptCollection[] listCollections(TenantId tenantId, WorkspaceId workspaceId) {
    return collections.findByWorkspace(tenantId, workspaceId);
  }

  PromptCollection[] listCollections(TenantId tenantId) {
    return collections.findAll(tenantId);
  }

  CommandResult patchCollection(PatchPromptCollectionRequest r) {
    if (!collections.existsById(r.collectionId))
      return CommandResult(false, "", "Prompt collection not found");
      
    auto pc = collections.findById(r.collectionId);
    if (r.name.length > 0)
      pc.name = r.name;
    if (r.description.length > 0)
      pc.description = r.description;
    pc.updatedAt = "now";
    
    collections.save(pc);
    return CommandResult(true, pc.id.value, "");
  }

  CommandResult deleteCollection(TenantId tenantId, PromptCollectionId id) {
    auto collection = collections.findById(tenantId, id);
    if (collection.isNull)
      return CommandResult(false, "", "Prompt collection not found");

    collections.remove(collection);
    return CommandResult(true, collection.id.value, "");
  }
}
