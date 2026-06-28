module uim.platform.data_retention.infrastructure.persistence.memory.data_subjects;
import uim.platform.data_retention;

// mixin(ShowModule!());

@safe:

class MemoryDataSubjectRepository : TenantRepository!(DataSubject, DataSubjectId), DataSubjectRepository {

        size_t countByApplicationGroup(TenantId tenantId, ApplicationGroupId groupId) {
            return findByApplicationGroup(tenantId, groupId).length;
        }
    DataSubject[] findByApplicationGroup(TenantId tenantId, ApplicationGroupId groupId) {
        return find(tenantId).filter!(a => a.applicationGroupId == groupId).array;
    }
    void removeByApplicationGroup(TenantId tenantId, ApplicationGroupId groupId) {
        findByApplicationGroup(tenantId, groupId).each!(entity => remove(entity));
    }

    size_t countByLifecycleStatus(TenantId tenantId, DataLifecycleStatus status) {
        return findByLifecycleStatus(tenantId, status).length;
    }

    DataSubject[] filterByLifecycleStatus(DataSubject[] subjects, DataLifecycleStatus status) {
        return subjects.filter!(s => s.lifecycleStatus == status).array;
    }

    DataSubject[] findByLifecycleStatus(TenantId tenantId, DataLifecycleStatus status) {
        return filterByLifecycleStatus(find(tenantId), status);
    }

    void removeByLifecycleStatus(TenantId tenantId, DataLifecycleStatus status) {
        findByLifecycleStatus(tenantId, status).each!(entity => remove(entity));
    }

    size_t countByRole(TenantId tenantId, DataSubjectRoleId roleId) {
        return findByRole(tenantId, roleId).length;
    }

    DataSubject[] findByRole(TenantId tenantId, DataSubjectRoleId roleId) {
        return find(tenantId).filter!(a => a.roleId == roleId).array;
    }

    void removeByRole(TenantId tenantId, DataSubjectRoleId roleId) {
        findByRole(tenantId, roleId).each!(entity => remove(entity));
    }
}
