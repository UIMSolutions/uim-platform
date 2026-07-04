module uim.platform.service_manager.infrastructure.persistence.memory.labels;

import uim.platform.service_manager;

mixin(ShowModule!());

@safe:

class MemoryLabelRepository : TenantRepository!(Label, LabelId), LabelRepository {

    size_t countByResource(TenantId tenantId, string resourceType, string resourceId) {
        return findByResource(tenantId, resourceType, resourceId).length;
    }

    Label[] filterByResource(Label[] labels, string resourceType, string resourceId) {
        return labels.filter!(e => e.resourceType == resourceType && e.resourceId == resourceId).array;
    }

    Label[] findByResource(TenantId tenantId, string resourceType, string resourceId) {
        return filterByResource(findByTenant(tenantId), resourceType, resourceId);
    }

    void removeByResource(TenantId tenantId, string resourceType, string resourceId) {
        findByResource(tenantId, resourceType, resourceId).each!(e => remove(e));
    }
}
