/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data.quality.domain.ports.repositories.addresses;

// import uim.platform.data.quality.domain.types;
// import uim.platform.data.quality.domain.entities.address_record;
import uim.platform.data.quality;

mixin(ShowModule!());

@safe:
/// Port for persisting address records.
interface AddressRepository : ITenantRepository!(AddressRecord, AddressId) {

  size_t countBySourceRecord(TenantId tenantId, RecordId sourceRecordId);
  AddressRecord[] findBySourceRecord(TenantId tenantId, RecordId sourceRecordId);
  void removeBySourceRecord(TenantId tenantId, RecordId sourceRecordId);

  size_t countByQuality(TenantId tenantId, AddressQuality quality);
  AddressRecord[] findByQuality(TenantId tenantId, AddressQuality quality);
  void removeByQuality(TenantId tenantId, AddressQuality quality);

}
