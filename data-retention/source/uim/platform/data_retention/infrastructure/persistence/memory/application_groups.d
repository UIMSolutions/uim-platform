module uim.platform.data_retention.infrastructure.persistence.memory.application_groups;
import uim.platform.data_retention;

mixin(ShowModule!());

@safe:

class MemoryApplicationGroupRepository : TenantRepository!(ApplicationGroup, ApplicationGroupId), ApplicationGroupRepository {

    size_t countByActive(TenantId tenantId) {
        return findActive(tenantId).length;
    }

    ApplicationGroup[] findActive(TenantId tenantId) {
        return findByTenant(tenantId).filter!(a => a.isActive).array;
    }

    void removeActive(TenantId tenantId) {
        findActive(tenantId).each!(entity => remove(entity));
    }

}
