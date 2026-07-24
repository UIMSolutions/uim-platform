/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data_attribute_recommendation.infrastructure.persistence
  .repositories.model_configs;

// import uim.platform.data_attribute_recommendation.domain.entities.model_configuration;
// import uim.platform.data_attribute_recommendation.domain.ports.repositories.model_configs;
import uim.platform.data_attribute_recommendation;

mixin(ShowModule!());

@safe:
class MemoryModelConfigRepository : TenantRepository!(ModelConfiguration, ModelConfigurationId), IModelConfigRepository {

  // #region ByName
  bool existsByName(TenantId tenantId, string name) {
    return findByTenant(tenantId).any!(e => e.name == name);
  }

  ModelConfiguration findByName(TenantId tenantId, string name) {
    foreach (e; findByTenant(tenantId))
      if (e.name == name)
        return e;
    return ModelConfiguration.init;
  }

  void removeByName(TenantId tenantId, string name) {
    remove(findByName(tenantId, name));
  }
  // #endregion ByName

  // #region ByDataset
  size_t countByDataset(TenantId tenantId, DatasetId datasetId) {
    return findByDataset(tenantId, datasetId).length;
  }

  ModelConfiguration[] filterByDataset(ModelConfiguration[] configs, DatasetId datasetId) {
    return configs.filter!(e => e.datasetId == datasetId).array;
  }

  ModelConfiguration[] findByDataset(TenantId tenantId, DatasetId datasetId) {
    return filterByDataset(findByTenant(tenantId), datasetId);
  }

  void removeByDataset(TenantId tenantId, DatasetId datasetId) {
    findByDataset(tenantId, datasetId).each!(e => remove(e));
  }
  // #endregion ByDataset

  size_t countByStatus(TenantId tenantId, ModelConfigStatus status) {
    return findByStatus(tenantId, status).length;
  }

  ModelConfiguration[] filterByStatus(ModelConfiguration[] configs, ModelConfigStatus status) {
    return configs.filter!(e => e.status == status).array;
  }

  ModelConfiguration[] findByStatus(TenantId tenantId, ModelConfigStatus status) {
    return filterByStatus(findByTenant(tenantId), status);
  }

