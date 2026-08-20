/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data_privacy.domain.ports.usecases.consent_records;

// import uim.platform.data_privacy.domain.entities.consent_record;
// import uim.platform.data_privacy.domain.ports.repositories.consent_records;
// import uim.platform.data_privacy.domain.ports.repositories.data_subjects;
// import uim.platform.data_privacy.application.dto;
import uim.platform.data_privacy;

mixin(ShowModule!());

@safe:
interface IManageConsentRecordsUseCase { 

  UsecaseResult grantConsent(CreateConsentRecordRequest req);
  ConsentRecord getConsent(TenantId tenantId, ConsentRecordId id);
  ConsentRecord[] listConsents(TenantId tenantId);
  ConsentRecord[] listConsents(TenantId tenantId, DataSubjectId subjectId);
  ConsentRecord[] listConsents(TenantId tenantId, ProcessingPurpose purpose);
  ConsentRecord[] listActiveConsents(TenantId tenantId, DataSubjectId subjectId);
  ConsentRecord[] listActiveConsents(TenantId tenantId);
  UsecaseResult revokeConsent(RevokeConsentRequest req);
  UsecaseResult deleteConsent(TenantId tenantId, ConsentRecordId id);
  
}
