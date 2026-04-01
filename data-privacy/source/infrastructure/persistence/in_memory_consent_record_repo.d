module infrastructure.persistence.memory.consent_record_repo;

import domain.types;
import domain.entities.consent_record;
import domain.ports.consent_record_repository;

class InMemoryConsentRecordRepository : ConsentRecordRepository
{
    private ConsentRecord[] store;

    ConsentRecord[] findByTenant(TenantId tenantId)
    {
        ConsentRecord[] result;
        foreach (ref c; store)
            if (c.tenantId == tenantId)
                result ~= c;
        return result;
    }

    ConsentRecord* findById(ConsentRecordId id, TenantId tenantId)
    {
        foreach (ref c; store)
            if (c.id == id && c.tenantId == tenantId)
                return &c;
        return null;
    }

    ConsentRecord[] findByDataSubject(TenantId tenantId, DataSubjectId dataSubjectId)
    {
        ConsentRecord[] result;
        foreach (ref c; store)
            if (c.tenantId == tenantId && c.dataSubjectId == dataSubjectId)
                result ~= c;
        return result;
    }

    ConsentRecord[] findByPurpose(TenantId tenantId, ProcessingPurpose purpose)
    {
        ConsentRecord[] result;
        foreach (ref c; store)
            if (c.tenantId == tenantId && c.purpose == purpose)
                result ~= c;
        return result;
    }

    ConsentRecord[] findByStatus(TenantId tenantId, ConsentStatus status)
    {
        ConsentRecord[] result;
        foreach (ref c; store)
            if (c.tenantId == tenantId && c.status == status)
                result ~= c;
        return result;
    }

    ConsentRecord[] findActiveConsents(TenantId tenantId, DataSubjectId dataSubjectId)
    {
        ConsentRecord[] result;
        foreach (ref c; store)
            if (c.tenantId == tenantId && c.dataSubjectId == dataSubjectId
                && c.status == ConsentStatus.granted)
                result ~= c;
        return result;
    }

    void save(ConsentRecord record)
    {
        store ~= record;
    }

    void update(ConsentRecord record)
    {
        foreach (ref c; store)
            if (c.id == record.id && c.tenantId == record.tenantId)
            {
                c = record;
                return;
            }
    }

    void remove(ConsentRecordId id, TenantId tenantId)
    {
        ConsentRecord[] kept;
        foreach (ref c; store)
            if (!(c.id == id && c.tenantId == tenantId))
                kept ~= c;
        store = kept;
    }
}
