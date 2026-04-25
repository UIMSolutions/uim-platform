module uim.platform.data_retention.infrastructure.persistence.memory.data_subjects;
import uim.platform.data_retention;

mixin(ShowModule!());

@safe:

class MemoryDataSubjectRepository : TenantRepository!(DataSubject, DataSubjectId), DataSubjectRepository {

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
        findByLifecycleStatus(tenantId, status).each!(entity => remove(entity.id));
    }

    size_t countByRole(TenantId tenantId, DataSubjectRoleId roleId) {
        return findByRole(tenantId, roleId).length;
    }

    DataSubject[] findByRole(TenantId tenantId, DataSubjectRoleId roleId) {
        return findByTenant(tenantId).filter!(a => a.roleId == roleId).array;
    }

    void removeByRole(TenantId tenantId, DataSubjectRoleId roleId) {
        findByRole(tenantId, roleId).each!(entity => remove(entity.id));
    }
}
