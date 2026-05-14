/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.ai_core.application.usecases.manage.executions;

// import uim.platform.ai_core.domain.types;
// import uim.platform.ai_core.domain.entities.execution;
// import uim.platform.ai_core.domain.ports.repositories.execution;
// import uim.platform.ai_core.domain.ports.repositories.configuration;
// import uim.platform.ai_core.domain.services.execution_scheduler;
// import uim.platform.ai_core.application.dto;

// import std.uuid : randomUUID;

import uim.platform.ai_core;

mixin(ShowModule!()); 

@safe:
class ManageExecutionsUseCase { // TODO: UIMUseCase {
  private ExecutionRepository execRepo;
  private ConfigurationRepository confRepo;

  this(ExecutionRepository execRepo, ConfigurationRepository confRepo) {
    this.execRepo = execRepo;
    this.confRepo = confRepo;
  }

  CommandResult createExecution(CreateExecutionRequest r) {
    if (r.configurationId.isEmpty)
      return CommandResult(false, "", "Configuration ID is required");
    if (r.resourceGroupId.isEmpty)
      return CommandResult(false, "", "Resource group ID is required");

    auto conf = confRepo.findById(r.configurationId, r.resourceGroupId);
    if (conf.isNull)
      return CommandResult(false, "", "Configuration not found");

    Execution e;
    e.initEntity(r.tenantId);
    e.resourceGroupId = r.resourceGroupId;
    e.configurationId = r.configurationId;
    e.scenarioId = conf.scenarioId;
    e.executableId = conf.executableId;
    e.status = ExecutionStatus.pending;
    e.statusMessage = "Execution created and pending";

    import core.time : MonoTime;
    auto now = MonoTime.currTime.ticks;
    e.createdAt = now;
    e.updatedAt = now;

    execRepo.save(e);
    return CommandResult(true, e.id.value, "");
  }

  CommandResult patchExecution(PatchExecutionRequest r) {
    auto e = execRepo.findById(r.executionId, r.resourceGroupId);
    if (e.isNull)
      return CommandResult(false, "", "Execution not found");

    TargetStatus target;
    if (r.targetStatus == "stopped")
      target = TargetStatus.stopped;
    else if (r.targetStatus == "deleted")
      target = TargetStatus.deleted_;
    else
      return CommandResult(false, "", "Invalid target status");

    if (!ExecutionScheduler.canTransition(e.status, target))
      return CommandResult(false, "", "Cannot transition to target status from current status");

    e.targetStatus = target;
    if (target == TargetStatus.stopped)
      e.status = ExecutionStatus.stopped;
    else if (target == TargetStatus.deleted_) {
      e.status = ExecutionStatus.dead;
    }

    import core.time : MonoTime;
    e.updatedAt = MonoTime.currTime.ticks;

    execRepo.update(e);
    return CommandResult(true, e.id.value, "");
  }

  Execution getExecution(GetExecutionRequest r) {
    return execRepo.findById(r.resourceGroupId, r.executionId);
  }

  Execution[] listExecutions(ListExecutionsRequest r) {
    return execRepo.findByResourceGroup(r.resourceGroupId);
  }

  Execution[] listExecutionsByScenario(ListExecutionsByScenarioRequest r) {
    return execRepo.findByScenario(r.resourceGroupId, r.scenarioId);
  }

  Execution[] listExecutionsByStatus(ListExecutionsByStatusRequest r) {
    return execRepo.findByStatus(r.resourceGroupId, r.status, r.resourceGroupId);
  }

  size_t count(CountExecutionsRequest r) {
    return execRepo.countByResourceGroup(r.resourceGroupId);
  }

  CommandResult deleteExecution(DeleteExecutionRequest r) {
    auto execution = execRepo.findById(r.resourceGroupId, r.executionId);
    if (execution.isNull)
      return CommandResult(false, "", "Execution not found");

    execRepo.remove(execution);
    return CommandResult(true, execution.id.value, "");
  }

}
