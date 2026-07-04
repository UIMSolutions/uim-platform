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
    if (req.subjectId.isEmpty)
      return CommandResult(false, "", "Data subject ID is required");

    auto r = PurposeRecord(req.tenantId);
    r.dataSubjectId = req.subjectId;
    r.businessContextId = req.contextId;
    r.purpose = req.purpose.toProcessingPurpose;
    r.status = PurposeRecordStatus.active;
    r.legalBasis = req.legalBasis.toLegalBasis;
    r.residenceDays = req.residenceDays;
    r.retentionDays = req.retentionDays;
    r.validFrom = req.validFrom > 0 ? req.validFrom : currentTimestamp;
    r.validUntil = req.validUntil;

    repo.save(r);
    return CommandResult(true, r.id.value, "");
  }

  PurposeRecord getRecord(TenantId tenantId, PurposeRecordId id) {
    return repo.findById(tenantId, id);
  }

  PurposeRecord[] listRecords(TenantId tenantId) {
    return repo.findByTenant(tenantId);
  }

  PurposeRecord[] listRecords(TenantId tenantId, DataSubjectId subjectId) {
    return repo.findByDataSubject(tenantId, subjectId);
  }

  PurposeRecord[] listRecords(TenantId tenantId, PurposeRecordStatus status) {
    return repo.findByStatus(tenantId, status);
  }

  CommandResult deactivateRecord(DeactivatePurposeRecordRequest req) {
    auto r = repo.findById(req.tenantId, req.recordId);
    if (r.isNull)
      return CommandResult(false, "", "Purpose record not found");
    if (r.status == PurposeRecordStatus.deactivated)
      return CommandResult(false, "", "Purpose record already deactivated");

    r.status = PurposeRecordStatus.deactivated;
    r.deactivatedAt = currentTimestamp();
    r.updatedAt = r.deactivatedAt;

    repo.update(r);
    return CommandResult(true, r.id.value, "");
  }

  CommandResult deleteRecord(TenantId tenantId, PurposeRecordId recordId) {
    auto r = repo.findById(tenantId, recordId);
    if (r.isNull)
      return CommandResult(false, "", "Purpose record not found");

    repo.remove(r);
    return CommandResult(true, r.id.value, "");
  }
}
