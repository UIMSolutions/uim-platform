/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data.privacy.application.dto;

import uim.platform.data.privacy;

mixin(ShowModule!());

@safe:
// ──────────────── Data Subject DTOs ────────────────

struct CreateDataSubjectRequest {
  TenantId tenantId;
  DataSubjectType subjectType;
  string externalId;
  string displayName;
  string email;
  string sourceSystem;
  string country;
}

struct UpdateDataSubjectRequest {
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

struct CreatePersonalDataModelRequest {
  TenantId tenantId;
  string fieldName;
  string fieldDescription;
  string category;
  string sensitivity;
  string sourceSystem;
  string sourceEntity;
  string subjectType;
  bool isSpecialCategory;
  string legalReference;
}

struct UpdatePersonalDataModelRequest {
  PersonalDataModelId id;
  TenantId tenantId;
  string fieldName;
  string fieldDescription;
  string category;
  string sensitivity;
  string sourceSystem;
  string sourceEntity;
  bool isSpecialCategory;
  string legalReference;
}
// ──────────────── Deletion Request DTOs ────────────────

struct CreateDeletionRequest {
  TenantId tenantId;
  DataSubjectId dataSubjectId;
  UserId requestedBy;

  string[] targetSystems;
  string blockerReason;
  string[] categories;
  string reason;
}

struct UpdateDeletionStatusRequest {
  DeletionRequestId requestId;
  TenantId tenantId;
  string status;
  string blockerReason;
}
// ──────────────── Blocking Request DTOs ────────────────

struct CreateBlockingRequest {
  TenantId tenantId;
  DataSubjectId dataSubjectId;
  UserId requestedBy;
  string[] targetSystems;
  string[] categories;
  string reason;
}

struct UpdateBlockingStatusRequest {
  BlockingRequestId id;
  TenantId tenantId;
  string status;
}
// ──────────────── Legal Ground DTOs ────────────────

struct CreateLegalGroundRequest {
  TenantId tenantId;
  DataSubjectId dataSubjectId;
  LegalBasis basis;
  string purpose;
  string description;
  string legalReference;
  string[] categories;
  long validFrom;
  long validUntil;
}

struct UpdateLegalGroundRequest {
  LegalGroundId id;
  TenantId tenantId;
  string description;
  string legalReference;
  string[] categories;
  bool isActive;
  long validUntil;
}
// ──────────────── Retention Rule DTOs ────────────────

struct CreateRetentionRuleRequest {
  TenantId tenantId;
  string name;
  string description;
  string purpose;
  string[] categories;
  int retentionDays;
  string legalReference;
  bool isDefault;
}

struct UpdateRetentionRuleRequest {
  RetentionRuleId id;
  TenantId tenantId;
  string name;
  string description;
  int retentionDays;
  string[] categories;
  string legalReference;
  string status;
}
// ──────────────── Consent Record DTOs ────────────────

struct CreateConsentRecordRequest {
  TenantId tenantId;
  DataSubjectId dataSubjectId;

  string purpose;
  string[] categories;
  string channel;
  string consentText;
  string version_;
  string ipAddress;
  long expiresAt;
}

struct RevokeConsentRequest {
  ConsentRecordId id;
  TenantId tenantId;
}
// ──────────────── Data Retrieval Request DTOs ────────────────

struct CreateDataRetrievalRequest {
  TenantId tenantId;
  DataSubjectId dataSubjectId;
  UserId requestedBy;
  string[] targetSystems;
  string[] categories;
  string reason;
}

struct UpdateRetrievalStatusRequest {
  DataRetrievalRequestId id;
  TenantId tenantId;
  string status;
  string downloadUrl;
  long totalFields;
}
// ──────────────── Generic result ────────────────

// ──────────────── Data Controller DTOs ────────────────

struct CreateDataControllerRequest {
  TenantId tenantId;
  string name;
  string description;
  string legalEntityName;
  string contactEmail;
  string contactPhone;
  string address;
  string country;
  string dpoName;
  string dpoEmail;
}

struct UpdateDataControllerRequest {
  DataControllerId controllerId;
  TenantId tenantId;
  string name;
  string description;
  string legalEntityName;
  string contactEmail;
  string contactPhone;
  string address;
  string country;
  string dpoName;
  string dpoEmail;
  bool isActive;
}
// ──────────────── Data Controller Group DTOs ────────────────

struct CreateDataControllerGroupRequest {
  TenantId tenantId;
  string name;
  string description;
  DataControllerId[] controllerIds;
}

struct UpdateDataControllerGroupRequest {
  DataControllerGroupId groupId;
  TenantId tenantId;
  string name;
  string description;
  DataControllerId[] controllerIds;
  bool isActive;
}
// ──────────────── Business Context DTOs ────────────────

struct CreateBusinessContextRequest {
  TenantId tenantId;
  string name;
  string description;
  DataControllerGroupId controllerGroupId;
  string[] dataCategories;
  string[] purposes;
  string[] dataCategoryAttributes;
  bool isCrossRoleEnabled;
}

struct UpdateBusinessContextRequest {
  BusinessContextId contextId;
  TenantId tenantId;
  string name;
  string description;
  string[] dataCategories;
  string[] purposes;
  string[] dataCategoryAttributes;
  bool isCrossRoleEnabled;
}

struct ActivateBusinessContextRequest {
  BusinessContextId contextId;
  TenantId tenantId;
}
// ──────────────── Business Process DTOs ────────────────

struct CreateBusinessProcessRequest {
  TenantId tenantId;
  string name;
  string description;
  DataControllerId controllerId;
  string[] purposes;
  string[] legalBases;
  string owner;
}

struct UpdateBusinessProcessRequest {
  BusinessProcessId processId;
  TenantId tenantId;
  string name;
  string description;
  string[] purposes;
  string[] legalBases;
  string owner;
  bool isActive;
}
// ──────────────── Business Subprocess DTOs ────────────────

struct CreateBusinessSubprocessRequest {
  TenantId tenantId;
  BusinessProcessId parentProcessId;
  
