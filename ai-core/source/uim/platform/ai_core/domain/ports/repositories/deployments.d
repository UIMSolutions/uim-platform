/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.ai_core.domain.ports.repositories.deployments;
// import uim.platform.ai_core.domain.types;
// import uim.platform.ai_core.domain.entities.deployment;
import uim.platform.ai_core;
mixin(ShowModule!()); 

@safe:
interface DeploymentRepository : ITenantRepository!(Deployment, DeploymentId) {
  
  bool existsById(TenantId tenantId, ResourceGroupId rgId, DeploymentId id);
  Deployment findById(TenantId tenantId, ResourceGroupId rgId, DeploymentId id);
  void removeById(TenantId tenantId, ResourceGroupId rgId, DeploymentId id);

  size_t countByResourceGroup(TenantId tenantId, ResourceGroupId rgId);
  Deployment[] findByResourceGroup(TenantId tenantId, ResourceGroupId rgId);
  void removeByResourceGroup(TenantId tenantId, ResourceGroupId rgId);

  size_t countByConfiguration(TenantId tenantId, ResourceGroupId rgId, ConfigurationId confId);
  Deployment[] findByConfiguration(TenantId tenantId, ResourceGroupId rgId, ConfigurationId confId);
  void removeByConfiguration(TenantId tenantId, ResourceGroupId rgId, ConfigurationId confId);

  size_t countByScenario(TenantId tenantId, ResourceGroupId rgId, ScenarioId scenarioId);
  Deployment[] findByScenario(TenantId tenantId, ResourceGroupId rgId, ScenarioId scenarioId);
  void removeByScenario(TenantId tenantId, ResourceGroupId rgId, ScenarioId scenarioId);

  size_t countByStatus(TenantId tenantId, ResourceGroupId rgId, DeploymentStatus status);
  Deployment[] findByStatus(TenantId tenantId, ResourceGroupId rgId, DeploymentStatus status);
  void removeByStatus(TenantId tenantId, ResourceGroupId rgId, DeploymentStatus status);

}
