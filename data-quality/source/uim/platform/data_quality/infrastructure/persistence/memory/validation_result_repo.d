module uim.platform.xyz.infrastructure.persistence.memory.validation_result_repo;

import domain.types;
import domain.entities.validation_result;
import domain.ports.validation_result_repository;

import std.algorithm : filter;
import std.array : array;

class MemoryValidationResultRepository : ValidationResultRepository
{
    private ValidationResult[RecordId] store;

    ValidationResult[] findByTenant(TenantId tenantId)
    {
        return store.byValue().filter!(r => r.tenantId == tenantId).array;
    }

    ValidationResult* findByRecord(RecordId recordId, TenantId tenantId)
    {
        if (auto p = recordId in store)
            if (p.tenantId == tenantId)
                return p;
        return null;
    }

    ValidationResult[] findByDataset(TenantId tenantId, DatasetId datasetId)
    {
        return store.byValue()
            .filter!(r => r.tenantId == tenantId && r.datasetId == datasetId)
            .array;
    }

    void save(ValidationResult result) { store[result.recordId] = result; }

    void removeByDataset(TenantId tenantId, DatasetId datasetId)
    {
        RecordId[] toRemove;
        foreach (ref r; store.byValue())
            if (r.tenantId == tenantId && r.datasetId == datasetId)
                toRemove ~= r.recordId;
        foreach (id; toRemove)
            store.remove(id);
    }
}
