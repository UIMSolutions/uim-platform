/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.ai_core.application.use_cases.manage_scenarios;

import uim.platform.ai_core.domain.types;
import uim.platform.ai_core.domain.entities.scenario;
import uim.platform.ai_core.domain.ports.scenario_repository;
import uim.platform.ai_core.domain.services.scenario_validator;
import uim.platform.ai_core.application.dto;

import std.conv : to;

class ManageScenariosUseCase : UIMUseCase {
  private ScenarioRepository repo;

  this(ScenarioRepository repo) {
    this.repo = repo;
  }

  CommandResult create(CreateScenarioRequest r) {
    auto err = ScenarioValidator.validate(r.id, r.name);
    if (err.length > 0)
      return CommandResult(false, "", err);

    if (r.resourceGroupId.length == 0)
      return CommandResult(false, "", "Resource group ID is required");

    auto existing = repo.findById(r.id, r.resourceGroupId);
    if (existing.id.length > 0)
      return CommandResult(false, "", "Scenario already exists");

    Scenario s;
    s.id = r.id;
    s.tenantId = r.tenantId;
    s.resourceGroupId = r.resourceGroupId;
    s.name = r.name;
    s.description = r.description;
    s.labels = r.labels;

    import core.time : MonoTime;
    auto now = MonoTime.currTime.ticks;
    s.createdAt = now;
    s.modifiedAt = now;

    repo.save(s);
    return CommandResult(true, s.id, "");
  }

  Scenario get_(ScenarioId id, ResourceGroupId rgId) {
    return repo.findById(id, rgId);
  }

  Scenario[] list(ResourceGroupId rgId) {
    return repo.findByResourceGroup(rgId);
  }

  CommandResult remove(ScenarioId id, ResourceGroupId rgId) {
    auto existing = repo.findById(id, rgId);
    if (existing.id.length == 0)
      return CommandResult(false, "", "Scenario not found");

    repo.remove(id, rgId);
    return CommandResult(true, id, "");
  }

  long count(ResourceGroupId rgId) {
    return repo.countByResourceGroup(rgId);
  }
}
