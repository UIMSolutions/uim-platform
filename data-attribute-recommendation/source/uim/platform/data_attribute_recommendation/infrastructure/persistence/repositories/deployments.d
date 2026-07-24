/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data_attribute_recommendation.infrastructure.persistence.repositories.deployments;

// import uim.platform.data_attribute_recommendation.domain.entities.model_deployment;
// import uim.platform.data_attribute_recommendation.domain.ports.repositories.deployments;
import uim.platform.data_attribute_recommendation;

mixin(ShowModule!());

@safe:
class MemoryDeploymentRepository : TenantRepository!(ModelDeployment, DeploymentId), IDeploymentRepository {

  bool existsByTrainingJob(TenantId tenantId, TrainingJobId jobId) {
    return findByTenant(tenantId).any!(e => e.trainingJobId == jobId);
  }

  ModelDeployment findByTrainingJob(TenantId tenantId, TrainingJobId jobId) {
    foreach (e; findByTenant(tenantId))
      if (e.trainingJobId == jobId)
        return e;
    return ModelDeployment.init;
  }

  void removeByTrainingJob(TenantId tenantId, TrainingJobId jobId) {
    remove(findByTrainingJob(tenantId, jobId));
  }

  size_t countByModelConfig(TenantId tenantId, ModelConfigurationId configId) {
    return findByModelConfig(tenantId, configId).length;
  }

  ModelDeployment[] filterByModelConfig(ModelDeployment[] deployments, ModelConfigurationId configId) {
    return deployments.filter!(e => e.modelConfigId == configId).array;
  }

  ModelDeployment[] findByModelConfig(TenantId tenantId, ModelConfigurationId configId) {
    return filterByModelConfig(findByTenant(tenantId), configId);
  }

  void removeByModelConfig(TenantId tenantId, ModelConfigurationId configId) {
    findByModelConfig(tenantId, configId).each!(e => remove(e));
  }

  size_t countByStatus(TenantId tenantId, DeploymentStatus status) {
    return findByStatus(tenantId, status).length;
  }

  ModelDeployment[] filterByStatus(ModelDeployment[] deployments, DeploymentStatus status) {
    return deployments.filter!(e => e.status == status).array;
  }

  ModelDeployment[] findByStatus(TenantId tenantId, DeploymentStatus status) {
    return filterByStatus(findByTenant(tenantId), status);
  }

