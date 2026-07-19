module uim.platform.data_retention.domain.ports.repositories.application_groups;
import uim.platform.data_retention;
mixin(ShowModule!());

@safe:

interface ApplicationGroupRepository : ITenantRepository!(ApplicationGroup, ApplicationGroupId) {

    ApplicationGroup[] findActive(TenantId tenantId);

}