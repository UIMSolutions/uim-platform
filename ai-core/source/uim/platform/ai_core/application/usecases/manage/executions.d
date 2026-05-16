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

    auto conf = confRepo.findById(r.tenantId, r.resourceGroupId, r.configurationId);
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

    execRepo.save(e);
    return CommandResult(true, e.id.value, "");
  }

  CommandResult patchExecution(PatchExecutionRequest r) {
    auto e = execRepo.findById(r.tenantId, r.resourceGroupId, r.executionId);
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

  Execution getExecution(TenantId tenantId, ResourceGroupId resourceGroupId, ExecutionId executionId) {
    return execRepo.findById(tenantId, resourceGroupId, executionId);
  }

  Execution[] listExecutions(TenantId tenantId, ResourceGroupId resourceGroupId) {
    return execRepo.findByResourceGroup(tenantId, resourceGroupId);
  }

  Execution[] listExecutions(TenantId tenantId, ResourceGroupId resourceGroupId, ScenarioId scenarioId) {
    return execRepo.findByScenario(tenantId, resourceGroupId, scenarioId);
  }

  Execution[] listExecutions(TenantId tenantId, ResourceGroupId resourceGroupId, ExecutionStatus status) {
    return execRepo.findByStatus(tenantId, resourceGroupId, status);
  }

  size_t countExecutions(TenantId tenantId, ResourceGroupId resourceGroupId) {
    return execRepo.countByResourceGroup(tenantId, resourceGroupId);
  }
  
  CommandResult deleteExecution(TenantId tenantId, ResourceGroupId resourceGroupId, ExecutionId executionId) {
    auto execution = execRepo.findById(tenantId, resourceGroupId, executionId);
    if (execution.isNull)
      return CommandResult(false, "", "Execution not found");

    execRepo.remove(execution);
    return CommandResult(true, execution.id.value, "");
  }

}
