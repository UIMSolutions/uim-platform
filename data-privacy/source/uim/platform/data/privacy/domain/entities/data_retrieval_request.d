module uim.platform.data.privacy.domain.entities.data_retrieval_request;

import uim.platform.data.privacy.domain.types;

/// A data subject access request — retrieve all personal data (GDPR Art. 15).
struct DataRetrievalRequest
{
    DataRetrievalRequestId id;
    TenantId tenantId;
    DataSubjectId dataSubjectId;
    UserId requestedBy;
    RequestType requestType = RequestType.access;
    RetrievalStatus status = RetrievalStatus.requested;
    string[] targetSystems;         // systems to query
    PersonalDataCategory[] categories;  // filter by category (empty = all)
    string downloadUrl;             // set when completed
    long totalFields;               // count of personal data fields retrieved
    string reason;
    long requestedAt;
    long completedAt;
    long deadline;                  // regulatory deadline (30 days)
}
