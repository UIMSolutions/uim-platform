module uim.platform.data_retention.infrastructure.persistence.memory.deletion_requests;
import uim.platform.data_retention;

mixin(ShowModule!());

@safe:

class MemoryDeletionRequestRepository : TenantRepository!(DeletionRequest, DeletionRequestId), DeletionRequestRepository {

    size_t countByDataSubject(TenantId tenantId, DataSubjectId subjectId) {
        return findByDataSubject(tenantId, subjectId).length;
    }

    DeletionRequest[] filterByDataSubject(DeletionRequest[] requests, DataSubjectId subjectId) {
        return requests.filter!(r => r.dataSubjectId == subjectId).array;
    }

    DeletionRequest[] findByDataSubject(TenantId tenantId, DataSubjectId subjectId) {
        return filterByDataSubject(findByTenant(tenantId), subjectId);
    }

    void removeByDataSubject(TenantId tenantId, DataSubjectId subjectId) {
        findByDataSubject(tenantId, subjectId).removeAll;
    }

    size_t countByStatus(TenantId tenantId, DeletionRequestStatus status) {
        return findByStatus(tenantId, status).length;
    }

    DeletionRequest[] filterByStatus(DeletionRequest[] requests, DeletionRequestStatus status) {
        return requests.filter!(r => r.status == status).array;
    }

    DeletionRequest[] findByStatus(TenantId tenantId, DeletionRequestStatus status) {
        return filterByStatus(findByTenant(tenantId), status);
    }

    void removeByStatus(TenantId tenantId, DeletionRequestStatus status) {
        findByStatus(tenantId, status).removeAll;
    }

    size_t countByApplicationGroup(TenantId tenantId, ApplicationGroupId groupId) {
        return findByApplicationGroup(tenantId, groupId).length;
    }

    DeletionRequest[] filterByApplicationGroup(DeletionRequest[] requests, ApplicationGroupId groupId) {
        return requests.filter!(r => r.applicationGroupId == groupId).array;
    }

    DeletionRequest[] findByApplicationGroup(TenantId tenantId, ApplicationGroupId groupId) {
        return filterByApplicationGroup(findByTenant(tenantId), groupId);
    }

    void removeByApplicationGroup(TenantId tenantId, ApplicationGroupId groupId) {
        findByApplicationGroup(tenantId, groupId).removeAll;
    }

}
