/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data.privacy.infrastructure.persistence.memory.purpose_records;

// import uim.platform.data.privacy.domain.types;
// import uim.platform.data.privacy.domain.entities.purpose_record;
// import uim.platform.data.privacy.domain.ports.repositories.purpose_records;
import uim.platform.data.privacy;

mixin(ShowModule!());

@safe:
class MemoryPurposeRecordRepository : TenantRepository!(PurposeRecord, PurposeRecordId), PurposeRecordRepository {

  size_t countByDataSubject(TenantId tenantId, DataSubjectId subjectId) {
    return findByDataSubject(tenantId, subjectId).length;
  }

  PurposeRecord[] filterByDataSubject(PurposeRecord[] records, DataSubjectId subjectId) {
    return records.filter!(s => s.dataSubjectId == subjectId).array;
  }

  PurposeRecord[] findByDataSubject(TenantId tenantId, DataSubjectId subjectId) {
    return filterByDataSubject(findByTenant(tenantId), subjectId);
  }

  void removeByDataSubject(TenantId tenantId, DataSubjectId subjectId) {
    findByDataSubject(tenantId, subjectId).removeAll;
  }

  size_t countByStatus(TenantId tenantId, PurposeRecordStatus status) {
    return findByStatus(tenantId, status).length;
  }

  PurposeRecord[] findByStatus(TenantId tenantId, PurposeRecordStatus status) {
    PurposeRecord[] result;
    foreach (s; findByTenant(tenantId))
      if (s.status == status)
        result ~= s;
    return result;
  }

  void removeByStatus(TenantId tenantId, PurposeRecordStatus status) {
    findByStatus(tenantId, status).each!(entity => remove(entity));
  }

  size_t countByBusinessContext(TenantId tenantId, BusinessContextId contextId) {
    return findByBusinessContext(tenantId, contextId).length;
  }

  PurposeRecord[] findByBusinessContext(TenantId tenantId, BusinessContextId contextId) {
    PurposeRecord[] result;
    foreach (s; findByTenant(tenantId))
      if (s.businessContextId == contextId)
        result ~= s;
    return result;
  }

  void removeByBusinessContext(TenantId tenantId, BusinessContextId contextId) {
    findByBusinessContext(tenantId, contextId).each!(entity => remove(entity));
  }

}
