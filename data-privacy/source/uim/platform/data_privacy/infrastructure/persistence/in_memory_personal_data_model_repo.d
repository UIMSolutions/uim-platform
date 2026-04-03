module uim.platform.xyz.infrastructure.persistence.memory.personal_data_model_repo;

import domain.types;
import domain.entities.personal_data_model;
import domain.ports.personal_data_model_repository;

class MemoryPersonalDataModelRepository : PersonalDataModelRepository
{
    private PersonalDataModel[] store;

    PersonalDataModel[] findByTenant(TenantId tenantId)
    {
        PersonalDataModel[] result;
        foreach (ref m; store)
            if (m.tenantId == tenantId)
                result ~= m;
        return result;
    }

    PersonalDataModel* findById(PersonalDataModelId id, TenantId tenantId)
    {
        foreach (ref m; store)
            if (m.id == id && m.tenantId == tenantId)
                return &m;
        return null;
    }

    PersonalDataModel[] findByCategory(TenantId tenantId, PersonalDataCategory category)
    {
        PersonalDataModel[] result;
        foreach (ref m; store)
            if (m.tenantId == tenantId && m.category == category)
                result ~= m;
        return result;
    }

    PersonalDataModel[] findBySourceSystem(TenantId tenantId, string sourceSystem)
    {
        PersonalDataModel[] result;
        foreach (ref m; store)
            if (m.tenantId == tenantId && m.sourceSystem == sourceSystem)
                result ~= m;
        return result;
    }

    PersonalDataModel[] findBySubjectType(TenantId tenantId, DataSubjectType subjectType)
    {
        PersonalDataModel[] result;
        foreach (ref m; store)
            if (m.tenantId == tenantId && m.subjectType == subjectType)
                result ~= m;
        return result;
    }

    PersonalDataModel[] findSpecialCategories(TenantId tenantId)
    {
        PersonalDataModel[] result;
        foreach (ref m; store)
            if (m.tenantId == tenantId && m.isSpecialCategory)
                result ~= m;
        return result;
    }

    void save(PersonalDataModel model)
    {
        store ~= model;
    }

    void update(PersonalDataModel model)
    {
        foreach (ref m; store)
            if (m.id == model.id && m.tenantId == model.tenantId)
            {
                m = model;
                return;
            }
    }

    void remove(PersonalDataModelId id, TenantId tenantId)
    {
        PersonalDataModel[] kept;
        foreach (ref m; store)
            if (!(m.id == id && m.tenantId == tenantId))
                kept ~= m;
        store = kept;
    }
}
