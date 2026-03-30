module domain.ports.consent_record_repository;

import domain.types;
import domain.entities.consent_record;

/// Port for persisting consent records.
interface ConsentRecordRepository
{
    ConsentRecord[] findByTenant(TenantId tenantId);
    ConsentRecord* findById(ConsentRecordId id, TenantId tenantId);
    ConsentRecord[] findByDataSubject(TenantId tenantId, DataSubjectId dataSubjectId);
    ConsentRecord[] findByPurpose(TenantId tenantId, ProcessingPurpose purpose);
    ConsentRecord[] findByStatus(TenantId tenantId, ConsentStatus status);
    ConsentRecord[] findActiveConsents(TenantId tenantId, DataSubjectId dataSubjectId);
    void save(ConsentRecord record);
    void update(ConsentRecord record);
    void remove(ConsentRecordId id, TenantId tenantId);
}
