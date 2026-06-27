module uim.platform.data_retention.domain.ports.repositories.data_subjects;
import uim.platform.data_retention;

// mixin(ShowModule!());

@safe:

interface DataSubjectRepository : ITentRepository!(DataSubject, DataSubjectId) {
    
    DataSubject[] findByApplicationGroup(TenantId tenantId, ApplicationGroupId groupId);
    DataSubject[] findByLifecycleStatus(TenantId tenantId, DataLifecycleStatus status);
    DataSubject[] findByRole(TenantId tenantId, DataSubjectRoleId roleId);

    
}
