module uim.platform.data.privacy.domain.entities.blocking_request;

import uim.platform.data.privacy.domain.types;

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
