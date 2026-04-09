/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data.quality.application.usecases.cleanse_addresses;

// import std.uuid;

// import uim.platform.data.quality.domain.types;
// import uim.platform.data.quality.domain.entities.address_record;
// import uim.platform.data.quality.domain.ports.repositories.addresses;
// import uim.platform.data.quality.domain.services.address_cleanser;
// import uim.platform.data.quality.application.dto;
import uim.platform.data.quality;

mixin(ShowModule!());

@safe:
class CleanseAddressesUseCase : UIMUseCase {
  private AddressRepository repo;
  private AddressCleanser cleanser;

  this(AddressRepository repo, AddressCleanser cleanser) {
    this.repo = repo;
    this.cleanser = cleanser;
  }

  /// Cleanse a single address.
  AddressRecord cleanse(CleanseAddressRequest req) {
    auto record = AddressRecord();
    record.id = randomUUID();
    record.tenantId = req.tenantId;
    record.sourceRecordId = req.sourceRecordId;
    record.inputLine1 = req.line1;
    record.inputLine2 = req.line2;
    record.inputCity = req.city;
    record.inputRegion = req.region;
    record.inputPostalCode = req.postalCode;
    record.inputCountry = req.country;

    auto cleansed = cleanser.cleanse(record);
    repo.save(cleansed);
    return cleansed;
  }

  /// Cleanse a batch of addresses.
  AddressRecord[] cleanseBatch(CleanseBatchAddressRequest req) {
    AddressRecord[] results;
    foreach (ref addr; req.addresses) {
      results ~= cleanse(addr);
    }
    return results;
  }

  /// Retrieve cleansed addresses by tenant.
  AddressRecord[] getByTenant(TenantId tenantId) {
    return repo.findByTenant(tenantId);
  }

  /// Retrieve by source record.
  AddressRecord[] getBySourceRecord(RecordId sourceRecordtenantId, id tenantId) {
    return repo.findBySourceRecord(sourceRecordtenantId, id);
  }

  /// Retrieve by quality level.
  AddressRecord[] getByQuality(TenantId tenantId, AddressQuality quality) {
    return repo.findByQuality(tenantId, quality);
  }
}
