/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data.privacy.domain.ports.usescases.consent_records;

// import uim.platform.data.privacy.domain.entities.consent_record;
// import uim.platform.data.privacy.domain.ports.repositories.consent_records;
// import uim.platform.data.privacy.domain.ports.repositories.data_subjects;
// import uim.platform.data.privacy.application.dto;
import uim.platform.data.privacy;

mixin(ShowModule!());

@safe:
interface IManageConsentRecordsUseCase { 

  CommandResult grantConsent(CreateConsentRecordRequest req);
  ConsentRecord getConsent(TenantId tenantId, ConsentRecordId id);
  ConsentRecord[] listConsents(TenantId tenantId);
  ConsentRecord[] listConsents(TenantId tenantId, DataSubjectId subjectId);
  ConsentRecord[] listConsents(TenantId tenantId, ProcessingPurpose purpose);
  ConsentRecord[] listActiveConsents(TenantId tenantId, DataSubjectId subjectId);
  ConsentRecord[] listActiveConsents(TenantId tenantId);
  CommandResult revokeConsent(RevokeConsentRequest req);
  CommandResult deleteConsent(TenantId tenantId, ConsentRecordId id);
  
}
