module uim.platform.data_retention.domain.ports.repositories.data_subject_roles;
import uim.platform.data_retention;

mixin(ShowModule!());

@safe:

interface DataSubjectRoleRepository : ITenantRepository!(DataSubjectRole, DataSubjectRoleId) {
    bool existsById(DataSubjectRoleId id);
    DataSubjectRole findById(DataSubjectRoleId id);

    DataSubjectRole[] findAll(TenantId tenantId);
    DataSubjectRole[] findActive(TenantId tenantId);

    void save(DataSubjectRole a);
    void save(TenantId tenantId, DataSubjectRole a);
    void update(DataSubjectRole a);
    void update(TenantId tenantId, DataSubjectRole a);
}
