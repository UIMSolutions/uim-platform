module uim.platform.data_retention.infrastructure.persistence.repositories.data_subject_roles;
import uim.platform.data_retention;

mixin(ShowModule!());

@safe:

class DataSubjectRoleRepository : TenantRepository!(DataSubjectRole, DataSubjectRoleId), IDataSubjectRoleRepository {

    size_t countActive(TenantId tenantId) {
        return findActive(tenantId).length;
    }

    DataSubjectRole[] filterActive(DataSubjectRole[] roles) {
        return roles.filter!(a => a.isActive).array;
    }

    DataSubjectRole[] findActive(TenantId tenantId) {
        return filterActive(findByTenant(tenantId));
    }

    void removeActive(TenantId tenantId) {
        findActive(tenantId).each!(entity => remove(entity));
    }
}
