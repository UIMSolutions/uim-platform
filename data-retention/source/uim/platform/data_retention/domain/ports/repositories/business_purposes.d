module uim.platform.data_retention.domain.ports.repositories.business_purposes;
import uim.platform.data_retention;

mixin(ShowModule!());

@safe:

interface BusinessPurposeRepository : ITenantRepository!(BusinessPurpose, BusinessPurposeId) {

    BusinessPurpose[] findByApplicationGroup(TenantId tenantId, ApplicationGroupId groupId);
    BusinessPurpose[] findByStatus(TenantId tenantId, BusinessPurposeStatus status);

}
