module uim.platform.xyz.domain.entities.blocking_request;

import uim.platform.xyz.domain.types;

/// A request to restrict processing of personal data (GDPR Art. 18).
struct BlockingRequest
{
    BlockingRequestId id;
    TenantId tenantId;
    DataSubjectId dataSubjectId;
    UserId requestedBy;
    BlockingStatus status = BlockingStatus.requested;
    string[] targetSystems;
    PersonalDataCategory[] categories;
    string reason;
    long requestedAt;
    long activatedAt;
    long releasedAt;
}
