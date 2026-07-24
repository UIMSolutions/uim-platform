/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data_attribute_recommendation.infrastructure.persistence.repositories.datasets;


import uim.platform.data_attribute_recommendation;

mixin(ShowModule!());

@safe:
class MemoryDatasetRepository : TenantRepository!(Dataset, DatasetId), IDatasetRepository {

  // #region ByName
  bool existsByName(TenantId tenantId, string name) {
    return findByTenant(tenantId).any!(e => e.name == name);
  }

  Dataset findByName(TenantId tenantId, string name) {
    foreach (e; findByTenant(tenantId))
      if (e.name == name)
        return e;
    return Dataset.init;
  }

  void removeByName(TenantId tenantId, string name) {
    remove(findByName(tenantId, name));
  }
  // #endregion ByName

  size_t countByStatus(TenantId tenantId, DatasetStatus status) {
    return findByStatus(tenantId, status).length;
  }

  Dataset[] filterByStatus(Dataset[] datasets, DatasetStatus status) {
    return datasets.filter!(e => e.status == status).array;
  }

  Dataset[] findByStatus(TenantId tenantId, DatasetStatus status) {
    return filterByStatus(findByTenant(tenantId), status);
  }

  void removeByStatus(TenantId tenantId, DatasetStatus status) {
    findByStatus(tenantId, status).each!(e => remove(e));
  }

  // #region ByDataType
  size_t countByDataType(TenantId tenantId, DataType dataType) {
    return findByDataType(tenantId, dataType).length;
  }

  Dataset[] filterByDataType(Dataset[] datasets, DataType dataType) {
    return datasets.filter!(e => e.dataType == dataType).array;
  }

  Dataset[] findByDataType(TenantId tenantId, DataType dataType) {
    return filterByDataType(findByTenant(tenantId), dataType);
  }

