module uim.platform.data_retention.domain.ports.repositories.deletion_requests;
import uim.platform.data_retention;
mixin(ShowModule!());

@safe:

interface DeletionRequestRepository : ITenantRepository!(DeletionRequest, DeletionRequestId) {

    DeletionRequest[] findByDataSubject(TenantId tenantId, DataSubjectId subjectId);
    DeletionRequest[] findByStatus(TenantId tenantId, DeletionRequestStatus status);
    DeletionRequest[] findByApplicationGroup(TenantId tenantId, ApplicationGroupId groupId);

}
