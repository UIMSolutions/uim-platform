/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data.quality.domain.ports.repositories.addresss;

import uim.platform.data.quality.domain.types;
import uim.platform.data.quality.domain.entities.address_record;

/// Port for persisting address records.
interface AddressRepository {
  AddressRecord[] findByTenant(TenantId tenantId);
  AddressRecord* findById(AddressId id, TenantId tenantId);
  AddressRecord[] findBySourceRecord(RecordId sourceRecordId, TenantId tenantId);
  AddressRecord[] findByQuality(TenantId tenantId, AddressQuality quality);
  void save(AddressRecord record);
  void update(AddressRecord record);
  void remove(AddressId id, TenantId tenantId);
}
