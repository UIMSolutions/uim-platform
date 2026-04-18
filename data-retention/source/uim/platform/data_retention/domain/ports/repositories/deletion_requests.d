module uim.platform.data_retention.domain.ports.repositories.deletion_requests;
import uim.platform.data_retention;

mixin(ShowModule!());

@safe:

interface DeletionRequestRepository { //: ITenantRepository!(DeletionRequest, DeletionRequestId) {
    bool existsById(DeletionRequestId id);
    DeletionRequest findById(DeletionRequestId id);

    DeletionRequest[] findAll(TenantId tenantId);
    DeletionRequest[] findByDataSubject(TenantId tenantId, DataSubjectId subjectId);
    DeletionRequest[] findByStatus(TenantId tenantId, DeletionRequestStatus status);
    DeletionRequest[] findByApplicationGroup(TenantId tenantId, ApplicationGroupId groupId);

    void save(DeletionRequest a);
    void save(TenantId tenantId, DeletionRequest a);
    void update(DeletionRequest a);
    void update(TenantId tenantId, DeletionRequest a);
}
