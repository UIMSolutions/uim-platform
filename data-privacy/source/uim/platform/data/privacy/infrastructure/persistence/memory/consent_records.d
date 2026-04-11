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
class MemoryConsentRecordRepository : ConsentRecordRepository {
  private ConsentRecord[ConsentRecordId][TenantId] store;

  bool existsByTenant(TenantId tenantId) {
    return tenantId in store;
  }

  ConsentRecord[] findByTenant(TenantId tenantId) {
    if (!existsByTenant(tenantId))
      return null;

    return store[tenantId].byValue.array;
  }

  ConsentRecord* findById(ConsentRecordId tenantId, id tenantId) {
    if (!existsById(tenantId, id))
      return null;

    return &store[tenantId][id];
  }

  ConsentRecord[] findByDataSubject(TenantId tenantId, DataSubjectId dataSubjectId) {
    if (!existsByTenant(tenantId))
      return null;

    ConsentRecord[] result;
    foreach (c; store[tenantId].byValue)
      if (c.dataSubjectId == dataSubjectId)
        result ~= c;
    return result;
  }

  ConsentRecord[] findByPurpose(TenantId tenantId, ProcessingPurpose purpose) {
    if (!existsByTenant(tenantId))
      return null;

    ConsentRecord[] result;
    foreach (c; store[tenantId].byValue)
      if (c.purpose == purpose)
        result ~= c;
    return result;
  }

  ConsentRecord[] findByStatus(TenantId tenantId, ConsentStatus status) {
    if (!existsByTenant(tenantId))
      return null;

    ConsentRecord[] result;
    foreach (c; store[tenantId].byValue)
      if (c.status == status)
        result ~= c;
    return result;
  }

  ConsentRecord[] findActiveConsents(TenantId tenantId, DataSubjectId dataSubjectId) {
    if (!existsByTenant(tenantId))
      return null;

    ConsentRecord[] result;
    foreach (c; store[tenantId].byValue)
      if (c.dataSubjectId == dataSubjectId && c.status == ConsentStatus.granted)
        result ~= c;
    return result;
  }

  void save(ConsentRecord record) {
    if (!existsByTenant(record.tenantId)) {
      ConsentRecord[ConsentRecordId] records;
      store[record.tenantId] = records;
    }
    store[record.tenantId][record.id] = record;
  }

  void update(ConsentRecord record) {
    if (!existsById(record.id, record.tenantId))
      return;

    store[record.tenantId][record.id] = record;
  }

  void remove(ConsentRecordId tenantId, id tenantId) {
    if (!existsById(tenantId, id))
      return;

    store[tenantId].remove(id);
    if (store[tenantId].empty) {
      store.remove(tenantId);
    }
  }
}
