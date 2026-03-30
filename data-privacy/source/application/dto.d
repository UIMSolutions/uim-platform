module application.dto;

import domain.types;

// ──────────────── Data Subject DTOs ────────────────

struct CreateDataSubjectRequest
{
    TenantId tenantId;
    DataSubjectType subjectType;
    string externalId;
    string displayName;
    string email;
    string sourceSystem;
    string country;
}

struct UpdateDataSubjectRequest
{
    DataSubjectId id;
    TenantId tenantId;
    DataSubjectType subjectType;
    string displayName;
    string email;
    string sourceSystem;
    string country;
    bool isActive;
}

// ──────────────── Personal Data Model DTOs ────────────────

struct CreatePersonalDataModelRequest
{
    TenantId tenantId;
    string fieldName;
    string fieldDescription;
    PersonalDataCategory category;
    DataSensitivity sensitivity;
    string sourceSystem;
    string sourceEntity;
    DataSubjectType subjectType;
    bool isSpecialCategory;
    string legalReference;
}

struct UpdatePersonalDataModelRequest
{
    PersonalDataModelId id;
    TenantId tenantId;
    string fieldName;
    string fieldDescription;
    PersonalDataCategory category;
    DataSensitivity sensitivity;
    string sourceSystem;
    string sourceEntity;
    bool isSpecialCategory;
    string legalReference;
}

// ──────────────── Deletion Request DTOs ────────────────

struct CreateDeletionRequest
{
    TenantId tenantId;
    DataSubjectId dataSubjectId;
    UserId requestedBy;
    string[] targetSystems;
    PersonalDataCategory[] categories;
    string reason;
}

struct UpdateDeletionStatusRequest
{
    DeletionRequestId id;
    TenantId tenantId;
    DeletionStatus status;
    string blockerReason;
}

// ──────────────── Blocking Request DTOs ────────────────

struct CreateBlockingRequest
{
    TenantId tenantId;
    DataSubjectId dataSubjectId;
    UserId requestedBy;
    string[] targetSystems;
    PersonalDataCategory[] categories;
    string reason;
}

struct UpdateBlockingStatusRequest
{
    BlockingRequestId id;
    TenantId tenantId;
    BlockingStatus status;
}

// ──────────────── Legal Ground DTOs ────────────────

struct CreateLegalGroundRequest
{
    TenantId tenantId;
    DataSubjectId dataSubjectId;
    LegalBasis basis;
    ProcessingPurpose purpose;
    string description;
    string legalReference;
    PersonalDataCategory[] categories;
    long validFrom;
    long validUntil;
}

struct UpdateLegalGroundRequest
{
    LegalGroundId id;
    TenantId tenantId;
    string description;
    string legalReference;
    PersonalDataCategory[] categories;
    bool isActive;
    long validUntil;
}

// ──────────────── Retention Rule DTOs ────────────────

struct CreateRetentionRuleRequest
{
    TenantId tenantId;
    string name;
    string description;
    ProcessingPurpose purpose;
    PersonalDataCategory[] categories;
    int retentionDays;
    string legalReference;
    bool isDefault;
}

struct UpdateRetentionRuleRequest
{
    RetentionRuleId id;
    TenantId tenantId;
    string name;
    string description;
    int retentionDays;
    PersonalDataCategory[] categories;
    string legalReference;
    RetentionRuleStatus status;
}

// ──────────────── Consent Record DTOs ────────────────

struct CreateConsentRecordRequest
{
    TenantId tenantId;
    DataSubjectId dataSubjectId;
    ProcessingPurpose purpose;
    PersonalDataCategory[] categories;
    string channel;
    string consentText;
    string version_;
    string ipAddress;
    long expiresAt;
}

struct RevokeConsentRequest
{
    ConsentRecordId id;
    TenantId tenantId;
}

// ──────────────── Data Retrieval Request DTOs ────────────────

struct CreateDataRetrievalRequest
{
    TenantId tenantId;
    DataSubjectId dataSubjectId;
    UserId requestedBy;
    string[] targetSystems;
    PersonalDataCategory[] categories;
    string reason;
}

struct UpdateRetrievalStatusRequest
{
    DataRetrievalRequestId id;
    TenantId tenantId;
    RetrievalStatus status;
    string downloadUrl;
    long totalFields;
}

// ──────────────── Generic result ────────────────

struct CommandResult
{
    string id;
    string error;

    bool isSuccess() const
    {
        return error.length == 0;
    }
}
