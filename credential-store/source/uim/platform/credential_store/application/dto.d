/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.credential_store.application.dto;

import uim.platform.credential_store;

mixin(ShowModule!());

@safe:
// Namespace DTOs
struct CreateNamespaceRequest {
  TenantId tenantId;
  string name;
  string description;
  UserId createdBy;
}

struct UpdateNamespaceRequest {
  string description;
}

// Credential DTOs
struct CreateCredentialRequest {
  TenantId tenantId;
  NamespaceId namespaceId;
  string name;
  string type;       // "password", "key", "keyring"
  string value;
  string metadata;
  string format;
  string username;
  UserId createdBy;
  string ifNoneMatch; // "*" = create only, empty = create or update
}

struct UpdateCredentialRequest {
  string value;
  string metadata;
  string format;
  string username;
  UserId updatedBy;
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
  NamespaceId namespaceId;
  string name;
  string metadata;
  string format;
  int rotationPeriodDays;
  UserId createdBy;
}

struct RotateKeyringRequest {
  CredentialId keyringId;
  TenantId tenantId;
}

// DEK Encryption DTOs
struct GenerateDekRequest {
  TenantId tenantId;
  NamespaceId namespaceId;
  string keyringName;
}

struct GenerateDekResponse {
  bool success;
  string dek;         // plaintext DEK
  string encryptedDek; // DEK encrypted with keyring
  CredentialId keyringId;
  long keyringVersion;
  string error;
}

struct EncryptDekRequest {
  TenantId tenantId;
  NamespaceId namespaceId;
  string keyringName;
  string dek;           // plaintext DEK to encrypt
}

struct EncryptDekResponse {
  bool success;
  string encryptedDek;
  CredentialId keyringId;
  long keyringVersion;
  string error;
}

struct DecryptDekRequest {
  TenantId tenantId;
  NamespaceId namespaceId;
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
  NamespaceId[] allowedNamespaces;
  long expiresAt;
  UserId createdBy;
}

struct UpdateServiceBindingRequest {
  string description;
  string permission;
  string status;           // "active", "revoked"
  NamespaceId[] allowedNamespaces;
}

struct ServiceBindingResponse {
  string id;
  string name;
  string clientId;
  string clientSecret;     // only returned on creation
  string permission;
  string status;
  NamespaceId[] allowedNamespaces;
  long createdAt;
  long expiresAt;
}

// Audit DTOs
struct AuditLogFilter {
  TenantId tenantId;
  NamespaceId namespaceId;
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
