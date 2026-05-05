module uim.platform.data_retention.infrastructure.persistence.memory.business_purposes;
import uim.platform.data_retention;

mixin(ShowModule!());

@safe:

class MemoryBusinessPurposeRepository : TenantRepository!(BusinessPurpose, BusinessPurposeId), BusinessPurposeRepository {

    size_t countByApplicationGroup(TenantId tenantId, ApplicationGroupId groupId) {
        return findByApplicationGroup(tenantId, groupId).length;
    }

    BusinessPurpose[] findByApplicationGroup(TenantId tenantId, ApplicationGroupId groupId) {
        return findByTenant(tenantId).filter!(a => a.applicationGroupId == groupId).array;
    }

    void removeByApplicationGroup(TenantId tenantId, ApplicationGroupId groupId) {
        findByApplicationGroup(tenantId, groupId).each!(entity => remove(entity));
    }

    size_t countByStatus(TenantId tenantId, BusinessPurposeStatus status) {
        return findByStatus(tenantId, status).length;
    }

    BusinessPurpose[] findByStatus(TenantId tenantId, BusinessPurposeStatus status) {
        return findByTenant(tenantId).filter!(a => a.status == status).array;
    }

    void removeByStatus(TenantId tenantId, BusinessPurposeStatus status) {
        findByStatus(tenantId, status).each!(entity => remove(entity));
    }
}
