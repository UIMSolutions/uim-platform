module domain.ports.data_subject_repository;

import domain.types;
import domain.entities.data_subject;

/// Port for persisting and querying data subjects.
interface DataSubjectRepository
{
    DataSubject[] findByTenant(TenantId tenantId);
    DataSubject* findById(DataSubjectId id, TenantId tenantId);
    DataSubject* findByExternalId(string externalId, TenantId tenantId);
    DataSubject[] findByType(TenantId tenantId, DataSubjectType subjectType);
    DataSubject[] findBySourceSystem(TenantId tenantId, string sourceSystem);
    void save(DataSubject subject);
    void update(DataSubject subject);
    void remove(DataSubjectId id, TenantId tenantId);
}
