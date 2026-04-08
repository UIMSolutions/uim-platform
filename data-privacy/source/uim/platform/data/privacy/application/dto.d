/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data.privacy.application.dto;

// import uim.platform.data.privacy.domain.types;
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
  PersonalDataCategory category;
  DataSensitivity sensitivity;
  string sourceSystem;
  string sourceEntity;
  DataSubjectType subjectType;
  bool isSpecialCategory;
  string legalReference;
}

struct UpdatePersonalDataModelRequest {
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

struct CreateDeletionRequest {
  TenantId tenantId;
  DataSubjectId dataSubjectId;
  UserId requestedBy;
  string[] targetSystems;
  PersonalDataCategory[] categories;
  string reason;
}

struct UpdateDeletionStatusRequest {
  DeletionRequestId id;
  TenantId tenantId;
  DeletionStatus status;
  string blockerReason;
}

// ──────────────── Blocking Request DTOs ────────────────

struct CreateBlockingRequest {
  TenantId tenantId;
  DataSubjectId dataSubjectId;
  UserId requestedBy;
  string[] targetSystems;
  PersonalDataCategory[] categories;
  string reason;
}

struct UpdateBlockingStatusRequest {
  BlockingRequestId id;
  TenantId tenantId;
  BlockingStatus status;
}

// ──────────────── Legal Ground DTOs ────────────────

struct CreateLegalGroundRequest {
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

struct UpdateLegalGroundRequest {
  LegalGroundId id;
  TenantId tenantId;
  string description;
  string legalReference;
  PersonalDataCategory[] categories;
  bool isActive;
  long validUntil;
}

// ──────────────── Retention Rule DTOs ────────────────

struct CreateRetentionRuleRequest {
  TenantId tenantId;
  string name;
  string description;
  ProcessingPurpose purpose;
  PersonalDataCategory[] categories;
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
  PersonalDataCategory[] categories;
  string legalReference;
  RetentionRuleStatus status;
}

// ──────────────── Consent Record DTOs ────────────────

struct CreateConsentRecordRequest {
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
  PersonalDataCategory[] categories;
  string reason;
}

struct UpdateRetrievalStatusRequest {
  DataRetrievalRequestId id;
  TenantId tenantId;
  RetrievalStatus status;
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
  DataControllerId id;
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
  DataControllerGroupId id;
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
  PersonalDataCategory[] dataCategories;
  ProcessingPurpose[] purposes;
  string[] dataCategoryAttributes;
  bool isCrossRoleEnabled;
}

struct UpdateBusinessContextRequest {
  BusinessContextId id;
  TenantId tenantId;
  string name;
  string description;
  PersonalDataCategory[] dataCategories;
  ProcessingPurpose[] purposes;
  string[] dataCategoryAttributes;
  bool isCrossRoleEnabled;
}

struct ActivateBusinessContextRequest {
  BusinessContextId id;
  TenantId tenantId;
}

// ──────────────── Business Process DTOs ────────────────

struct CreateBusinessProcessRequest {
  TenantId tenantId;
  string name;
  string description;
  DataControllerId controllerId;
  ProcessingPurpose[] purposes;
  LegalBasis[] legalBases;
  string owner;
}

struct UpdateBusinessProcessRequest {
  BusinessProcessId id;
  TenantId tenantId;
  string name;
  string description;
  ProcessingPurpose[] purposes;
  LegalBasis[] legalBases;
  string owner;
  bool isActive;
}

// ──────────────── Business Subprocess DTOs ────────────────

struct CreateBusinessSubprocessRequest {
  TenantId tenantId;
  BusinessProcessId parentProcessId;
  string name;
  string description;
  ProcessingPurpose[] purposes;
  PersonalDataCategory[] dataCategories;
  string owner;
}

struct UpdateBusinessSubprocessRequest {
  BusinessSubprocessId id;
  TenantId tenantId;
  string name;
  string description;
  ProcessingPurpose[] purposes;
  PersonalDataCategory[] dataCategories;
  string owner;
  bool isActive;
}

// ──────────────── Correction Request DTOs ────────────────

struct CreateCorrectionRequest {
  TenantId tenantId;
  DataSubjectId dataSubjectId;
  UserId requestedBy;
  string[] targetSystems;
  string fieldName;
  string currentValue;
  string correctedValue;
  string reason;
}

struct UpdateCorrectionStatusRequest {
  CorrectionRequestId id;
  TenantId tenantId;
  CorrectionStatus status;
}

// ──────────────── Archive Request DTOs ────────────────

struct CreateArchiveRequest {
  TenantId tenantId;
  DataSubjectId dataSubjectId;
  UserId requestedBy;
  string[] targetSystems;
  PersonalDataCategory[] categories;
  string archiveLocation;
  string reason;
  bool isTestMode;
  long scheduledAt;
}

struct UpdateArchiveStatusRequest {
  ArchiveRequestId id;
  TenantId tenantId;
  ArchiveStatus status;
}

// ──────────────── Destruction Request DTOs ────────────────

struct CreateDestructionRequest {
  TenantId tenantId;
  DataSubjectId dataSubjectId;
  UserId requestedBy;
  string[] targetSystems;
  ArchiveRequestId archiveRequestId;
  BlockingRequestId blockingRequestId;
  string reason;
  long scheduledAt;
}

struct UpdateDestructionStatusRequest {
  DestructionRequestId id;
  TenantId tenantId;
  DestructionStatus status;
}

// ──────────────── Purpose Record DTOs ────────────────

struct CreatePurposeRecordRequest {
  TenantId tenantId;
  DataSubjectId dataSubjectId;
  BusinessContextId businessContextId;
  ProcessingPurpose purpose;
  LegalBasis legalBasis;
  int residenceDays;
  int retentionDays;
  long validFrom;
  long validUntil;
}

struct DeactivatePurposeRecordRequest {
  PurposeRecordId id;
  TenantId tenantId;
}

// ──────────────── Consent Purpose DTOs ────────────────

struct CreateConsentPurposeRequest {
  TenantId tenantId;
  DataControllerId controllerId;
  string name;
  string description;
  ProcessingPurpose purpose;
  PersonalDataCategory[] dataCategories;
  string consentFormTemplate;
  string version_;
  bool requiresExplicitConsent;
  long validFrom;
  long validUntil;
}

struct UpdateConsentPurposeRequest {
  ConsentPurposeId id;
  TenantId tenantId;
  string name;
  string description;
  string consentFormTemplate;
  string version_;
  bool requiresExplicitConsent;
  ConsentPurposeStatus status;
}

// ──────────────── Rule Set DTOs ────────────────

struct CreateRuleSetRequest {
  TenantId tenantId;
  BusinessContextId businessContextId;
  string name;
  string description;
  string conditionsJson; // serialized RuleCondition array
  string resultPurposesJson; // serialized ProcessingPurpose array
  int priority;
}

struct UpdateRuleSetRequest {
  RuleSetId id;
  TenantId tenantId;
  string name;
  string description;
  string conditionsJson;
  string resultPurposesJson;
  int priority;
  RuleSetStatus status;
}

// ──────────────── Information Report DTOs ────────────────

struct CreateInformationReportRequest {
  TenantId tenantId;
  DataSubjectId dataSubjectId;
  UserId requestedBy;
  string format; // pdf, json, xml, csv
  string[] targetSystems;
  PersonalDataCategory[] categories;
  string reason;
}

struct UpdateInformationReportStatusRequest {
  InformationReportId id;
  TenantId tenantId;
  InformationReportStatus status;
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
  AnonymizationConfigId id;
  TenantId tenantId;
  string name;
  string description;
  string rulesJson;
  bool isReversible;
  string[] targetSystems;
  AnonymizationConfigStatus status;
}
