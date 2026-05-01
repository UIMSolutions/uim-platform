/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.master_data_integration.application.dto;

import uim.platform.master_data_integration.domain.types;



/// --- Master Data Object DTOs ---

struct CreateMasterDataObjectRequest {
  TenantId tenantId;
  DataModelId dataModelId;
  string category; // "businessPartner", "costCenter", etc.
  string objectType;
  string displayName;
  string description;
  string localId;
  string globalId;
  string[string] attributes;
  string sourceSystem;
  string sourceClient;
  UserId createdBy;
}

struct UpdateMasterDataObjectRequest {
  string displayName;
  string description;
  string status; // "active", "inactive", "blocked", "markedForDeletion"
  string[string] attributes;
  UserId updatedBy;
}

/// --- Data Model DTOs ---

struct CreateDataModelRequest {
  TenantId tenantId;
  string name;
  string namespace;
  string version_;
  string description;
  string category;
  FieldDefinitionDto[] fields;
  string[] keyFields;
  string[] requiredFields;
  UserId createdBy;
}

struct UpdateDataModelRequest {
  string description;
  string version_;
  FieldDefinitionDto[] fields;
  string[] keyFields;
  string[] requiredFields;
}

struct FieldDefinitionDto {
  string name;
  string displayName;
  string type_; // "string", "integer", "decimal", etc.
  bool isRequired;
  bool isKey;
  string defaultValue;
  int maxLength;
  string referenceModel;
  string description;
}

/// --- Distribution Model DTOs ---

struct CreateDistributionModelRequest {
  TenantId tenantId;
  string name;
  string description;
  string direction; // "outbound", "inbound", "bidirectional"
  ClientId sourceClientId;
  ClientId[] targetClientIds;
  string[] categories;
  DataModelId[] dataModelIds;
  FilterRuleId[] filterRuleIds;
  bool autoReplicate;
  string cronSchedule;
  UserId createdBy;
}

struct UpdateDistributionModelRequest {
  string name;
  string description;
  string status; // "active", "inactive", "draft"
  ClientId[] targetClientIds;
  string[] categories;
  DataModelId[] dataModelIds;
  FilterRuleId[] filterRuleIds;
  bool autoReplicate;
  string cronSchedule;
}

/// --- Key Mapping DTOs ---

struct CreateKeyMappingRequest {
  TenantId tenantId;
  MasterDataObjectId masterDataObjectId;
  string category;
  string objectType;
  KeyMappingEntryDto[] entries;
}

struct UpdateKeyMappingRequest {
  KeyMappingEntryDto[] entries;
}

struct KeyMappingEntryDto {
  ClientId clientId;
  string systemId;
  string localKey;
  string sourceType; // "local", "remote", "universal"
  bool isPrimary;
}

struct LookupKeyRequest {
  TenantId tenantId;
  ClientId sourceClientId;
  string sourceLocalKey;
  ClientId targetClientId;
}

/// --- Client DTOs ---

struct CreateClientRequest {
  TenantId tenantId;
  string name;
  string description;
  string clientType; // "sapS4Hana", "sapSuccessFactors", etc.
  string systemUrl;
  string destinationName;
  string communicationArrangement;
  string[] supportedCategories;
  bool supportsInitialLoad;
  bool supportsDeltaReplication;
  bool supportsKeyMapping;
  string authType;
  string clientIdRef;
  string certificateRef;
  UserId createdBy;
}

struct UpdateClientRequest {
  string name;
  string description;
  string status; // "connected", "disconnected", "error", "suspended"
  string systemUrl;
  string destinationName;
  string communicationArrangement;
  string[] supportedCategories;
  string authType;
  string clientIdRef;
  string certificateRef;
}

/// --- Replication Job DTOs ---

struct CreateReplicationJobRequest {
  TenantId tenantId;
  DistributionModelId distributionModelId;
  string name;
  string description;
  string trigger; // "manual", "scheduled", "eventDriven", "onChange"
  string[] categories;
  ClientId sourceClientId;
  ClientId[] targetClientIds;
  bool isInitialLoad;
  UserId createdBy;
}

/// --- Filter Rule DTOs ---

struct CreateFilterRuleRequest {
  TenantId tenantId;
  string name;
  string description;
  string category;
  DataModelId dataModelId;
  string objectType;
  FilterConditionDto[] conditions;
  string logicOperator; // "AND" or "OR"
  UserId createdBy;
}

struct UpdateFilterRuleRequest {
  string name;
  string description;
  FilterConditionDto[] conditions;
  string logicOperator;
  bool isActive;
}

struct FilterConditionDto {
  string fieldName;
  string operator; // "equals", "contains", "inList", etc.
  string value;
  string[] valueList;
  string lowerBound;
  string upperBound;
}

/// --- Change Log DTOs ---

struct ChangeLogQueryRequest {
  TenantId tenantId;
  MasterDataObjectId objectId;
  string category;
  string deltaToken;
  long sinceTimestamp;
}
