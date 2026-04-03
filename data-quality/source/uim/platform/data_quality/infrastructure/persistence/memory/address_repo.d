module uim.platform.xyz.infrastructure.persistence.memory.address_repo;

import domain.types;
import domain.entities.address_record;
import domain.ports.address_repository;

import std.algorithm : filter;
import std.array : array;

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
        return store.byValue()
            .filter!(r => r.tenantId == tenantId && r.sourceRecordId == sourceRecordId)
            .array;
    }

    AddressRecord[] findByQuality(TenantId tenantId, AddressQuality quality) {
        return store.byValue()
            .filter!(r => r.tenantId == tenantId && r.quality == quality)
            .array;
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
