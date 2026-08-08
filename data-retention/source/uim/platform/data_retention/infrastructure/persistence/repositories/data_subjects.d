module uim.platform.data_retention.infrastructure.persistence.repositories.data_subjects;
import uim.platform.data_retention;

mixin(ShowModule!());

@safe:

class DataSubjectRepository : TenantRepository!(DataSubject, DataSubjectId), IDataSubjectRepository {

        size_t countByApplicationGroup(TenantId tenantId, ApplicationGroupId groupId) {
            return findByApplicationGroup(tenantId, groupId).length;
        }


    DataSubject[] filterByApplicationGroup(DataSubject[] subjects, ApplicationGroupId groupId) {
        return subjects.filter!(a => a.groupId == groupId).array;
    }

    DataSubject[] findByApplicationGroup(TenantId tenantId, ApplicationGroupId groupId) {
        return filterByApplicationGroup(findByTenant(tenantId), groupId);
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
        return filterByLifecycleStatus(findByTenant(tenantId), status);
    }

    void removeByLifecycleStatus(TenantId tenantId, DataLifecycleStatus status) {
        findByLifecycleStatus(tenantId, status).each!(entity => remove(entity));
    }

    size_t countByRole(TenantId tenantId, DataSubjectRoleId roleId) {
        return findByRole(tenantId, roleId).length;
    }

    DataSubject[] filterByRole(DataSubject[] subjects, DataSubjectRoleId roleId) {
        return subjects.filter!(s => s.roleId == roleId).array;
    }

    DataSubject[] findByRole(TenantId tenantId, DataSubjectRoleId roleId) {
        return filterByRole(findByTenant(tenantId), roleId);
    }

    void removeByRole(TenantId tenantId, DataSubjectRoleId roleId) {
        findByRole(tenantId, roleId).each!(entity => remove(entity));
    }
}