  void removeByStatus(TenantId tenantId, DeploymentStatus status) {
    findByStatus(tenantId, status).each!(e => remove(e));
  }

}
///
unittest {
  import uim.platform.data_attribute_recommendation.domain.entities.model_deployment;
  import uim.platform.data_attribute_recommendation.domain.ports.model_configs;
  import uim.platform.data_attribute_recommendation.domain.ports.training_jobs;
  import uim.platform.data_attribute_recommendation.domain.ports.deployments;

  void testDeploymentRepository() {
    auto repo = new MemoryDeploymentRepository();
    auto tenantId = TenantId("1");
    
    auto deployment1 = ModelDeployment(tenantId);
    deployment1.modelConfigId = ModelConfigurationId("1");
    deployment1.trainingJobId = TrainingJobId("1");
    deployment1.status = DeploymentStatus.active;
    repo.save(deployment1);

    auto deployment2 = ModelDeployment(tenantId);
    deployment2.modelConfigId = ModelConfigurationId("1");
    deployment2.trainingJobId = TrainingJobId("2");
    deployment2.status = DeploymentStatus.inactive;
    repo.save(deployment2);

    assert(repo.countByModelConfig(tenantId, ModelConfigurationId("1")) == 2);
    assert(repo.countByStatus(tenantId, DeploymentStatus.active) == 1);
    assert(repo.countByStatus(tenantId, DeploymentStatus.inactive) == 1);

    repo.removeByTrainingJob(tenantId, TrainingJobId("1"));
    assert(repo.countByModelConfig(tenantId, ModelConfigurationId("1")) == 1);
    assert(repo.countByStatus(tenantId, DeploymentStatus.active) == 0);
  }

  void testDeploymentRepositoryWithEmptyTenant() {
    auto repo = new MemoryDeploymentRepository();
    auto tenantId = TenantId("1");
    
    auto deployment1 = ModelDeployment(tenantId);
    deployment1.modelConfigId = ModelConfigurationId("1");
    deployment1.trainingJobId = TrainingJobId("1");
    deployment1.status = DeploymentStatus.active;
    repo.save(deployment1);

    auto deployment2 = ModelDeployment(tenantId);
    deployment2.modelConfigId = ModelConfigurationId("1");
    deployment2.trainingJobId = TrainingJobId("2");
    deployment2.status = DeploymentStatus.inactive;
    repo.save(deployment2);

    auto emptyTenantId = TenantId("2");
    assert(repo.countByModelConfig(emptyTenantId, ModelConfigurationId("1")) == 0);
    assert(repo.countByStatus(emptyTenantId, DeploymentStatus.active) == 0);
    assert(repo.countByStatus(emptyTenantId, DeploymentStatus.inactive) == 0);

    repo.removeByTrainingJob(emptyTenantId, TrainingJobId("1"));
    assert(repo.countByModelConfig(emptyTenantId, ModelConfigurationId("1")) == 0);
    assert(repo.countByStatus(emptyTenantId, DeploymentStatus.active) == 0);
  }

  void testDeploymentRepositoryWithNonExistentTrainingJob() {
    auto repo = new MemoryDeploymentRepository();
    auto tenantId = TenantId("1");
    
    auto deployment1 = ModelDeployment(tenantId);
    deployment1.modelConfigId = ModelConfigurationId("1");
    deployment1.trainingJobId = TrainingJobId("1");
    deployment1.status = DeploymentStatus.active;
    repo.save(deployment1);

    auto deployment2 = ModelDeployment(tenantId);
    deployment2.modelConfigId = ModelConfigurationId("1");
    deployment2.trainingJobId = TrainingJobId("2");
    deployment2.status = DeploymentStatus.inactive;
    repo.save(deployment2);

    assert(repo.countByModelConfig(tenantId, ModelConfigurationId("1")) == 2);
    assert(repo.countByStatus(tenantId, DeploymentStatus.active) == 1);
    assert(repo.countByStatus(tenantId, DeploymentStatus.inactive) == 1);

    repo.removeByTrainingJob(tenantId, TrainingJobId("3")); // Non-existent training job
    assert(repo.countByModelConfig(tenantId, ModelConfigurationId("1")) == 2);
    assert(repo.countByStatus(tenantId, DeploymentStatus.active) == 1);
  }

  void testDeploymentRepositoryByModelConfig() {
    auto repo = new MemoryDeploymentRepository();
    auto tenantId = TenantId("1");
    
    auto deployment1 = ModelDeployment(tenantId);
    deployment1.modelConfigId = ModelConfigurationId("1");
    deployment1.trainingJobId = TrainingJobId("1");
    deployment1.status = DeploymentStatus.active;
    repo.save(deployment1);

    auto deployment2 = ModelDeployment(tenantId);
    deployment2.modelConfigId = ModelConfigurationId("1");
    deployment2.trainingJobId = TrainingJobId("2");
    deployment2.status = DeploymentStatus.inactive;
    repo.save(deployment2);
    
    auto deployment3 = ModelDeployment(tenantId);
    deployment3.modelConfigId = ModelConfigurationId("2");
    deployment3.trainingJobId = TrainingJobId("3");
    deployment3.status = DeploymentStatus.active;
    repo.save(deployment3);

    assert(repo.countByModelConfig(tenantId, ModelConfigurationId("1")) == 2);
    assert(repo.countByModelConfig(tenantId, ModelConfigurationId("2")) == 1);

    repo.removeByModelConfig(tenantId, ModelConfigurationId("1"));
    assert(repo.countByModelConfig(tenantId, ModelConfigurationId("1")) == 0);
    assert(repo.countByModelConfig(tenantId, ModelConfigurationId("2")) == 1);
  } 

  void testDeploymentRepositoryByStatus() {
    auto repo = new MemoryDeploymentRepository();
    auto tenantId = TenantId("1");
    
    auto deployment1 = ModelDeployment(tenantId);
    deployment1.modelConfigId = ModelConfigurationId("1");
    deployment1.trainingJobId = TrainingJobId("1");
    deployment1.status = DeploymentStatus.active;
    repo.save(deployment1);

    auto deployment2 = ModelDeployment(tenantId);
    deployment2.modelConfigId = ModelConfigurationId("1");
    deployment2.trainingJobId = TrainingJobId("2");
    deployment2.status = DeploymentStatus.inactive;
    repo.save(deployment2);
    
    auto deployment3 = ModelDeployment(tenantId);
    deployment3.modelConfigId = ModelConfigurationId("2");
    deployment3.trainingJobId = TrainingJobId("3");
    deployment3.status = DeploymentStatus.active;
    repo.save(deployment3); 

    assert(repo.countByStatus(tenantId, DeploymentStatus.active) == 2);
    assert(repo.countByStatus(tenantId, DeploymentStatus.inactive) == 1); 

    repo.removeByStatus(tenantId, DeploymentStatus.active);
    assert(repo.countByStatus(tenantId, DeploymentStatus.active) == 0);
    assert(repo.countByStatus(tenantId, DeploymentStatus.inactive) == 1); 
  }

  void allTests() {
    testDeploymentRepository();
    testDeploymentRepositoryWithEmptyTenant();
    testDeploymentRepositoryWithNonExistentTrainingJob();
    testDeploymentRepositoryByModelConfig();
    testDeploymentRepositoryByStatus();
  };

  allTests();
}
