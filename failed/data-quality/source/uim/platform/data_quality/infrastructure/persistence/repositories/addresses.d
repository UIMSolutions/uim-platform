/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data_quality.infrastructure.persistence.repositories.addresses;

// import uim.platform.data_quality.domain.entities.address_record;
// import uim.platform.data_quality.domain.ports.repositories.addresses;

import uim.platform.data_quality;

mixin(ShowModule!());

@safe:
class MemoryAddressRepository : MemoryTenantRepository!(AddressRecord, AddressId), AddressRepository {

  size_t countBySourceRecord(TenantId tenantId, RecordId sourceRecordId) {
    return findBySourceRecord(tenantId, sourceRecordId).length;
  }

  AddressRecord[] findBySourceRecord(TenantId tenantId, RecordId sourceRecordId) {
    return findByTenant(tenantId).filter!(r => r.sourceRecordId == sourceRecordId).array;
  }

  void removeBySourceRecord(TenantId tenantId, RecordId sourceRecordId) {
    return findBySourceRecord(tenantId, sourceRecordId).each!(e => remove(e));
  }

  AddressRecord[] findByQuality(TenantId tenantId, AddressQuality quality) {
    return findByTenant(tenantId).filter!(r => r.quality == quality).array;
  }

}
