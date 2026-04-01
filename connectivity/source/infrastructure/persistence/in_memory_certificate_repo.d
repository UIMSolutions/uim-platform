module infrastructure.persistence.memory.certificate_repo;

import domain.types;
import domain.entities.certificate;
import domain.ports.certificate_repository;

import std.algorithm : filter;
import std.array : array;

class MemoryCertificateRepository : CertificateRepository
{
    private Certificate[CertificateId] store;

    Certificate findById(CertificateId id)
    {
        if (auto p = id in store)
            return *p;
        return Certificate.init;
    }

    Certificate findByName(TenantId tenantId, string name)
    {
        foreach (ref e; store.byValue())
            if (e.tenantId == tenantId && e.name == name)
                return e;
        return Certificate.init;
    }

    Certificate[] findByTenant(TenantId tenantId)
    {
        return store.byValue().filter!(e => e.tenantId == tenantId).array;
    }

    Certificate[] findExpiring(TenantId tenantId, long now, uint withinDays)
    {
        return store.byValue()
            .filter!(e => e.tenantId == tenantId && e.expiresWithinDays(now, withinDays))
            .array;
    }

    void save(Certificate entity) { store[entity.id] = entity; }
    void update(Certificate entity) { store[entity.id] = entity; }
    void remove(CertificateId id) { store.remove(id); }
}
