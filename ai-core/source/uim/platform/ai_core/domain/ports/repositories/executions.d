/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.ai_core.domain.ports.repositories.executions;
// import uim.platform.ai_core.domain.types;
// import uim.platform.ai_core.domain.entities.execution;
import uim.platform.ai_core;

mixin(ShowModule!()); 

@safe:
interface ExecutionRepository : ITenantRepository!(Execution, ExecutionId) {

  bool existsById(TenantId tenantId, ResourceGroupId rgId, ExecutionId id);
  Execution findById(TenantId tenantId, ResourceGroupId rgId, ExecutionId id);
  void removeById(TenantId tenantId, ResourceGroupId rgId, ExecutionId id);

  size_t countByResourceGroup(TenantId tenantId, ResourceGroupId rgId);
  Execution[] findByResourceGroup(TenantId tenantId, ResourceGroupId rgId);
  void removeByResourceGroup(TenantId tenantId, ResourceGroupId rgId);
  
  size_t countByScenario(TenantId tenantId, ResourceGroupId rgId, ScenarioId scenarioId);
  Execution[] findByScenario(TenantId tenantId, ResourceGroupId rgId, ScenarioId scenarioId);
  void removeByScenario(TenantId tenantId, ResourceGroupId rgId, ScenarioId scenarioId);

  size_t countByConfiguration(TenantId tenantId, ResourceGroupId rgId, ConfigurationId confId);
  Execution[] findByConfiguration(TenantId tenantId, ResourceGroupId rgId, ConfigurationId confId);
  void removeByConfiguration(TenantId tenantId, ResourceGroupId rgId, ConfigurationId confId);

  size_t countByExecutable(TenantId tenantId, ResourceGroupId rgId, ExecutableId execId);
  Execution[] findByExecutable(TenantId tenantId, ResourceGroupId rgId, ExecutableId execId);
  void removeByExecutable(TenantId tenantId, ResourceGroupId rgId, ExecutableId execId);

  size_t countByStatus(TenantId tenantId, ResourceGroupId rgId, ExecutionStatus status);
  Execution[] findByStatus(TenantId tenantId, ResourceGroupId rgId, ExecutionStatus status);
  void removeByStatus(TenantId tenantId, ResourceGroupId rgId, ExecutionStatus status);

}
