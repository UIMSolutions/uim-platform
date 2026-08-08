module uim.platform.data_retention.application.dto;
import uim.platform.data_retention;

mixin(ShowModule!());

@safe:

// --- Business Purpose ---

struct CreateBusinessPurposeRequest {
    TenantId tenantId;
    BusinessPurposeId purposeId;

    string name;
    string description;
    string applicationGroupId;
    string dataSubjectRoleId;
    string legalEntityId;
    long referenceDate;
    UserId createdBy;
}

struct UpdateBusinessPurposeRequest {
    TenantId tenantId;
    BusinessPurposeId purposeId;

    string name;
    string description;
    string applicationGroupId;
    string dataSubjectRoleId;
    string legalEntityId;
    long referenceDate;
}

// --- Legal Ground ---

struct CreateLegalGroundRequest {
    TenantId tenantId;
    LegalGroundId groundId;

    string name;
    string description;
    string businessPurposeId;
    string type;
    long referenceDate;
    UserId createdBy;
}

struct UpdateLegalGroundRequest {
    TenantId tenantId;
    LegalGroundId groundId;
    string name;
    string description;
    string type;
    long referenceDate;
}

// --- Retention Rule ---

struct CreateRetentionRuleRequest {
    TenantId tenantId;
    RetentionRuleId ruleId;
    string businessPurposeId;
    string legalGroundId;
    int duration;
    string periodUnit;
    string actionOnExpiry;
    UserId createdBy;
}

struct UpdateRetentionRuleRequest {
    TenantId tenantId;
    RetentionRuleId ruleId;

    int duration;
    string periodUnit;
    string actionOnExpiry;
    bool isActive;
}

// --- Residence Rule ---

struct CreateResidenceRuleRequest {
    TenantId tenantId;
    BusinessPurposeId purposeId;
    LegalGroundId groundId;
    int duration;
    string periodUnit;
    UserId createdBy;
}

struct UpdateResidenceRuleRequest {
    TenantId tenantId;
    ResidenceRuleId ruleId;

    int duration;
    string periodUnit;
    bool isActive;
}

// --- Data Subject ---

struct CreateDataSubjectRequest {
    TenantId tenantId;
    DataSubjectId subjectId;

    string roleId;
    string applicationGroupId;
    string externalId;
    UserId createdBy;
}

struct UpdateDataSubjectRequest {
    TenantId tenantId;
    DataSubjectId subjectId;

    string lifecycleStatus;
    string roleId;
}

// --- Deletion Request ---

struct CreateDeletionRequestRequest {
    TenantId tenantId;
    DeletionRequestId requestId;
    DataSubjectId subjectId;
    ApplicationGroupId groupId;

    string actionType;
    string reason;
    UserId requestedBy;
}

struct UpdateDeletionRequestRequest {
    TenantId tenantId;
    DeletionRequestId requestId;
    DataSubjectId subjectId;
    ApplicationGroupId groupId;

    string status;
    string errorMessage;
}

// --- Archiving Job ---

struct CreateArchivingJobRequest {
    TenantId tenantId;
    ArchivingJobId jobId;
    ApplicationGroupId groupId;
    
    string operationType;
    string selectionCriteria;
    long scheduledAt;
    UserId createdBy;
}

struct UpdateArchivingJobRequest {
    TenantId tenantId;
    ArchivingJobId jobId;
    ApplicationGroupId groupId;

    string operationType;
    string status;
    int recordsProcessed;
    int recordsFailed;
    string errorMessage;
}

// --- Application Group ---

struct CreateApplicationGroupRequest {
    TenantId tenantId;
    ApplicationGroupId groupId;

    string name;
    string description;
    string scope_;
    string[] applicationIds;
    UserId createdBy;
}

struct UpdateApplicationGroupRequest {
    TenantId tenantId;
    ApplicationGroupId groupId;

    string name;
    string description;
    string scope_;
    string[] applicationIds;
    bool isActive;
}

// --- Legal Entity ---

struct CreateLegalEntityRequest {
    TenantId tenantId;
    LegalEntityId entityId;

    string name;
    string description;
    string country;
    string region;
    UserId createdBy;
}

struct UpdateLegalEntityRequest {
    TenantId tenantId;
    LegalEntityId entityId;
    
    string name;
    string description;
    string country;
    string region;
    bool isActive;
}

// --- Data Subject Role ---

struct CreateDataSubjectRoleRequest {
    TenantId tenantId;
    string name;
    string description;
    UserId createdBy;
}

struct UpdateDataSubjectRoleRequest {
    TenantId tenantId;
    string name;
    string description;
    bool isActive;
}
