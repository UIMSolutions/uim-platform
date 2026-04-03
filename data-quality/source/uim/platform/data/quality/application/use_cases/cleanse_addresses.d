module uim.platform.data.quality.application.usecases.cleanse_addresses;

// import std.uuid;

import uim.platform.data.quality.domain.types;
import uim.platform.data.quality.domain.entities.address_record;
import uim.platform.data.quality.domain.ports.address_repository;
import uim.platform.data.quality.domain.services.address_cleanser;
import uim.platform.data.quality.application.dto;

class CleanseAddressesUseCase {
    private AddressRepository repo;
    private AddressCleanser cleanser;

    this(AddressRepository repo, AddressCleanser cleanser) {
        this.repo = repo;
        this.cleanser = cleanser;
    }

    /// Cleanse a single address.
    AddressRecord cleanse(CleanseAddressRequest req) {
        auto record = AddressRecord();
        record.id = randomUUID().toString();
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
    AddressRecord[] getBySourceRecord(RecordId sourceRecordId, TenantId tenantId) {
        return repo.findBySourceRecord(sourceRecordId, tenantId);
    }

    /// Retrieve by quality level.
    AddressRecord[] getByQuality(TenantId tenantId, AddressQuality quality) {
        return repo.findByQuality(tenantId, quality);
    }
}
