/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data.privacy.application.usecases.manage_consent_records;

// import std.uuid;
// import std.datetime.systime : Clock;

import uim.platform.data.privacy.domain.types;
import uim.platform.data.privacy.domain.entities.consent_record;
import uim.platform.data.privacy.domain.ports.consent_record_repository;
import uim.platform.data.privacy.domain.ports.data_subject_repository;
import uim.platform.data.privacy.application.dto;

class ManageConsentRecordsUseCase
{
  private ConsentRecordRepository repo;
  private DataSubjectRepository subjectRepo;

  this(ConsentRecordRepository repo, DataSubjectRepository subjectRepo)
  {
    this.repo = repo;
    this.subjectRepo = subjectRepo;
  }

  CommandResult grantConsent(CreateConsentRecordRequest req)
  {
    if (req.tenantId.length == 0)
      return CommandResult("", "Tenant ID is required");
    if (req.dataSubjectId.length == 0)
      return CommandResult("", "Data subject ID is required");
    if (req.consentText.length == 0)
      return CommandResult("", "Consent text is required");

    auto subject = subjectRepo.findById(req.dataSubjectId, req.tenantId);
    if (subject is null)
      return CommandResult("", "Data subject not found");

    auto now = Clock.currStdTime();
    auto record = ConsentRecord();
    record.id = randomUUID().toString();
    record.tenantId = req.tenantId;
    record.dataSubjectId = req.dataSubjectId;
    record.purpose = req.purpose;
    record.categories = req.categories;
    record.status = ConsentStatus.granted;
    record.channel = req.channel;
    record.consentText = req.consentText;
    record.version_ = req.version_;
    record.ipAddress = req.ipAddress;
    record.grantedAt = now;
    record.expiresAt = req.expiresAt;
    record.createdAt = now;

    repo.save(record);
    return CommandResult(record.id, "");
  }

  ConsentRecord* getConsent(ConsentRecordId id, TenantId tenantId)
  {
    return repo.findById(id, tenantId);
  }

  ConsentRecord[] listConsents(TenantId tenantId)
  {
    return repo.findByTenant(tenantId);
  }

  ConsentRecord[] listByDataSubject(TenantId tenantId, DataSubjectId subjectId)
  {
    return repo.findByDataSubject(tenantId, subjectId);
  }

  ConsentRecord[] listByPurpose(TenantId tenantId, ProcessingPurpose purpose)
  {
    return repo.findByPurpose(tenantId, purpose);
  }

  ConsentRecord[] listActiveConsents(TenantId tenantId, DataSubjectId subjectId)
  {
    return repo.findActiveConsents(tenantId, subjectId);
  }

  CommandResult revokeConsent(RevokeConsentRequest req)
  {
    auto record = repo.findById(req.id, req.tenantId);
    if (record is null)
      return CommandResult("", "Consent record not found");
    if (record.status == ConsentStatus.revoked)
      return CommandResult("", "Consent already revoked");

    record.status = ConsentStatus.revoked;
    record.revokedAt = Clock.currStdTime();

    repo.update(*record);
    return CommandResult(record.id, "");
  }

  void deleteConsent(ConsentRecordId id, TenantId tenantId)
  {
    repo.remove(id, tenantId);
  }
}