  void removeByStatus(TenantId tenantId, ModelConfigStatus status) {
    findByStatus(tenantId, status).each!(e => remove(e));
  }
}
///
unittest {
  mixin(ShowTest!("MemoryModelConfigRepository Tests"));

  void testExistsByName() {
    auto repo = new MemoryModelConfigRepository();
    auto tenantId = TenantId("tenant1");

    // Add a model configuration
    auto config = ModelConfiguration.init;
    config.id = ModelConfigurationId("config1");
    config.tenantId = tenantId;
    config.name = "myModel";
    repo.save(config);

    assert(repo.existsByName(tenantId, "myModel") == true);
    assert(repo.existsByName(tenantId, "nonExistentModel") == false);
  }

  void testFindByName() {
    auto repo = new MemoryModelConfigRepository();
    auto tenantId = TenantId("tenant1");

    // Add a model configuration
    auto config = ModelConfiguration.init;
    config.id = ModelConfigurationId("config1");
    config.tenantId = tenantId;
    config.name = "myModel";
    repo.save(config);

    auto foundConfig = repo.findByName(tenantId, "myModel");
    assert(foundConfig.id == ModelConfigurationId("config1"));
    assert(foundConfig.name == "myModel");

    auto notFoundConfig = repo.findByName(tenantId, "nonExistentModel");
    assert(notFoundConfig.id == ModelConfigurationId.init);
  } 

  void testRemoveByName() {
    auto repo = new MemoryModelConfigRepository();
    auto tenantId = TenantId("tenant1");

    // Add a model configuration
    auto config = ModelConfiguration.init;
    config.id = ModelConfigurationId("config1");
    config.tenantId = tenantId;
    config.name = "myModel";
    repo.save(config);

    assert(repo.existsByName(tenantId, "myModel") == true);

    repo.removeByName(tenantId, "myModel");
    assert(repo.existsByName(tenantId, "myModel") == false);
  }

  void testFindByDataset() {
    auto repo = new MemoryModelConfigRepository();
    auto tenantId = TenantId("tenant1");
    auto datasetId = DatasetId("dataset1");

    // Add a model configuration
    auto config = ModelConfiguration.init;
    config.id = ModelConfigurationId("config1");
    config.tenantId = tenantId;
    config.datasetId = datasetId;
    repo.save(config);

    auto configsByDataset = repo.findByDataset(tenantId, datasetId);
    assert(configsByDataset.length == 1);
    assert(configsByDataset[0].id == ModelConfigurationId("config1"));
  }

  void testRemoveByDataset() {
    auto repo = new MemoryModelConfigRepository();
    auto tenantId = TenantId("tenant1");
    auto datasetId = DatasetId("dataset1");

    // Add a model configuration
    auto config = ModelConfiguration.init;
    config.id = ModelConfigurationId("config1");
    config.tenantId = tenantId;
    config.datasetId = datasetId;
    repo.save(config);

    assert(repo.countByDataset(tenantId, datasetId) == 1);

    repo.removeByDataset(tenantId, datasetId);
    assert(repo.countByDataset(tenantId, datasetId) == 0);
  }

  void testFindByStatus() {
    auto repo = new MemoryModelConfigRepository();
    auto tenantId = TenantId("tenant1");
    auto status = ModelConfigStatus.ready;

    // Add a model configuration
    auto config = ModelConfiguration.init;
    config.id = ModelConfigurationId("config1");
    config.tenantId = tenantId;
    config.status = status;
    repo.save(config);

    auto configsByStatus = repo.findByStatus(tenantId, status);
    assert(configsByStatus.length == 1);
    assert(configsByStatus[0].id == ModelConfigurationId("config1"));
  }

  void testRemoveByStatus() {
    auto repo = new MemoryModelConfigRepository();
    auto tenantId = TenantId("tenant1");
    auto status = ModelConfigStatus.ready;

    // Add a model configuration
    auto config = ModelConfiguration.init;
    config.id = ModelConfigurationId("config1");
    config.tenantId = tenantId;
    config.status = status;
    repo.save(config);

    assert(repo.countByStatus(tenantId, status) == 1);

    repo.removeByStatus(tenantId, status);
    assert(repo.countByStatus(tenantId, status) == 0);
  }

  void testFilterByDataset() {
    auto repo = new MemoryModelConfigRepository();
    auto tenantId = TenantId("tenant1");
    auto datasetId1 = DatasetId("dataset1");
    auto datasetId2 = DatasetId("dataset2");

    // Add model configurations
    auto config1 = ModelConfiguration.init;
    config1.id = ModelConfigurationId("config1");
    config1.tenantId = tenantId;
    config1.datasetId = datasetId1;
    repo.save(config1);

    auto config2 = ModelConfiguration.init;
    config2.id = ModelConfigurationId("config2");
    config2.tenantId = tenantId;
    config2.datasetId = datasetId2;
    repo.save(config2);

    auto allConfigs = repo.findByTenant(tenantId);
    auto filteredConfigs = repo.filterByDataset(allConfigs, datasetId1);
    assert(filteredConfigs.length == 1);
    assert(filteredConfigs[0].id == ModelConfigurationId("config1"));
  }

  void testFilterByStatus() {
    auto repo = new MemoryModelConfigRepository();
    auto tenantId = TenantId("tenant1");
    auto status1 = ModelConfigStatus.ready;
    auto status2 = ModelConfigStatus.draft;

    // Add model configurations
    auto config1 = ModelConfiguration.init;
    config1.id = ModelConfigurationId("config1");
    config1.tenantId = tenantId;
    config1.status = status1;
    repo.save(config1);

    auto config2 = ModelConfiguration.init;
    config2.id = ModelConfigurationId("config2");
    config2.tenantId = tenantId;
    config2.status = status2;
    repo.save(config2);

    auto allConfigs = repo.findByTenant(tenantId);
    auto filteredConfigs = repo.filterByStatus(allConfigs, status1);
    assert(filteredConfigs.length == 1);
    assert(filteredConfigs[0].id == ModelConfigurationId("config1"));
  }

  void testCountByDataset() {
    auto repo = new MemoryModelConfigRepository();
    auto tenantId = TenantId("tenant1");
    auto datasetId = DatasetId("dataset1");

    // Add a model configuration
    auto config = ModelConfiguration.init;
    config.id = ModelConfigurationId("config1");
    config.tenantId = tenantId;
    config.datasetId = datasetId;
    repo.save(config);

    assert(repo.countByDataset(tenantId, datasetId) == 1);
  }

  void testCountByStatus() {
    auto repo = new MemoryModelConfigRepository();
    auto tenantId = TenantId("tenant1");
    auto status = ModelConfigStatus.ready;

    // Add a model configuration
    auto config = ModelConfiguration.init;
    config.id = ModelConfigurationId("config1");
    config.tenantId = tenantId;
    config.status = status;
    repo.save(config);

    assert(repo.countByStatus(tenantId, status) == 1);
  }

  void testRemoveNonExistentByName() {
    auto repo = new MemoryModelConfigRepository();
    auto tenantId = TenantId("tenant1");

    // Attempt to remove a non-existent model configuration by name
    repo.removeByName(tenantId, "nonExistentModel");
    // No exception should be thrown, and the repository should remain unchanged
    assert(repo.findByTenant(tenantId).length == 0);
  }

  void testRemoveNonExistentByDataset() {
    auto repo = new MemoryModelConfigRepository();
    auto tenantId = TenantId("tenant1");
    auto datasetId = DatasetId("nonExistentDataset");

    // Attempt to remove non-existent model configurations by dataset
    repo.removeByDataset(tenantId, datasetId);
    // No exception should be thrown, and the repository should remain unchanged
    assert(repo.findByTenant(tenantId).length == 0);
  }

  void testRemoveNonExistentByStatus() {
    auto repo = new MemoryModelConfigRepository();
    auto tenantId = TenantId("tenant1");
    auto status = ModelConfigStatus.ready;

    // Attempt to remove non-existent model configurations by status
    repo.removeByStatus(tenantId, status);
    // No exception should be thrown, and the repository should remain unchanged
    assert(repo.findByTenant(tenantId).length == 0);
  }

  void testRemoveByNameWithMultipleConfigs() {
    auto repo = new MemoryModelConfigRepository();
    auto tenantId = TenantId("tenant1");

    // Add multiple model configurations
    auto config1 = ModelConfiguration.init;
    config1.id = ModelConfigurationId("config1");
    config1.tenantId = tenantId;
    config1.name = "myModel";
    repo.save(config1);

    auto config2 = ModelConfiguration.init;
    config2.id = ModelConfigurationId("config2");
    config2.tenantId = tenantId;
    config2.name = "myModel"; // Same name as config1
    repo.save(config2);

    assert(repo.countByTenant(tenantId) == 2);

    // Remove by name should remove both configurations with the same name
    repo.removeByName(tenantId, "myModel");
    assert(repo.countByTenant(tenantId) == 0);
  }

  void allTests() {
    testExistsByName();
    testFindByName();
    testRemoveByName();
    testFindByDataset();
    testRemoveByDataset();
    testFindByStatus();
    testRemoveByStatus();
    testFilterByDataset();
    testFilterByStatus();
    testCountByDataset();
    testCountByStatus();
    testRemoveNonExistentByName();
    testRemoveNonExistentByDataset();
    testRemoveNonExistentByStatus();
    testRemoveByNameWithMultipleConfigs();
  }
}