  string name;
  string description;
  string[] purposes;
  string[] dataCategories;
  string owner;
}

struct UpdateBusinessSubprocessRequest {
  BusinessSubprocessId subprocessId;
  TenantId tenantId;
  string name;
  string description;
  string[] purposes;
  string[] dataCategories;
  string owner;
  bool isActive;
}
// ──────────────── Correction Request DTOs ────────────────

struct CreateCorrectionRequest {
  TenantId tenantId;
  DataSubjectId subjectId;
  UserId requestedBy;
  string[] targetSystems;
  string fieldName;
  string currentValue;
  string correctedValue;
  string reason;
}

struct UpdateCorrectionStatusRequest {
  CorrectionRequestId requestId;
  TenantId tenantId;
  string status;
}
// ──────────────── Archive Request DTOs ────────────────

struct CreateArchiveRequest {
  TenantId tenantId;
  DataSubjectId subjectId;
  UserId requestedBy;
  string[] targetSystems;
  string[] categories;
  string archiveLocation;
  string reason;
  bool isTestMode;
  long scheduledAt;
}

struct UpdateArchiveStatusRequest {
  ArchiveRequestId requestId;
  TenantId tenantId;
  string status;
}
// ──────────────── Destruction Request DTOs ────────────────

struct CreateDestructionRequest {
  TenantId tenantId;
  DataSubjectId dataSubjectId;
  UserId requestedBy;
  string[] targetSystems;
  string archiveRequestId;
  string blockingRequestId;
  string reason;
  long scheduledAt;
}

struct UpdateDestructionStatusRequest {
  DestructionRequestId requestId;
  TenantId tenantId;
  string status;
}
// ──────────────── Purpose Record DTOs ────────────────

struct CreatePurposeRecordRequest {
  TenantId tenantId;
  DataSubjectId subjectId;
  BusinessContextId contextId;
  string purpose;
  string legalBasis;
  int residenceDays;
  int retentionDays;
  long validFrom;
  long validUntil;
}

struct DeactivatePurposeRecordRequest {
  PurposeRecordId recordId;
  TenantId tenantId;
}
// ──────────────── Consent Purpose DTOs ────────────────

struct CreateConsentPurposeRequest {
  TenantId tenantId;
  DataControllerId controllerId;
  string name;
  string description;
  string purpose;
  string[] dataCategories;
  string consentFormTemplate;
  string version_;
  bool requiresExplicitConsent;
  long validFrom;
  long validUntil;
}

struct UpdateConsentPurposeRequest {
  ConsentPurposeId purposeId;
  TenantId tenantId;
  string name;
  string description;
  string consentFormTemplate;
  string version_;
  bool requiresExplicitConsent;
  string status;
}
// ──────────────── Rule Set DTOs ────────────────

struct CreateRuleSetRequest {
  TenantId tenantId;
  BusinessContextId contextId;
  string name;
  string description;
  string conditionsJson; // serialized RuleCondition array
  string resultPurposesJson; // serialized ProcessingPurpose array
  int priority;
}

struct UpdateRuleSetRequest {
  RuleSetId setId;
  TenantId tenantId;
  string name;
  string description;
  string conditionsJson;
  string resultPurposesJson;
  int priority;
  string status;
}
// ──────────────── Information Report DTOs ────────────────

struct CreateInformationReportRequest {
  TenantId tenantId;
  DataSubjectId subjectId;
  UserId requestedBy;
  string format; // pdf, json, xml, csv
  string[] targetSystems;
  string[] categories;
  string reason;
}

struct UpdateInformationReportStatusRequest {
  InformationReportId reportId;
  TenantId tenantId;
  string status;
  string downloadUrl;
  long totalRecords;
}
// ──────────────── Anonymization Config DTOs ────────────────

struct CreateAnonymizationConfigRequest {
  TenantId tenantId;
  string name;
  string description;
  string rulesJson; // serialized AnonymizationRule array
  bool isReversible;
  string[] targetSystems;
}

struct UpdateAnonymizationConfigRequest {
  AnonymizationConfigId configId;
  TenantId tenantId;
  string name;
  string description;
  string rulesJson;
  bool isReversible;
  string[] targetSystems;
  string status;
}
