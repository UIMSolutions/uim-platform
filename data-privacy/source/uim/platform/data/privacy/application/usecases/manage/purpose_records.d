/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data.privacy.application.usecases.manage.purpose_records;

import uim.platform.data.privacy;

mixin(ShowModule!());

@safe:
class ManagePurposeRecordsUseCase : UIMUseCase {
  private PurposeRecordRepository repo;

  this(PurposeRecordRepository repo) {
    this.repo = repo;
  }

  CommandResult createRecord(CreatePurposeRecordRequest req) {
    if (req.tenantId.isEmpty)
      return CommandResult("", "Tenant ID is required");
    if (req.dataSubjectid.isEmpty)
      return CommandResult("", "Data subject ID is required");

    auto now = Clock.currStdTime();
    auto r = PurposeRecord();
    r.id = randomUUID().toString();
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
    return CommandResult(r.id, "");
  }

  PurposeRecord* getRecord(PurposeRecordId id, TenantId tenantId) {
    return repo.findById(id, tenantId);
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
    if (r is null)
      return CommandResult("", "Purpose record not found");
    if (r.status == PurposeRecordStatus.deactivated)
      return CommandResult("", "Purpose record already deactivated");

    r.status = PurposeRecordStatus.deactivated;
    r.deactivatedAt = Clock.currStdTime();
    r.updatedAt = r.deactivatedAt;

    repo.update(*r);
    return CommandResult(r.id, "");
  }

  void deleteRecord(PurposeRecordId id, TenantId tenantId) {
    repo.remove(id, tenantId);
  }
}
