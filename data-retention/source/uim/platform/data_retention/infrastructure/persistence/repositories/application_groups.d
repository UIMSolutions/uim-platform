module uim.platform.data_retention.infrastructure.persistence.repositories.application_groups;
import uim.platform.data_retention;

mixin(ShowModule!());

@safe:

class ApplicationGroupRepository : TenantRepository!(ApplicationGroup, ApplicationGroupId), IApplicationGroupRepository {

    size_t countByActive(TenantId tenantId) {
        return findActive(tenantId).length;
    }

    ApplicationGroup[] filterActive(ApplicationGroup[] groups) {
        return groups.filter!(a => a.isActive).array;
    }

    ApplicationGroup[] findActive(TenantId tenantId) {
        return filterActive(findByTenant(tenantId));
    }

    void removeActive(TenantId tenantId) {
        findActive(tenantId).each!(entity => remove(entity));
    }

}
