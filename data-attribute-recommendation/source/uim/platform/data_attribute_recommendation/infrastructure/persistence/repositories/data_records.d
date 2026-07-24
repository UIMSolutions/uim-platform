/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data_attribute_recommendation.infrastructure.persistence.repositories.data_records;

// import uim.platform.data_attribute_recommendation.domain.entities.data_record;

import uim.platform.data_attribute_recommendation;

mixin(ShowModule!());

@safe:
class DataRecordRepository : TenantRepository!(DataRecord, DataRecordId), IDataRecordRepository {

  // #region ByDataset
  size_t countByDataset(TenantId tenantId, DatasetId datasetId) {
    return findByDataset(tenantId, datasetId).length;
  }

  DataRecord[] filterByDataset(DataRecord[] records, DatasetId datasetId) {
    return records.filter!(e => e.datasetId == datasetId).array;
  }

  DataRecord[] findByDataset(TenantId tenantId, DatasetId datasetId) {
    return filterByDataset(findByTenant(tenantId), datasetId);
  }

  void removeByDataset(TenantId tenantId, DatasetId datasetId) {
    findByDataset(tenantId, datasetId).each!(e => remove(e));
  }
  // #endregion ByDataset

  // #region ByStatus
  size_t countByStatus(TenantId tenantId, DatasetId datasetId, RecordStatus status) {
    return findByStatus(tenantId, datasetId, status).length;
  }
  
  DataRecord[] filterByStatus(DataRecord[] records, RecordStatus status) {
    return records.filter!(e => e.status == status).array;
  }

  DataRecord[] findByStatus(TenantId tenantId, DatasetId datasetId, RecordStatus status) {
    return filterByStatus(findByDataset(tenantId, datasetId), status);
  }
  
