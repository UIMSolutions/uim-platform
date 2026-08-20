/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data_privacy.application.usecases.manage.consent_records;

// import uim.platform.data_privacy.domain.entities.consent_record;
// import uim.platform.data_privacy.domain.ports.repositories.consent_records;
// import uim.platform.data_privacy.domain.ports.repositories.data_subjects;
// import uim.platform.data_privacy.application.dto;
import uim.platform.data_privacy;

mixin(ShowModule!());

@safe:
class ManageConsentRecordsUseCase {
  protected IConsentRecordRepository repo;
  private IDataSubjectRepository subjectRepo;

  this(IConsentRecordRepository repo, IDataSubjectRepository subjectRepo) {
    this.repo = repo;
    this.subjectRepo = subjectRepo;
  }

  UsecaseResult grantConsent(CreateConsentRecordRequest req) {
    if (req.tenantId.isEmpty)
      return UsecaseResult(false, "", "Tenant ID is required");
    if (req.dataSubjectId.isEmpty)
      return UsecaseResult(false, "", "Data subject ID is required");
    if (req.consentText.length == 0)
      return UsecaseResult(false, "", "Consent text is required");

    auto subject = subjectRepo.findById(req.tenantId, req.dataSubjectId);
    if (subject.isNull)
      return UsecaseResult(false, "", "Data subject not found");

    auto record = ConsentRecord(req.tenantId);
    record.dataSubjectId = req.dataSubjectId;
    record.purpose = req.purpose.toProcessingPurpose;
    record.categories = req.categories.map!(c => c.toPersonalDataCategory).array;
    record.status = ConsentStatus.granted;
    record.channel = req.channel;
    record.consentText = req.consentText;
    record.version_ = req.version_;
    record.ipAddress = req.ipAddress;
    record.grantedAt = record.createdAt;
    record.expiresAt = req.expiresAt;

    repo.save(record);
    return UsecaseResult(true, record.id.value, "");
  }

  ConsentRecord getConsent(TenantId tenantId, ConsentRecordId id) {
    return repo.findById(tenantId, id);
  }

  ConsentRecord[] listConsents(TenantId tenantId) {
    return repo.findByTenant(tenantId);
  }

  ConsentRecord[] listConsents(TenantId tenantId, DataSubjectId subjectId) {
    return repo.findByDataSubject(tenantId, subjectId);
  }

  ConsentRecord[] listConsents(TenantId tenantId, ProcessingPurpose purpose) {
    return repo.findByPurpose(tenantId, purpose);
  }

  ConsentRecord[] listActiveConsents(TenantId tenantId, DataSubjectId subjectId) {
    return repo.findActiveConsents(tenantId, subjectId);
  }

  ConsentRecord[] listActiveConsents(TenantId tenantId) {
    return repo.findActiveConsents(tenantId);
  }

  UsecaseResult revokeConsent(RevokeConsentRequest req) {
    auto record = repo.findById(req.tenantId, req.recordId);
    if (record.isNull)
      return UsecaseResult(false, "", "Consent record not found");
    if (record.status == ConsentStatus.revoked)
      return UsecaseResult(false, "", "Consent already revoked");

    record.status = ConsentStatus.revoked;
    record.revokedAt = currentTimestamp();

    repo.update(record);
    return UsecaseResult(true, record.id.value, "");
  }

  UsecaseResult deleteConsent(TenantId tenantId, ConsentRecordId id) {
    auto record = repo.findById(tenantId, id);
    if (record.isNull)
      return UsecaseResult(false, "", "Consent record not found");

    repo.remove(record);
    return UsecaseResult(true, record.id.value, "");
  }
}
