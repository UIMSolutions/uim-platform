/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data.privacy.domain.ports.repositories.consent_records;

// import uim.platform.data.privacy.domain.types;
// import uim.platform.data.privacy.domain.entities.consent_record;
import uim.platform.data.privacy;

mixin(ShowModule!());

@safe:
/// Port for persisting consent records.
interface ConsentRecordRepository : ITenantRepository!(ConsentRecord, ConsentRecordId) {

  size_t countByDataSubject(TenantId tenantId, DataSubjectId dataSubjectId);
  ConsentRecord[] findByDataSubject(TenantId tenantId, DataSubjectId dataSubjectId);
  void removeByDataSubject(TenantId tenantId, DataSubjectId dataSubjectId);

  size_t countByPurpose(TenantId tenantId, ProcessingPurpose purpose);
  ConsentRecord[] findByPurpose(TenantId tenantId, ProcessingPurpose purpose);
  void removeByPurpose(TenantId tenantId, ProcessingPurpose purpose);

  size_t countByStatus(TenantId tenantId, ConsentStatus status);
  ConsentRecord[] findByStatus(TenantId tenantId, ConsentStatus status);
  void removeByStatus(TenantId tenantId, ConsentStatus status);

  size_t countActiveConsents(TenantId tenantId, DataSubjectId dataSubjectId);
  ConsentRecord[] findActiveConsents(TenantId tenantId, DataSubjectId dataSubjectId);
  void removeActiveConsents(TenantId tenantId, DataSubjectId dataSubjectId);

}