  void removeByStatus(TenantId tenantId, DatasetId datasetId, RecordStatus status) {
    findByStatus(tenantId, datasetId, status).each!(e => remove(e));
  }
  // #endregion ByStatus

}
///
unittest {
  import uim.platform.data_attribute_recommendation.domain.entities.data_record;
  import uim.platform.data_attribute_recommendation.domain.ports.data_records;
  import uim.platform.data_attribute_recommendation.infrastructure.persistence.repositories.data_records;

  void testDataRecordRepository() {
    auto tenantId = TenantId("1");
    auto repo = new DataRecordRepository();
    assert(repo.countByTenant(tenantId) == 0);
    assert(repo.countByDataset(tenantId, DatasetId("1")) == 0);
    assert(repo.countByStatus(tenantId, DatasetId("1"), RecordStatus.pending) == 0);
  }

  void testDataRecordRepositoryWithRecords() {
    auto tenantId = TenantId("1");
    auto repo = new DataRecordRepository();
    auto record1 = DataRecord(tenantId);
    record1.datasetId = DatasetId("1");
    record1.status = RecordStatus.pending;
    repo.save(record1);

    auto record2 = DataRecord(tenantId);
    record2.datasetId = DatasetId("1");
    record2.status = RecordStatus.rejected;
    repo.save(record2);

    auto record3 = DataRecord(tenantId);
    record3.datasetId = DatasetId("2");
    record3.status = RecordStatus.pending;
    repo.save(record3);
    
    assert(repo.countByTenant(tenantId) == 3);
    assert(repo.countByDataset(tenantId, DatasetId("1")) == 2);
    assert(repo.countByDataset(tenantId, DatasetId("2")) == 1);
    assert(repo.countByStatus(tenantId, DatasetId("1"), RecordStatus.pending) == 1);
    assert(repo.countByStatus(tenantId, DatasetId("1"), RecordStatus.rejected) == 1);
    assert(repo.countByStatus(tenantId, DatasetId("2"), RecordStatus.pending) == 1);

    repo.removeByDataset(tenantId, DatasetId("1"));
    assert(repo.countByTenant(tenantId) == 1);
    assert(repo.countByDataset(tenantId, DatasetId("1")) == 0);
    assert(repo.countByDataset(tenantId, DatasetId("2")) == 1);
  }

  void testDataRecordRepositoryWithStatus() {
    auto tenantId = TenantId("1");
    auto repo = new DataRecordRepository();
    
    auto record1 = DataRecord(tenantId);
    record1.datasetId = DatasetId("1");
    record1.status = RecordStatus.pending;
    repo.save(record1);

    auto record2 = DataRecord(tenantId);
    record2.datasetId = DatasetId("1");
    record2.status = RecordStatus.rejected;
    repo.save(record2);
    
    auto record3 = DataRecord(tenantId);
    record3.datasetId = DatasetId("2");
    record3.status = RecordStatus.pending;
    repo.save(record3);

    assert(repo.countByStatus(tenantId, DatasetId("1"), RecordStatus.pending) == 1);
    assert(repo.countByStatus(tenantId, DatasetId("1"), RecordStatus.rejected) == 1);
    assert(repo.countByStatus(tenantId, DatasetId("2"), RecordStatus.pending) == 1);

    repo.removeByStatus(tenantId, DatasetId("1"), RecordStatus.pending);
    assert(repo.countByStatus(tenantId, DatasetId("1"), RecordStatus.pending) == 0);
    assert(repo.countByStatus(tenantId, DatasetId("1"), RecordStatus.rejected) == 1);
  }

  void testDataRecordRepositoryWithNonExistentRecords() {
    auto tenantId = TenantId("1");
    auto repo = new DataRecordRepository();
    
    auto record1 = DataRecord(tenantId);
    record1.datasetId = DatasetId("1");
    record1.status = RecordStatus.pending;
    repo.save(record1);

    auto record2 = DataRecord(tenantId);
    record2.datasetId = DatasetId("1");
    record2.status = RecordStatus.rejected;
    repo.save(record2);
    
    auto record3 = DataRecord(tenantId);
    record3.datasetId = DatasetId("2");
    record3.status = RecordStatus.pending;
    repo.save(record3);

    assert(repo.countByDataset(tenantId, DatasetId("3")) == 0);
    assert(repo.countByStatus(tenantId, DatasetId("3"), RecordStatus.pending) == 0);

    repo.removeByDataset(tenantId, DatasetId("3"));
    assert(repo.countByTenant(tenantId) == 3);

    repo.removeByStatus(tenantId, DatasetId("3"), RecordStatus.pending);
    assert(repo.countByTenant(tenantId) == 3);
  }

  void testDataRecordRepositoryWithMultipleTenants() {
    auto repo = new DataRecordRepository();
    auto tenantId1 = TenantId("1");
    auto tenantId2 = TenantId("2");
    auto record1 = DataRecord(tenantId1);
    record1.datasetId = DatasetId("1");
    record1.status = RecordStatus.pending;
    repo.save(record1);

    auto record2 = DataRecord(tenantId1);
    record2.datasetId = DatasetId("1");
    record2.status = RecordStatus.rejected;
    repo.save(record2);

    auto record3 = DataRecord(tenantId2);
    record3.datasetId = DatasetId("1");
    record3.status = RecordStatus.pending;
    repo.save(record3);

    assert(repo.countByTenant(tenantId1) == 2);
    assert(repo.countByTenant(tenantId2) == 1);

    assert(repo.countByDataset(tenantId1, DatasetId("1")) == 2);
    assert(repo.countByDataset(tenantId2, DatasetId("1")) == 1);

    assert(repo.countByStatus(tenantId1, DatasetId("1"), RecordStatus.pending) == 1);
    assert(repo.countByStatus(tenantId2, DatasetId("1"), RecordStatus.pending) == 1);
  }

  void testDataRecordRepositoryWithEmptyTenant() {
    auto repo = new DataRecordRepository();
    auto tenantId = TenantId("1");
    
    auto record1 = DataRecord(tenantId);
    record1.datasetId = DatasetId("1");
    record1.status = RecordStatus.pending;
    repo.save(record1);

    auto record2 = DataRecord(tenantId);
    record2.datasetId = DatasetId("1");
    record2.status = RecordStatus.rejected;
    repo.save(record2);

    auto emptyTenantId = TenantId("2");
    assert(repo.countByTenant(emptyTenantId) == 0);
    assert(repo.countByDataset(emptyTenantId, DatasetId("1")) == 0);
    assert(repo.countByStatus(emptyTenantId, DatasetId("1"), RecordStatus.pending) == 0);

    repo.removeByDataset(emptyTenantId, DatasetId("1"));
    assert(repo.countByTenant(tenantId) == 2);

    repo.removeByStatus(emptyTenantId, DatasetId("1"), RecordStatus.pending);
    assert(repo.countByTenant(tenantId) == 2);
  }

  void testDataRecordRepositoryWithEmptyDataset() {
    auto repo = new DataRecordRepository();
    auto tenantId = TenantId("1");
    
    auto record1 = DataRecord(tenantId);
    record1.datasetId = DatasetId("1");
    record1.status = RecordStatus.pending;
    repo.save(record1);

    auto record2 = DataRecord(tenantId);
    record2.datasetId = DatasetId("1");
    record2.status = RecordStatus.rejected;
    repo.save(record2);

    assert(repo.countByDataset(tenantId, DatasetId("2")) == 0);
    assert(repo.countByStatus(tenantId, DatasetId("2"), RecordStatus.pending) == 0);

    repo.removeByDataset(tenantId, DatasetId("2"));
    assert(repo.countByTenant(tenantId) == 2);

    repo.removeByStatus(tenantId, DatasetId("2"), RecordStatus.pending);
    assert(repo.countByTenant(tenantId) == 2);
  }

  void testDataRecordRepositoryWithEmptyStatus() {
    auto repo = new DataRecordRepository();
    auto tenantId = TenantId("1");

    auto record1 = DataRecord(tenantId);
    record1.datasetId = DatasetId("1");
    record1.status = RecordStatus.pending;
    repo.save(record1);
    
    auto record2 = DataRecord(tenantId);
    record2.datasetId = DatasetId("1");
    record2.status = RecordStatus.rejected;
    repo.save(record2);

    assert(repo.countByStatus(tenantId, DatasetId("1"), RecordStatus.rejected) == 1);

    repo.removeByStatus(tenantId, DatasetId("1"), RecordStatus.pending);
    assert(repo.countByTenant(tenantId) == 1);
  }

  void testDataRecordRepositoryWithEmptyRepository() {
    auto repo = new DataRecordRepository();

    auto tenantId = TenantId("1");
    assert(repo.countByTenant(tenantId) == 0);
    assert(repo.countByDataset(tenantId, DatasetId("1")) == 0);
    assert(repo.countByStatus(tenantId, DatasetId("1"), RecordStatus.pending) == 0);

    repo.removeByDataset(tenantId, DatasetId("1"));
    assert(repo.countByTenant(tenantId) == 0);

    repo.removeByStatus(tenantId, DatasetId("1"), RecordStatus.pending);
    assert(repo.countByTenant(tenantId) == 0);
  }

  void allTests() {
    testDataRecordRepository();
    testDataRecordRepositoryWithRecords();
    testDataRecordRepositoryWithStatus();
    testDataRecordRepositoryWithNonExistentRecords();
    testDataRecordRepositoryWithMultipleTenants();
    testDataRecordRepositoryWithEmptyTenant();
    testDataRecordRepositoryWithEmptyDataset();
    testDataRecordRepositoryWithEmptyStatus();
    testDataRecordRepositoryWithEmptyRepository();
  }

  allTests();

}
