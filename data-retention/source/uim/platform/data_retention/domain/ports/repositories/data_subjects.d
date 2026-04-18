module uim.platform.data_retention.domain.ports.repositories.data_subjects;
import uim.platform.data_retention;

mixin(ShowModule!());

@safe:

interface DataSubjectRepository : ITenantRepository!(DataSubject, DataSubjectId) {
    bool existsById(DataSubjectId id);
    DataSubject findById(DataSubjectId id);

    DataSubject[] findAll(TenantId tenantId);
    DataSubject[] findByApplicationGroup(TenantId tenantId, ApplicationGroupId groupId);
    DataSubject[] findByLifecycleStatus(TenantId tenantId, DataLifecycleStatus status);
    DataSubject[] findByRole(TenantId tenantId, DataSubjectRoleId roleId);

    void save(DataSubject a);
    void save(TenantId tenantId, DataSubject a);
    void update(DataSubject a);
    void update(TenantId tenantId, DataSubject a);
}
