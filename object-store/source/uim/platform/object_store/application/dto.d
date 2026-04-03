/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.object_store.application.dto;

import uim.platform.object_store.domain.types;

/// --- Command result ---

struct CommandResult
{
  bool success;
  string id;
  string error;
}

/// --- Bucket DTOs ---

struct CreateBucketRequest
{
  TenantId tenantId;
  string name;
  string region;
  string storageClass; // "standard", "nearline", "coldline", "archive"
  bool versioningEnabled;
  string encryptionType; // "none", "sse_s3", "sse_kms", "sse_c"
  string encryptionKeyId;
  long quotaBytes;
  UserId createdBy;
}

struct UpdateBucketRequest
{
  string storageClass;
  bool versioningEnabled;
  string encryptionType;
  string encryptionKeyId;
  long quotaBytes;
}

/// --- Storage Object DTOs ---

struct CreateObjectRequest
{
  TenantId tenantId;
  BucketId bucketId;
  string key;
  string contentType;
  long size;
  string metadata; // JSON key-value pairs
  string storageClass;
  UserId createdBy;
}

struct UpdateObjectMetadataRequest
{
  string contentType;
  string metadata;
  string storageClass;
}

struct CopyObjectRequest
{
  TenantId tenantId;
  BucketId sourceBucketId;
  string sourceKey;
  BucketId destBucketId;
  string destKey;
  UserId createdBy;
}

/// --- Access Policy DTOs ---

struct CreateAccessPolicyRequest
{
  TenantId tenantId;
  BucketId bucketId;
  string name;
  string effect; // "allow", "deny"
  string principal;
  string actions; // JSON array
  string resources; // JSON array
  UserId createdBy;
}

struct UpdateAccessPolicyRequest
{
  string name;
  string effect;
  string principal;
  string actions;
  string resources;
}

/// --- Lifecycle Rule DTOs ---

struct CreateLifecycleRuleRequest
{
  TenantId tenantId;
  BucketId bucketId;
  string name;
  string prefix;
  string status; // "enabled", "disabled"
  int expirationDays;
  int transitionDays;
  string transitionStorageClass;
  int abortIncompleteUploadDays;
  UserId createdBy;
}

struct UpdateLifecycleRuleRequest
{
  string name;
  string prefix;
  string status;
  int expirationDays;
  int transitionDays;
  string transitionStorageClass;
  int abortIncompleteUploadDays;
}

/// --- CORS Rule DTOs ---

struct CreateCorsRuleRequest
{
  TenantId tenantId;
  BucketId bucketId;
  string allowedOrigins; // JSON array
  string allowedMethods; // JSON array
  string allowedHeaders; // JSON array
  string exposedHeaders; // JSON array
  int maxAgeSeconds;
}

struct UpdateCorsRuleRequest
{
  string allowedOrigins;
  string allowedMethods;
  string allowedHeaders;
  string exposedHeaders;
  int maxAgeSeconds;
}

/// --- Service Binding DTOs ---

struct CreateServiceBindingRequest
{
  TenantId tenantId;
  BucketId bucketId;
  string name;
  string permission; // "readOnly", "readWrite", "admin"
  long expiresAt;
  UserId createdBy;
}
