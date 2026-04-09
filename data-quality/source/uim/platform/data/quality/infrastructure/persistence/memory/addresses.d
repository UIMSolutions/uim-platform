/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data.quality.infrastructure.persistence.memory.addresses;

// import uim.platform.data.quality.domain.types;
// import uim.platform.data.quality.domain.entities.address_record;
// import uim.platform.data.quality.domain.ports.repositories.addresses;

// import std.algorithm : filter;
// import std.array : array;
import uim.platform.data.quality;

mixin(ShowModule!());

@safe:
class MemoryAddressRepository : MemoryTenantRepository!(AddressRecord, AddressId), AddressRepository {
  // private AddressRecord[AddressId][TenantId] store;

  // AddressRecord[] findByTenant(TenantId tenantId) {
  //   return store.byValue().filter!(r => r.tenantId == tenantId).array;
  // }

  // AddressRecord findById(AddressId tenantId, id tenantId) {
  //   if (auto p = tenantId in store)
  //     if (auto r = id in p)
  //       return r;
  //   return null;
  // }

  AddressRecord[] findBySourceRecord(TenantId tenantId, RecordId sourceRecordId) {
    return findByTenant(tenantId).filter!(r => r.sourceRecordId == sourceRecordId).array;
  }

  AddressRecord[] findByQuality(TenantId tenantId, AddressQuality quality) {
    return findByTenant(tenantId).filter!(r => r.quality == quality).array;
  }

  // void save(AddressRecord record) {
    // store[record.id] = record;
  // }
// 
  // void update(AddressRecord record) {
    // store[record.id] = record;
  // }
// 
  // void remove(TenantId tenantId, AddressId id) {
    // if (auto p = id in store)
      // if (p.tenantId == tenantId)
        // store.remove(id);
  // }
}
