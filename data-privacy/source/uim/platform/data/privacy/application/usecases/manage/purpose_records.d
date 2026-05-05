/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data.privacy.application.usecases.manage.purpose_records;

import uim.platform.data.privacy;

mixin(ShowModule!());

@safe:
class ManagePurposeRecordsUseCase { // TODO: UIMUseCase {
  private PurposeRecordRepository repo;

  this(PurposeRecordRepository repo) {
    this.repo = repo;
  }

  CommandResult createRecord(CreatePurposeRecordRequest req) {
    if (req.tenantId.isEmpty)
      return CommandResult(false, "", "Tenant ID is required");
    if (req.dataSubjectId.isEmpty)
      return CommandResult(false, "", "Data subject ID is required");

    auto now = Clock.currStdTime();
    auto r = PurposeRecord();
    r.id = randomUUID();
    r.tenantId = req.tenantId;
    r.dataSubjectId = req.dataSubjectId;
    r.businessContextId = req.businessContextId;
    r.purpose = req.purpose;
    r.status = PurposeRecordStatus.active;
    r.legalBasis = req.legalBasis;
    r.residenceDays = req.residenceDays;
    r.retentionDays = req.retentionDays;
    r.validFrom = req.validFrom > 0 ? req.validFrom : now;
    r.validUntil = req.validUntil;
    r.createdAt = now;
    r.updatedAt = now;

    repo.save(r);
    return CommandResult(r.id.value, "");
  }

  PurposeRecord getRecord(TenantId tenantId, PurposeRecordId id) {
    return repo.findById(tenantId, id);
  }

  PurposeRecord[] listRecords(TenantId tenantId) {
    return repo.findByTenant(tenantId);
  }

  PurposeRecord[] listByDataSubject(TenantId tenantId, DataSubjectId subjectId) {
    return repo.findByDataSubject(tenantId, subjectId);
  }

  PurposeRecord[] listByStatus(TenantId tenantId, PurposeRecordStatus status) {
    return repo.findByStatus(tenantId, status);
  }

  CommandResult deactivateRecord(DeactivatePurposeRecordRequest req) {
    auto r = repo.findById(req.id, req.tenantId);
    if (r.isNull)
      return CommandResult(false, "", "Purpose record not found");
    if (r.status == PurposeRecordStatus.deactivated)
      return CommandResult(false, "", "Purpose record already deactivated");

    r.status = PurposeRecordStatus.deactivated;
    r.deactivatedAt = Clock.currStdTime();
    r.updatedAt = r.deactivatedAt;

    repo.update(r);
    return CommandResult(true, r.id.value, "");
  }

  CommandResult deleteRecord(TenantId tenantId, PurposeRecordId id) {
    auto r = repo.findById(tenantId, id);
    if (r.isNull)
      return CommandResult(false, "", "Purpose record not found");

    repo.removeById(tenantId, id);
    return CommandResult(true, id.value, "");
  }
}
