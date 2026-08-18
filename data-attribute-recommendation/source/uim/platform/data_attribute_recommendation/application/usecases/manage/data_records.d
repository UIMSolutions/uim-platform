/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data_attribute_recommendation.application.usecases.manage.data_records;

// import uim.platform.data_attribute_recommendation.domain.entities.data_record;





import uim.platform.data_attribute_recommendation;

mixin(ShowModule!());

@safe:
class ManageDataRecordsUseCase {
  protected IDataRecordRepository repo;
  private IDatasetRepository datasetRepo;

  this(IDataRecordRepository repo, IDatasetRepository datasetRepo) {
    this.repo = repo;
    this.datasetRepo = datasetRepo;
  }

  UsecaseResult createDataRecord(CreateDataRecordRequest req) {
    if (req.tenantId.isEmpty)
      return UsecaseResult(false, "", "Tenant ID is required");

    if (req.datasetId.isEmpty)
      return UsecaseResult(false, "", "Dataset ID is required");

    if (req.attributes.length == 0)
      return UsecaseResult(false, "", "Attributes are required");

    // Verify dataset exists and is still mutable
    auto ds = datasetRepo.findById(req.tenantId, req.datasetId);
    if (ds.isNull)
      return UsecaseResult(false, "", "Dataset not found");

    if (ds.status != DatasetStatus.draft && ds.status != DatasetStatus.ready)
      return UsecaseResult(false, "", "Cannot add records to a processed or completed dataset");

    auto record = DataRecord(req.tenantId, DataRecordId(createId), req.createdBy);
    record.datasetId = req.datasetId;
    record.tenantId = req.tenantId;
    record.attributes = req.attributes;
    record.labels = req.labels;
    record.status = RecordStatus.pending;

    repo.save(record);
    return UsecaseResult(true, record.id.value, "");
  }

  DataRecord getDataRecord(TenantId tenantId, DataRecordId id) {
    return repo.findById(tenantId, id);
  }

  DataRecord[] listDataRecords(TenantId tenantId, DatasetId datasetId) {
    return repo.findByDataset(tenantId, datasetId);
  }

  UsecaseResult validateDataRecord(TenantId tenantId, DataRecordId id) {
    auto record = repo.findById(tenantId, id);
    if (record.isNull)
      return UsecaseResult(false, "", "Record not found");

    record.status = RecordStatus.validated;
    repo.update(record);
    return UsecaseResult(true, record.id.value, "");
  }

  UsecaseResult rejectDataRecord(TenantId tenantId, DataRecordId id) {
    auto record = repo.findById(tenantId, id);
    if (record.isNull)
      return UsecaseResult(false, "", "Record not found");

    record.status = RecordStatus.rejected;
    repo.update(record);
    return UsecaseResult(true, record.id.value, "");
  }

  UsecaseResult deleteDataRecord(TenantId tenantId, DataRecordId id) {
    auto existing = repo.findById(tenantId, id);
    if (existing.isNull)
      return UsecaseResult(false, "", "Record not found");

    repo.remove(existing);
    return UsecaseResult(true, existing.id.value, "");
  }
}

///
unittest {
    auto iDataRecordRepository = new IDataRecordRepository();
    auto iDatasetRepository = new IDatasetRepository();
    auto usecase = new ManageDataRecordsUseCase(iDataRecordRepository, iDatasetRepository);
    auto tenantId = TenantId("test-tenant");

}
