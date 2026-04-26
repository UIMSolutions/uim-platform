module uim.platform.service_manager.domain.ports.repositories.labels;

import uim.platform.service_manager;

mixin(ShowModule!());

@safe:

interface LabelRepository : ITenantRepository!(Label, LabelId) {

    size_t countByResource(TenantId tenantId, string resourceType, string resourceId);
    Label[] filterByResource(Label[] labels, string resourceType, string resourceId);
    Label[] findByResource(TenantId tenantId, string resourceType, string resourceId);
    void removeByResource(TenantId tenantId, string resourceType, string resourceId);
}
