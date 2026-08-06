module uim.platform.data_retention.infrastructure.persistence.repositories.business_purposes;
import uim.platform.data_retention;

mixin(ShowModule!());

@safe:

class BusinessPurposeRepository : TenantRepository!(BusinessPurpose, BusinessPurposeId), IBusinessPurposeRepository {

    size_t countByApplicationGroup(TenantId tenantId, ApplicationGroupId groupId) {
        return findByApplicationGroup(tenantId, groupId).length;
    }

    BusinessPurpose[] filterByApplicationGroup(BusinessPurpose[] purposes, ApplicationGroupId groupId) {
        return purposes.filter!(a => a.applicationGroupId == groupId).array;
    }

    BusinessPurpose[] findByApplicationGroup(TenantId tenantId, ApplicationGroupId groupId) {
        return filterByApplicationGroup(findByTenant(tenantId), groupId);
    }

    void removeByApplicationGroup(TenantId tenantId, ApplicationGroupId groupId) {
        findByApplicationGroup(tenantId, groupId).each!(entity => remove(entity));
    }

    size_t countByStatus(TenantId tenantId, BusinessPurposeStatus status) {
        return findByStatus(tenantId, status).length;
    }

    BusinessPurpose[] filterByStatus(BusinessPurpose[] purposes, BusinessPurposeStatus status) {
        return purposes.filter!(a => a.status == status).array;
    }
    
    BusinessPurpose[] findByStatus(TenantId tenantId, BusinessPurposeStatus status) {
        return filterByStatus(findByTenant(tenantId), status);
    }

    void removeByStatus(TenantId tenantId, BusinessPurposeStatus status) {
        findByStatus(tenantId, status).each!(entity => remove(entity));
    }
}
