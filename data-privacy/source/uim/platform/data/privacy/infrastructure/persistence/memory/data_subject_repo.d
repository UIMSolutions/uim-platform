module uim.platform.data.privacy.infrastructure.persistence.memory.data_subject_repo;

import uim.platform.data.privacy.domain.types;
import uim.platform.data.privacy.domain.entities.data_subject;
import uim.platform.data.privacy.domain.ports.data_subject_repository;

class MemoryDataSubjectRepository : DataSubjectRepository
{
    private DataSubject[] store;

    DataSubject[] findByTenant(TenantId tenantId)
    {
        DataSubject[] result;
        foreach (ref s; store)
            if (s.tenantId == tenantId)
                result ~= s;
        return result;
    }

    DataSubject* findById(DataSubjectId id, TenantId tenantId)
    {
        foreach (ref s; store)
            if (s.id == id && s.tenantId == tenantId)
                return &s;
        return null;
    }

    DataSubject* findByExternalId(string externalId, TenantId tenantId)
    {
        foreach (ref s; store)
            if (s.externalId == externalId && s.tenantId == tenantId)
                return &s;
        return null;
    }

    DataSubject[] findByType(TenantId tenantId, DataSubjectType subjectType)
    {
        DataSubject[] result;
        foreach (ref s; store)
            if (s.tenantId == tenantId && s.subjectType == subjectType)
                result ~= s;
        return result;
    }

    DataSubject[] findBySourceSystem(TenantId tenantId, string sourceSystem)
    {
        DataSubject[] result;
        foreach (ref s; store)
            if (s.tenantId == tenantId && s.sourceSystem == sourceSystem)
                result ~= s;
        return result;
    }

    void save(DataSubject subject)
    {
        store ~= subject;
    }

    void update(DataSubject subject)
    {
        foreach (ref s; store)
            if (s.id == subject.id && s.tenantId == subject.tenantId)
            {
                s = subject;
                return;
            }
    }

    void remove(DataSubjectId id, TenantId tenantId)
    {
        DataSubject[] kept;
        foreach (ref s; store)
            if (!(s.id == id && s.tenantId == tenantId))
                kept ~= s;
        store = kept;
    }
}
