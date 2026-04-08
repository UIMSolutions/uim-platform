/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.ai_launchpad.application.usecases.manage.prompts;

import uim.platform.ai_launchpad.domain.ports.repositories.prompts;
import uim.platform.ai_launchpad.domain.entities.prompt;
import uim.platform.ai_launchpad.domain.services.prompt_enricher;
import uim.platform.ai_launchpad.domain.types;
import uim.platform.ai_launchpad.application.dto;

import std.uuid : randomUUID;
import std.conv : to;

class ManagePromptsUseCase : UIMUseCase {
  private IPromptRepository repo;
  private PromptEnricher enricher;

  this(IPromptRepository repo, PromptEnricher enricher) {
    this.repo = repo;
    this.enricher = enricher;
  }

  CommandResult create(CreatePromptRequest r) {
    if (r.name.length == 0) return CommandResult(false, "", "Prompt name is required");
    if (r.modelName.length == 0) return CommandResult(false, "", "Model name is required");

    Prompt p;
    p.id = randomUUID().to!string;
    p.collectionId = r.collectionId;
    p.name = r.name;
    p.modelName = r.modelName;
    p.modelVersion = r.modelVersion;
    p.inputParams = r.inputParams;
    p.status = PromptStatus.draft;
    p.createdBy = r.createdBy;

    foreach (ref msg; r.messages) {
      if (msg.length >= 2) {
        PromptRole role = PromptRole.user;
        if (msg[0] == "system") role = PromptRole.system;
        else if (msg[0] == "assistant") role = PromptRole.assistant;
        p.messages ~= PromptMessage(role, msg[1]);
      }
    }

    p.parameters.temperature = r.temperature;
    p.parameters.maxTokens = r.maxTokens;
    p.parameters.topP = r.topP;
    p.parameters.frequencyPenalty = r.frequencyPenalty;
    p.parameters.presencePenalty = r.presencePenalty;

    enricher.applyDefaults(p);

    if (!enricher.validateMessages(p))
      return CommandResult(false, "", "Prompt must have at least one user message");

    p.createdAt = "now";
    p.modifiedAt = "now";
    repo.save(p);
    return CommandResult(true, p.id, "");
  }

  Prompt get_(PromptId id) {
    return repo.findById(id);
  }

  Prompt[] listByCollection(PromptCollectionId collectionId) {
    return repo.findByCollection(collectionId);
  }

  Prompt[] listAll() {
    return repo.findAll();
  }

  CommandResult patch(PatchPromptRequest r) {
    auto p = repo.findById(r.promptId);
    if (p.id.isEmpty) return CommandResult(false, "", "Prompt not found");
    if (r.name.length > 0) p.name = r.name;
    if (r.status == "active") p.status = PromptStatus.active;
    else if (r.status == "archived") p.status = PromptStatus.archived;
    if (r.maxTokens > 0) p.parameters.maxTokens = r.maxTokens;
    if (r.temperature > 0) p.parameters.temperature = r.temperature;

    if (r.messages.length > 0) {
      p.messages = [];
      foreach (ref msg; r.messages) {
        if (msg.length >= 2) {
          PromptRole role = PromptRole.user;
          if (msg[0] == "system") role = PromptRole.system;
          else if (msg[0] == "assistant") role = PromptRole.assistant;
          p.messages ~= PromptMessage(role, msg[1]);
        }
      }
    }

    p.modifiedAt = "now";
    repo.save(p);
    return CommandResult(true, p.id, "");
  }

  CommandResult remove(PromptId id) {
    auto p = repo.findById(id);
    if (p.id.isEmpty) return CommandResult(false, "", "Prompt not found");
    repo.remove(id);
    return CommandResult(true, id, "");
  }
}
