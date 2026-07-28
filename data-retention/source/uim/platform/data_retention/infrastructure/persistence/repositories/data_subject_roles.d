module uim.platform.data_retention.infrastructure.persistence.repositories.data_subject_roles;
import uim.platform.data_retention;

mixin(ShowModule!());

@safe:

class MemoryDataSubjectRoleRepository : TenantRepository!(DataSubjectRole, DataSubjectRoleId), DataSubjectRoleRepository {

    size_t countActive(TenantId tenantId) {
        return findActive(tenantId).length;
    }

    DataSubjectRole[] findActive(TenantId tenantId) {
        return findByTenant(tenantId).filter!(a => a.isActive).array;
    }

    void removeActive(TenantId tenantId) {
        findActive(tenantId).each!(entity => remove(entity));
    }
}
