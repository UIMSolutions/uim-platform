/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data.privacy.infrastructure.persistence.memory.consent_records;

// import uim.platform.data.privacy.domain.types;
// import uim.platform.data.privacy.domain.entities.consent_record;
// import uim.platform.data.privacy.domain.ports.repositories.consent_records;
import uim.platform.data.privacy;

mixin(ShowModule!());

@safe:
class MemoryConsentRecordRepository : TenantRepository!(ConsentRecord, ConsentRecordId), ConsentRecordRepository {

  size_t countByDataSubject(TenantId tenantId, DataSubjectId dataSubjectId) {
    return findByDataSubject(tenantId, dataSubjectId).length;
  }

  ConsentRecord[] filterByDataSubject(ConsentRecord[] records, DataSubjectId dataSubjectId) {
    return records.filter!(r => r.dataSubjectId == dataSubjectId).array;
  }

  ConsentRecord[] findByDataSubject(TenantId tenantId, DataSubjectId dataSubjectId) {
    return findByTenant(tenantId).filterByDataSubject(dataSubjectId);
  }

  void removeByDataSubject(TenantId tenantId, DataSubjectId dataSubjectId) {
    findByDataSubject(tenantId, dataSubjectId).removeAll;
  }

  size_t countByPurpose(TenantId tenantId, ProcessingPurpose purpose) {
    return findByPurpose(tenantId, purpose).length;
  }

  ConsentRecord[] filterByPurpose(ConsentRecord[] records, ProcessingPurpose purpose) {
    return records.filter!(r => r.purpose == purpose).array;
  }

  ConsentRecord[] findByPurpose(TenantId tenantId, ProcessingPurpose purpose) {
    return findByTenant(tenantId).filterByPurpose(purpose);
  }

  void removeByPurpose(TenantId tenantId, ProcessingPurpose purpose) {
    findByPurpose(tenantId, purpose).removeAll;
  }

  size_t countByStatus(TenantId tenantId, ConsentStatus status) {
    return findByStatus(tenantId, status).length;
  }

  ConsentRecord[] filterByStatus(ConsentRecord[] records, ConsentStatus status) {
    return records.filter!(r => r.status == status).array;
  }

  ConsentRecord[] findByStatus(TenantId tenantId, ConsentStatus status) {
    return findByTenant(tenantId).filterByStatus(status);
  }

  void removeByStatus(TenantId tenantId, ConsentStatus status) {
    findByStatus(tenantId, status).removeAll;
  }

  size_t countActiveConsents(TenantId tenantId, DataSubjectId dataSubjectId) {
    return findActiveConsents(tenantId, dataSubjectId).length;
  }

  ConsentRecord[] filterActiveConsents(ConsentRecord[] records, DataSubjectId dataSubjectId) {
    return records.filter!(r => r.dataSubjectId == dataSubjectId && r.status == ConsentStatus.granted).array;
  }

  ConsentRecord[] findActiveConsents(TenantId tenantId, DataSubjectId dataSubjectId) {
    return findByTenant(tenantId).filterActiveConsents(dataSubjectId);
  }

  void removeActiveConsents(TenantId tenantId, DataSubjectId dataSubjectId) {
    findActiveConsents(tenantId, dataSubjectId).removeAll;
  }

}
