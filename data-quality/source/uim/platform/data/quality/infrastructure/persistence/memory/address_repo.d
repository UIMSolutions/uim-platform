/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data.quality.infrastructure.persistence.memory.address_repo;

import uim.platform.data.quality.domain.types;
import uim.platform.data.quality.domain.entities.address_record;
import uim.platform.data.quality.domain.ports.repositories.addresss;

// import std.algorithm : filter;
// import std.array : array;

class MemoryAddressRepository : AddressRepository {
  private AddressRecord[AddressId] store;

  AddressRecord[] findByTenant(TenantId tenantId) {
    return store.byValue().filter!(r => r.tenantId == tenantId).array;
  }

  AddressRecord* findById(AddressId id, TenantId tenantId) {
    if (auto p = id in store)
      if (p.tenantId == tenantId)
        return p;
    return null;
  }

  AddressRecord[] findBySourceRecord(RecordId sourceRecordId, TenantId tenantId) {
    return store.byValue().filter!(r => r.tenantId == tenantId
        && r.sourceRecordId == sourceRecordId).array;
  }

  AddressRecord[] findByQuality(TenantId tenantId, AddressQuality quality) {
    return store.byValue().filter!(r => r.tenantId == tenantId && r.quality == quality).array;
  }

  void save(AddressRecord record) {
    store[record.id] = record;
  }

  void update(AddressRecord record) {
    store[record.id] = record;
  }

  void remove(AddressId id, TenantId tenantId) {
    if (auto p = id in store)
      if (p.tenantId == tenantId)
        store.remove(id);
  }
}
