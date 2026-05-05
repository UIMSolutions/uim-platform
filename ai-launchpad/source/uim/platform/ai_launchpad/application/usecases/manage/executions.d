/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.ai_launchpad.application.usecases.manage.executions;

// import uim.platform.ai_launchpad.domain.ports.repositories.executions;
// import uim.platform.ai_launchpad.domain.entities.execution : Execution;
// import uim.platform.ai_launchpad.domain.types;
// import uim.platform.ai_launchpad.application.dto;

// import std.uuid : randomUUID;
// import std.conv : to;
import uim.platform.ai_launchpad;

mixin(ShowModule!());

@safe:
class ManageExecutionsUseCase { // TODO: UIMUseCase {
  private IExecutionRepository repo;

  this(IExecutionRepository repo) {
    this.repo = repo;
  }

  CommandResult create(CreateExecutionRequest r) {
    Execution e;
    e.id = randomUUID();
    e.connectionId = r.connectionId;
    e.configurationId = r.configurationId;
    e.resourceGroupId = r.resourceGroupId;
    e.status = ExecutionStatus.pending;
    e.createdAt = "now";
    e.updatedAt = "now";
    repo.save(e);
    return CommandResult(true, e.id.value, "");
  }

  Execution getById(ExecutionId id, ConnectionId connectionId) {
    return repo.findById(id, connectionId);
  }

  Execution[] listByConnection(ConnectionId connectionId) {
    return repo.findByConnection(connectionId);
  }

  Execution[] listByScenario(ScenarioId scenarioId, ConnectionId connectionId) {
    return repo.findByScenario(scenarioId, connectionId);
  }

  CommandResult patch(PatchExecutionRequest r) {
    auto e = repo.findById(r.executionId, r.connectionId);
    if (e.isNull) return CommandResult(false, "", "Execution not found");
    e.targetStatus = r.targetStatus;
    if (r.targetStatus == "stopped") e.status = ExecutionStatus.stopped;
    else if (r.targetStatus == "deleted") e.status = ExecutionStatus.dead;
    e.updatedAt = "now";
    repo.save(e);
    return CommandResult(true, e.id.value, "");
  }

  CommandResult[] bulkPatch(BulkPatchExecutionRequest r) {
    CommandResult[] results;
    foreach (eid; r.executionIds) {
      PatchExecutionRequest pr;
      pr.connectionId = r.connectionId;
      pr.executionId = eid;
      pr.targetStatus = r.targetStatus;
      results ~= patch(pr);
    }
    return results;
  }

  CommandResult remove(ExecutionId id, ConnectionId connectionId) {
    auto e = repo.findById(id, connectionId);
    if (e.isNull) return CommandResult(false, "", "Execution not found");
    repo.remove(id, connectionId);
    return CommandResult(true, id.value, "");
  }
}
