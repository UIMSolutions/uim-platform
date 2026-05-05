module uim.platform.data_retention.infrastructure.persistence.memory.data_subject_roles;
import uim.platform.data_retention;

mixin(ShowModule!());

@safe:

class MemoryDataSubjectRoleRepository : DataSubjectRoleRepository {

    site_t countByTenant(TenantId tenantId) {
        return findByTenant(tenantId).length;
    }

    DataSubjectRole[] findActive(TenantId tenantId) {
        return findByTenant(tenantId).filter!(a => a.isActive).array;
    }

    void removeActive(TenantId tenantId) {
        findActive(tenantId).each!(entity => remove(entity));
    }
}
