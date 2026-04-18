module uim.platform.data_retention.domain.ports.repositories.business_purposes;
import uim.platform.data_retention;

mixin(ShowModule!());

@safe:

interface BusinessPurposeRepository : ITenantRepository!(BusinessPurpose, BusinessPurposeId) {
    bool existsById(BusinessPurposeId id);
    BusinessPurpose findById(BusinessPurposeId id);

    BusinessPurpose[] findAll(TenantId tenantId);
    BusinessPurpose[] findByApplicationGroup(TenantId tenantId, ApplicationGroupId groupId);
    BusinessPurpose[] findByStatus(TenantId tenantId, BusinessPurposeStatus status);

    void save(BusinessPurpose a);
    void save(TenantId tenantId, BusinessPurpose a);
    void update(BusinessPurpose a);
    void update(TenantId tenantId, BusinessPurpose a);
}
