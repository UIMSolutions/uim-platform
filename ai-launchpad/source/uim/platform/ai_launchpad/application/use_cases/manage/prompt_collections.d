/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.ai_launchpad.application.usecases.manage.prompt_collections;

import uim.platform.ai_launchpad.domain.ports.repositories.prompt_collections;
import uim.platform.ai_launchpad.domain.entities.prompt_collection : PromptCollection;
import uim.platform.ai_launchpad.domain.types;
import uim.platform.ai_launchpad.application.dto;

import std.uuid : randomUUID;
import std.conv : to;

class ManagePromptCollectionsUseCase { // TODO: UIMUseCase {
  private IPromptCollectionRepository collectionRepository;

  this(IPromptCollectionRepository repo) {
    this.collectionRepository = repo;
  }

  CommandResult create(CreatePromptCollectionRequest r) {
    if (r.name.length == 0)
      return CommandResult(false, "", "Collection name is required");

    PromptCollection pc;
    pc.id = randomUUID();
    pc.name = r.name;
    pc.description = r.description;
    pc.scenarioId = r.scenarioId;
    pc.workspaceId = r.workspaceId;
    pc.promptCount = 0;
    pc.createdAt = "now";
    pc.updatedAt = "now";
    collectionRepository.save(pc);
    return CommandResult(true, pc.id, "");
  }

  PromptCollection getById(PromptCollectionId id) {
    return collectionRepository.findById(id);
  }

  PromptCollection[] listByWorkspace(WorkspaceId workspaceId) {
    return collectionRepository.findByWorkspace(workspaceId);
  }

  PromptCollection[] listAll() {
    return collectionRepository.findAll();
  }

  CommandResult patch(PatchPromptCollectionRequest r) {
    if (!collectionRepository.existsById(r.collectionId))
      return CommandResult(false, "", "Prompt collection not found");
      
    auto pc = collectionRepository.findById(r.collectionId);
    if (r.name.length > 0)
      pc.name = r.name;
    if (r.description.length > 0)
      pc.description = r.description;
    pc.updatedAt = "now";
    collectionRepository.save(pc);
    return CommandResult(true, pc.id, "");
  }

  CommandResult remove(PromptCollectionId id) {
    if (!collectionRepository.existsById(id))
      return CommandResult(false, "", "Prompt collection not found");

    collectionRepository.removeById(id);
    return CommandResult(true, id.value, "");
  }
}
