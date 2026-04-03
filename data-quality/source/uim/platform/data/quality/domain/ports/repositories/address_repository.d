module uim.platform.data.quality.domain.ports.address_repository;

import uim.platform.data.quality.domain.types;
import uim.platform.data.quality.domain.entities.address_record;

/// Port for persisting address records.
interface AddressRepository
{
  AddressRecord[] findByTenant(TenantId tenantId);
  AddressRecord* findById(AddressId id, TenantId tenantId);
  AddressRecord[] findBySourceRecord(RecordId sourceRecordId, TenantId tenantId);
  AddressRecord[] findByQuality(TenantId tenantId, AddressQuality quality);
  void save(AddressRecord record);
  void update(AddressRecord record);
  void remove(AddressId id, TenantId tenantId);
}
