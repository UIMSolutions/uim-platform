module uim.platform.xyz.domain.entities.deletion_request;

import uim.platform.xyz.domain.types;

/// A request to erase personal data for a data subject (GDPR Art. 17).
struct DeletionRequest
{
    DeletionRequestId id;
    TenantId tenantId;
    DataSubjectId dataSubjectId;
    UserId requestedBy;             // DPO or the data subject themselves
    RequestType requestType = RequestType.deletion;
    DeletionStatus status = DeletionStatus.requested;
    string[] targetSystems;         // systems where data should be deleted
    PersonalDataCategory[] categories;  // categories to delete (empty = all)
    string reason;                  // justification/legal basis
    string blockerReason;           // if status == blocked, why
    long requestedAt;
    long completedAt;
    long deadline;                  // regulatory deadline (e.g. 30 days)
}
