module uim.platform.data_retention.domain.ports.repositories.application_groups;
import uim.platform.data_retention;

mixin(ShowModule!());

@safe:

interface ApplicationGroupRepository { ///}: ITenantRepository!(ApplicationGroup, ApplicationGroupId) {
    bool existsById(ApplicationGroupId id);
    ApplicationGroup findById(ApplicationGroupId id);

    ApplicationGroup[] findAll(TenantId tenantId);
    ApplicationGroup[] findActive(TenantId tenantId);

    void save(ApplicationGroup appGroup);
    void save(TenantId tenantId, ApplicationGroup appGroup);

    void remove(ApplicationGroupId id);
    void remove(TenantId tenantId, ApplicationGroupId id);

    void update(ApplicationGroup appGroup);
    void update(TenantId tenantId, ApplicationGroup appGroup);
}
