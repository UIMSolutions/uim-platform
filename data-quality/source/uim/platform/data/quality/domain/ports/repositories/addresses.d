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
interface AddressRepository {
  AddressRecord[] findByTenant(TenantId tenantId);
  AddressRecord* findById(TenantId tenantId, AddressId addressId);
  AddressRecord[] findBySourceRecord(TenantId tenantId, RecordId sourceRecordId);
  AddressRecord[] findByQuality(TenantId tenantId, AddressQuality quality);
  void save(AddressRecord record);
  void update(AddressRecord record);
  void remove(TenantId tenantId, AddressId addressId);
}
