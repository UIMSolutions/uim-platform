/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.credential_store.application.dto;

// Namespace DTOs
struct CreateNamespaceRequest {
  TenantId tenantId;
  string name;
  string description;
  string createdBy;
}

struct UpdateNamespaceRequest {
  string description;
}

// Credential DTOs
struct CreateCredentialRequest {
  TenantId tenantId;
  string namespaceId;
  string name;
  string type;       // "password", "key", "keyring"
  string value;
  string metadata;
  string format;
  string username;
  string createdBy;
  string ifNoneMatch; // "*" = create only, empty = create or update
}

struct UpdateCredentialRequest {
  string value;
  string metadata;
  string format;
  string username;
  string modifiedBy;
  string ifMatch;    // "*" = update only, "<id>" = conditional update
}

struct CredentialResponse {
  string id;
  string name;
  string type;
  string value;
  string metadata;
  string format;
  string username;
  string status;
  long version_;
  long createdAt;
  long updatedAt;
}

// Keyring DTOs
struct CreateKeyringRequest {
  TenantId tenantId;
  string namespaceId;
  string name;
  string metadata;
  string format;
  int rotationPeriodDays;
  string createdBy;
}

struct RotateKeyringRequest {
  string keyringId;
  TenantId tenantId;
}

// DEK Encryption DTOs
struct GenerateDekRequest {
  TenantId tenantId;
  string namespaceId;
  string keyringName;
}

struct GenerateDekResponse {
  bool success;
  string dek;         // plaintext DEK
  string encryptedDek; // DEK encrypted with keyring
  string keyringId;
  long keyringVersion;
  string error;
}

struct EncryptDekRequest {
  TenantId tenantId;
  string namespaceId;
  string keyringName;
  string dek;           // plaintext DEK to encrypt
}

struct EncryptDekResponse {
  bool success;
  string encryptedDek;
  string keyringId;
  long keyringVersion;
  string error;
}

struct DecryptDekRequest {
  TenantId tenantId;
  string namespaceId;
  string keyringName;
  string encryptedDek;   // encrypted DEK to decrypt
  long keyringVersion;   // version used for encryption
}

struct DecryptDekResponse {
  bool success;
  string dek;           // decrypted DEK
  string error;
}

// Service Binding DTOs
struct CreateServiceBindingRequest {
  TenantId tenantId;
  string name;
  string description;
  string permission;       // "readOnly", "readWrite", "admin"
  string[] allowedNamespaces;
  long expiresAt;
  string createdBy;
}

struct UpdateServiceBindingRequest {
  string description;
  string permission;
  string status;           // "active", "revoked"
  string[] allowedNamespaces;
}

struct ServiceBindingResponse {
  string id;
  string name;
  string clientId;
  string clientSecret;     // only returned on creation
  string permission;
  string status;
  string[] allowedNamespaces;
  long createdAt;
  long expiresAt;
}

// Audit DTOs
struct AuditLogFilter {
  TenantId tenantId;
  string namespaceId;
  string resourceType;
  long startTime;
  long endTime;
}

// Overview
struct OverviewSummary {
  long totalNamespaces;
  long totalCredentials;
  long totalPasswords;
  long totalKeys;
  long totalKeyrings;
  long totalBindings;
  long totalAuditEntries;
}
