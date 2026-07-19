module uim.platform.data_retention.application.dto;
import uim.platform.data_retention;

mixin(ShowModule!());

@safe:

// --- Business Purpose ---

struct CreateBusinessPurposeRequest {
    TenantId tenantId;
    string name;
    string description;
    string applicationGroupId;
    string dataSubjectRoleId;
    string legalEntityId;
    long referenceDate;
    UserId createdBy;
}

struct UpdateBusinessPurposeRequest {
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
    string name;
    string description;
    string businessPurposeId;
    string type;
    long referenceDate;
    UserId createdBy;
}

struct UpdateLegalGroundRequest {
    string name;
    string description;
    string type;
    long referenceDate;
}

// --- Retention Rule ---

struct CreateRetentionRuleRequest {
    TenantId tenantId;
    string businessPurposeId;
    string legalGroundId;
    int duration;
    string periodUnit;
    string actionOnExpiry;
    UserId createdBy;
}

struct UpdateRetentionRuleRequest {
    int duration;
    string periodUnit;
    string actionOnExpiry;
    bool isActive;
}

// --- Residence Rule ---

struct CreateResidenceRuleRequest {
    TenantId tenantId;
    string businessPurposeId;
    string legalGroundId;
    int duration;
    string periodUnit;
    UserId createdBy;
}

struct UpdateResidenceRuleRequest {
    int duration;
    string periodUnit;
    bool isActive;
}

// --- Data Subject ---

struct CreateDataSubjectRequest {
    TenantId tenantId;
    string roleId;
    string applicationGroupId;
    string externalId;
    UserId createdBy;
}

struct UpdateDataSubjectRequest {
    string lifecycleStatus;
    string roleId;
}

// --- Deletion Request ---

struct CreateDeletionRequestRequest {
    TenantId tenantId;
    string dataSubjectId;
    string applicationGroupId;
    string actionType;
    string reason;
    UserId requestedBy;
}

struct UpdateDeletionRequestRequest {
    string status;
    string errorMessage;
}

// --- Archiving Job ---

struct CreateArchivingJobRequest {
    TenantId tenantId;
    string applicationGroupId;
    string operationType;
    string selectionCriteria;
    long scheduledAt;
    UserId createdBy;
}

struct UpdateArchivingJobRequest {
    string status;
    int recordsProcessed;
    int recordsFailed;
    string errorMessage;
}

// --- Application Group ---

struct CreateApplicationGroupRequest {
    TenantId tenantId;
    string name;
    string description;
    string scope_;
    string[] applicationIds;
    UserId createdBy;
}

struct UpdateApplicationGroupRequest {
    string name;
    string description;
    string scope_;
    string[] applicationIds;
    bool isActive;
}

// --- Legal Entity ---

struct CreateLegalEntityRequest {
    TenantId tenantId;
    string name;
    string description;
    string country;
    string region;
    UserId createdBy;
}

struct UpdateLegalEntityRequest {
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
    string name;
    string description;
    bool isActive;
}
