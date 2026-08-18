/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.ai_core.application.usecases.manage.executions;

import uim.platform.ai_core;

mixin(ShowModule!()); 

@safe:
class ManageExecutionsUseCase {
  protected IExecutionRepository execRepo;
  protected IConfigurationRepository confRepo;

  this(IExecutionRepository execRepo, IConfigurationRepository confRepo) {
    this.execRepo = execRepo;
    this.confRepo = confRepo;
  }

  UsecaseResult createExecution(CreateExecutionRequest r) {
    if (r.configurationId.isEmpty)
      return UsecaseResult(false, "", "Configuration ID is required");

    if (r.resourceGroupId.isEmpty)
      return UsecaseResult(false, "", "Resource group ID is required");

    auto conf = confRepo.findById(r.tenantId, r.resourceGroupId, r.configurationId);
    if (conf.isNull)
      return UsecaseResult(false, "", "Configuration not found");

    auto e = Execution(r.tenantId, r.executionId.isNull ? ExecutionId(createId()) : r.executionId); // , r.createdBy);
    e.resourceGroupId = r.resourceGroupId;
    e.configurationId = r.configurationId;
    e.scenarioId = conf.scenarioId;
    e.executableId = conf.executableId;
    e.status = ExecutionStatus.pending;
    e.statusMessage = "Execution created and pending";

    execRepo.save(e);
    return UsecaseResult(true, e.id.value, "");
  }

  UsecaseResult patchExecution(PatchExecutionRequest r) {
    auto e = execRepo.findById(r.tenantId, r.resourceGroupId, r.executionId);
    if (e.isNull)
      return UsecaseResult(false, "", "Execution not found");

    TargetStatus target;
    if (r.targetStatus == "stopped")
      target = TargetStatus.stopped;
    else if (r.targetStatus == "deleted")
      target = TargetStatus.deleted_;
    else
      return UsecaseResult(false, "", "Invalid target status");

    if (!ExecutionScheduler.canTransition(e.status, target))
      return UsecaseResult(false, "", "Cannot transition to target status from current status");

    e.targetStatus = target;
    if (target == TargetStatus.stopped)
      e.status = ExecutionStatus.stopped;
    else if (target == TargetStatus.deleted_) {
      e.status = ExecutionStatus.dead;
    }

    
    e.updatedAt = currentTimestamp;

    execRepo.update(e);
    return UsecaseResult(true, e.id.value, "");
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
  
  UsecaseResult deleteExecution(TenantId tenantId, ResourceGroupId resourceGroupId, ExecutionId executionId) {
    auto execution = execRepo.findById(tenantId, resourceGroupId, executionId);
    if (execution.isNull)
      return UsecaseResult(false, "", "Execution not found");

    execRepo.remove(execution);
    return UsecaseResult(true, execution.id.value, "");
  }

}

///
unittest {
//    auto executionRepository = new ExecutionRepository();
//    auto configurationRepository = new ConfigurationRepository();
//    auto usecase = new ManageExecutionsUseCase(executionRepository, configurationRepository);
//    auto tenantId = TenantId("test-tenant");
//
//    assert(usecase !is null);
}