  void removeByDataType(TenantId tenantId, DataType dataType) {
    findByDataType(tenantId, dataType).each!(e => remove(e));
  }
  // #endregion ByDataType

}
///
unittest {
  import std.stdio;
  import std.array;
  import std.algorithm;
  import std.exception;

  void testDatasetRepositoryWithEmptyTenant() {
    auto repo = new MemoryDatasetRepository();
    auto tenantId = TenantId("1");
    
    auto dataset1 = Dataset(tenantId);
    dataset1.name = "Dataset 1";
    dataset1.status = DatasetStatus.ready;
    dataset1.dataType = DataType.product;
    repo.save(dataset1);

    auto dataset2 = Dataset(tenantId);
    dataset2.name = "Dataset 2";
    dataset2.status = DatasetStatus.draft;
    dataset2.dataType = DataType.custom;
    repo.save(dataset2);

    auto emptyTenantId = TenantId("2");

    assert(repo.countByTenant(emptyTenantId) == 0);
    assert(repo.findByTenant(emptyTenantId).length == 0);
  }

  void testDatasetRepositoryWithNonEmptyTenant() {
    auto repo = new MemoryDatasetRepository();
    auto tenantId = TenantId("1");
    
    auto dataset1 = Dataset(tenantId);
    dataset1.name = "Dataset 1";
    dataset1.status = DatasetStatus.ready;
    dataset1.dataType = DataType.product;
    repo.save(dataset1);

    auto dataset2 = Dataset(tenantId);
    dataset2.name = "Dataset 2";
    dataset2.status = DatasetStatus.draft;
    dataset2.dataType = DataType.custom;
    repo.save(dataset2);

    assert(repo.countByTenant(tenantId) == 2);
    assert(repo.findByTenant(tenantId).length == 2);
  }

  void testDatasetRepositoryByName() {
    auto repo = new MemoryDatasetRepository();
    auto tenantId = TenantId("1");
    
    auto dataset1 = Dataset(tenantId);
    dataset1.name = "Dataset 1";
    repo.save(dataset1);

    assert(repo.existsByName(tenantId, "Dataset 1"));
    assert(!repo.existsByName(tenantId, "Nonexistent Dataset"));

    auto foundDataset = repo.findByName(tenantId, "Dataset 1");
    assert(foundDataset.name == "Dataset 1");

    repo.removeByName(tenantId, "Dataset 1");
    assert(!repo.existsByName(tenantId, "Dataset 1"));
  }

  void testDatasetRepositoryByStatus() {
    auto repo = new MemoryDatasetRepository();
    auto tenantId = TenantId("1");
    
    auto dataset1 = Dataset(tenantId);
    dataset1.status = DatasetStatus.ready;
    repo.save(dataset1);

    auto dataset2 = Dataset(tenantId);
    dataset2.status = DatasetStatus.draft;
    repo.save(dataset2);

    assert(repo.countByStatus(tenantId, DatasetStatus.ready) == 1);
    assert(repo.countByStatus(tenantId, DatasetStatus.draft) == 1);

    repo.removeByStatus(tenantId, DatasetStatus.ready);
    assert(repo.countByStatus(tenantId, DatasetStatus.ready) == 0);
  }

  void testDatasetRepositoryByDataType() {
    auto repo = new MemoryDatasetRepository();
    auto tenantId = TenantId("1");
    
    auto dataset1 = Dataset(tenantId);
    dataset1.dataType = DataType.product;
    repo.save(dataset1);

    auto dataset2 = Dataset(tenantId);
    dataset2.dataType = DataType.custom;
    repo.save(dataset2);

    assert(repo.countByDataType(tenantId, DataType.product) == 1);
    assert(repo.countByDataType(tenantId, DataType.custom) == 1);

    repo.removeByDataType(tenantId, DataType.product);
    assert(repo.countByDataType(tenantId, DataType.product) == 0);
  }

  void testDatasetRepositoryWithMultipleTenants() {
    auto repo = new MemoryDatasetRepository();
    auto tenantId1 = TenantId("1");
    auto tenantId2 = TenantId("2");
    
    auto dataset1 = Dataset(tenantId1);
    dataset1.name = "Tenant 1 Dataset";
    repo.save(dataset1);

    auto dataset2 = Dataset(tenantId2);
    dataset2.name = "Tenant 2 Dataset";
    repo.save(dataset2);

    assert(repo.countByTenant(tenantId1) == 1);
    assert(repo.countByTenant(tenantId2) == 1);

    assert(repo.findByName(tenantId1, "Tenant 1 Dataset").name == "Tenant 1 Dataset");
    assert(repo.findByName(tenantId2, "Tenant 2 Dataset").name == "Tenant 2 Dataset");
  }

  void testDatasetRepositoryWithNonexistentDataset() {
    auto repo = new MemoryDatasetRepository();
    auto tenantId = TenantId("1");
    
    assert(!repo.existsByName(tenantId, "Nonexistent Dataset"));
    assert(repo.findByName(tenantId, "Nonexistent Dataset").id == DatasetId.init);
  }

  void testDatasetRepositoryWithMultipleDatasets() {
    auto repo = new MemoryDatasetRepository();
    auto tenantId = TenantId("1");
    
    auto dataset1 = Dataset(tenantId);
    dataset1.name = "Dataset 1";
    dataset1.status = DatasetStatus.ready;
    dataset1.dataType = DataType.product;
    repo.save(dataset1);

    auto dataset2 = Dataset(tenantId);
    dataset2.name = "Dataset 2";
    dataset2.status = DatasetStatus.draft;
    dataset2.dataType = DataType.custom;
    repo.save(dataset2);

    assert(repo.countByTenant(tenantId) == 2);
    assert(repo.findByTenant(tenantId).length == 2);

    assert(repo.countByStatus(tenantId, DatasetStatus.ready) == 1);
    assert(repo.countByStatus(tenantId, DatasetStatus.draft) == 1);

    assert(repo.countByDataType(tenantId, DataType.product) == 1);
    assert(repo.countByDataType(tenantId, DataType.custom) == 1);
  }

  void allTests() {
    testDatasetRepositoryWithEmptyTenant();
    testDatasetRepositoryWithNonEmptyTenant();
    testDatasetRepositoryByName();
    testDatasetRepositoryByStatus();
    testDatasetRepositoryByDataType();
    testDatasetRepositoryWithMultipleTenants();
    testDatasetRepositoryWithNonexistentDataset();
    testDatasetRepositoryWithMultipleDatasets();
  }

  allTests();

}
