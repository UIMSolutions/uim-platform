module uim.platform.data_retention.domain.ports.repositories.application_groups;
import uim.platform.data_retention;

mixin(ShowModule!());

@safe:

interface ApplicationGroupRepository : ITenantRepository!(ApplicationGroup, ApplicationGroupId) {
    bool existsById(ApplicationGroupId id);
    ApplicationGroup findById(ApplicationGroupId id);

    ApplicationGroup[] findAll(TenantId tenantId);
    ApplicationGroup[] findActive(TenantId tenantId);

    void save(ApplicationGroup a);
    void save(TenantId tenantId, ApplicationGroup a);
    void update(ApplicationGroup a);
    void update(TenantId tenantId, ApplicationGroup a);
}
