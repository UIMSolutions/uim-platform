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

class ManagePromptCollectionsUseCase : UIMUseCase {
  private IPromptCollectionRepository repo;

  this(IPromptCollectionRepository repo) {
    this.repo = repo;
  }

  CommandResult create(CreatePromptCollectionRequest r) {
    if (r.name.length == 0) return CommandResult(false, "", "Collection name is required");

    PromptCollection pc;
    pc.id = randomUUID().to!string;
    pc.name = r.name;
    pc.description = r.description;
    pc.scenarioId = r.scenarioId;
    pc.workspaceId = r.workspaceId;
    pc.promptCount = 0;
    pc.createdAt = "now";
    pc.modifiedAt = "now";
    repo.save(pc);
    return CommandResult(true, pc.id, "");
  }

  PromptCollection get_(PromptCollectionId id) {
    return repo.findById(id);
  }

  PromptCollection[] listByWorkspace(WorkspaceId workspaceId) {
    return repo.findByWorkspace(workspaceId);
  }

  PromptCollection[] listAll() {
    return repo.findAll();
  }

  CommandResult patch(PatchPromptCollectionRequest r) {
    auto pc = repo.findById(r.collectionId);
    if (pc.id.length == 0) return CommandResult(false, "", "Prompt collection not found");
    if (r.name.length > 0) pc.name = r.name;
    if (r.description.length > 0) pc.description = r.description;
    pc.modifiedAt = "now";
    repo.save(pc);
    return CommandResult(true, pc.id, "");
  }

  CommandResult remove(PromptCollectionId id) {
    auto pc = repo.findById(id);
    if (pc.id.length == 0) return CommandResult(false, "", "Prompt collection not found");
    repo.remove(id);
    return CommandResult(true, id, "");
  }
}
