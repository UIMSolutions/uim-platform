/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.personal_data.application.dto;

import uim.platform.personal_data;

mixin(ShowModule!());

@safe:

struct CommandResult {
    bool success;
    string id;
    string error;
}

// --- Data Subject ---
struct CreateDataSubjectRequest {
    TenantId tenantId;
    string id;
    string subjectType;
    string firstName;
    string lastName;
    string email;
    string phoneNumber;
    string dateOfBirth;
    string nationality;
    string organizationName;
    string organizationId;
    string externalId;
    string createdBy;
}

struct UpdateDataSubjectRequest {
    TenantId tenantId;
    string id;
    string firstName;
    string lastName;
    string email;
    string phoneNumber;
    string organizationName;
    string modifiedBy;
}

// --- Data Subject Request ---
struct CreateDataSubjectRequestRequest {
    TenantId tenantId;
    string id;
    string dataSubjectId;
    string requestType;
    string priority;
    string description;
    string[] applicationIds;
    string[] dataCategoryIds;
    string assignedTo;
    string dueDate;
    string createdBy;
}

struct UpdateDataSubjectRequestRequest {
    TenantId tenantId;
    string id;
    string status;
    string assignedTo;
    string rejectionReason;
    string commentAuthor;
    string commentText;
    string modifiedBy;
}

// --- Personal Data Record ---
struct CreatePersonalDataRecordRequest {
    TenantId tenantId;
    string id;
    string dataSubjectId;
    string applicationId;
    string dataCategoryId;
    string sensitivity;
    string fieldName;
    string fieldValue;
    string purposeId;
    string legalBasis;
    string sourceSystem;
    string retentionRuleId;
    string createdBy;
}

// --- Registered Application ---
struct CreateRegisteredApplicationRequest {
    TenantId tenantId;
    string id;
    string name;
    string description;
    string endpointUrl;
    string apiVersion;
    string[] dataCategoryIds;
    string[] purposeIds;
    string contactEmail;
    string contactName;
    string registeredBy;
}

struct UpdateRegisteredApplicationRequest {
    TenantId tenantId;
    string id;
    string name;
    string description;
    string endpointUrl;
    string apiVersion;
    string contactEmail;
    string contactName;
    string modifiedBy;
}

// --- Processing Purpose ---
struct CreateProcessingPurposeRequest {
    TenantId tenantId;
    string id;
    string name;
    string description;
    string legalBasis;
    string[] dataCategoryIds;
    string[] applicationIds;
    string retentionPeriod;
    string dataProtectionOfficer;
    bool requiresConsent;
    string createdBy;
}

struct UpdateProcessingPurposeRequest {
    TenantId tenantId;
    string id;
    string name;
    string description;
    string legalBasis;
    string retentionPeriod;
    string dataProtectionOfficer;
    bool requiresConsent;
    string modifiedBy;
}

// --- Consent Record ---
struct CreateConsentRecordRequest {
    TenantId tenantId;
    string id;
    string dataSubjectId;
    string purposeId;
    string consentText;
    string consentVersion;
    string expiresAt;
    string ipAddress;
    string userAgent;
    string source;
    string createdBy;
}

struct WithdrawConsentRequest {
    TenantId tenantId;
    string id;
    string withdrawnBy;
}

// --- Retention Rule ---
struct CreateRetentionRuleRequest {
    TenantId tenantId;
    string id;
    string name;
    string description;
    int retentionPeriod;
    string periodUnit;
    string[] dataCategoryIds;
    string[] applicationIds;
    string[] purposeIds;
    bool autoDelete;
    bool notifyBeforeExpiry;
    int notifyDaysBefore;
    string createdBy;
}

struct UpdateRetentionRuleRequest {
    TenantId tenantId;
    string id;
    string name;
    string description;
    int retentionPeriod;
    string periodUnit;
    bool autoDelete;
    bool notifyBeforeExpiry;
    int notifyDaysBefore;
    string modifiedBy;
}

// --- Data Processing Log ---
struct CreateDataProcessingLogRequest {
    TenantId tenantId;
    string id;
    string entryType;
    string severity;
    string dataSubjectId;
    string applicationId;
    string requestId;
    string operatorId;
    string action;
    string details;
    string affectedFields;
    string ipAddress;
}

// --- Data Export ---
struct ExportPersonalDataRequest {
    TenantId tenantId;
    string dataSubjectId;
    string format;
}
