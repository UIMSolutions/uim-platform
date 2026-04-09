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
class MemoryPurposeRecordRepository : PurposeRecordRepository {
  private PurposeRecord[] store;

  PurposeRecord[] findByTenant(TenantId tenantId) {
    PurposeRecord[] result;
    foreach (ref s; store)
      if (s.tenantId == tenantId)
        result ~= s;
    return result;
  }

  PurposeRecord* findById(PurposeRecordId tenantId, id tenantId) {
    foreach (ref s; store)
      if (s.id == id && s.tenantId == tenantId)
        return &s;
    return null;
  }

  PurposeRecord[] findByDataSubject(TenantId tenantId, DataSubjectId subjectId) {
    PurposeRecord[] result;
    foreach (ref s; store)
      if (s.tenantId == tenantId && s.dataSubjectId == subjectId)
        result ~= s;
    return result;
  }

  PurposeRecord[] findByStatus(TenantId tenantId, PurposeRecordStatus status) {
    PurposeRecord[] result;
    foreach (ref s; store)
      if (s.tenantId == tenantId && s.status == status)
        result ~= s;
    return result;
  }

  PurposeRecord[] findByBusinessContext(TenantId tenantId, BusinessContextId contextId) {
    PurposeRecord[] result;
    foreach (ref s; store)
      if (s.tenantId == tenantId && s.businessContextId == contextId)
        result ~= s;
    return result;
  }

  void save(PurposeRecord entity) {
    store ~= entity;
  }

  void update(PurposeRecord entity) {
    foreach (ref s; store)
      if (s.id == entity.id && s.tenantId == entity.tenantId) {
        s = entity;
        return;
      }
  }

  void remove(PurposeRecordId tenantId, id tenantId) {
    PurposeRecord[] kept;
    foreach (ref s; store)
      if (!(s.id == id && s.tenantId == tenantId))
        kept ~= s;
    store = kept;
  }
}
