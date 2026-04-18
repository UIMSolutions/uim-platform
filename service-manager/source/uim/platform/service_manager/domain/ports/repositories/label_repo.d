module uim.platform.service_manager.domain.ports.repositories.label_repo;

import uim.platform.service_manager;

mixin(ShowModule!());

@safe:

interface LabelRepository {
    Label[] findByTenant(TenantId tenantId);
    Label* findById(TenantId tenantId, LabelId id);
    Label[] findByResource(TenantId tenantId, string resourceType, string resourceId);
    void save(Label entity);
    void update(Label entity);
    void remove(TenantId tenantId, LabelId id);
    ulong countByTenant(TenantId tenantId);
}
