/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// The user settable fields of each aggregate. Field names equal the entity's,
/// so adapters derive the spec of an existing entity for PATCH semantics.
module uim.platform.object_store.application.dtos.specs;

import uim.platform.object_store;

mixin(ShowModule!());

@safe:

// ── Buckets ──────────────────────────────────────────────────────────────────

struct BucketSpec {
  string name; /// fixed after creation
  string description;
  IaasProvider provider = IaasProvider.aws; /// fixed after creation
  string region; /// fixed after creation; "" = configured default
  StorageClass storageClass = StorageClass.standard;
  bool versioningEnabled;
  EncryptionType encryptionType = EncryptionType.sseS3;
  string encryptionKeyId;
  bool publicAccessBlocked = true;
  long quotaBytes;
  MetadataEntry[] labels;
}

alias CreateBucketRequest = CreateRootRequest!BucketSpec;
alias UpdateBucketRequest = UpdateRequest!(BucketId, BucketSpec);

// ── Objects (parent = bucket) ────────────────────────────────────────────────

struct ObjectSpec {
  string name; /// object key, fixed after creation
  string contentType;
  MetadataEntry[] metadata;
  StorageClass storageClass = StorageClass.standard; /// on create: standard = bucket default
  string content; /// "" on update = keep the content; otherwise a new version
  ContentEncoding contentEncoding = ContentEncoding.text;
}

alias CreateObjectRequest = CreateRequest!(BucketId, ObjectSpec);
alias UpdateObjectRequest = UpdateRequest!(StorageObjectId, ObjectSpec);

// ── Versions (created by writing objects; nothing is settable) ───────────────

struct VersionSpec {
}

alias CreateVersionRequest = CreateRequest!(StorageObjectId, VersionSpec);
alias UpdateVersionRequest = UpdateRequest!(ObjectVersionId, VersionSpec);

// ── Access policies (parent = bucket) ────────────────────────────────────────

struct AccessPolicySpec {
  string name;
  string description;
  PolicyEffect effect = PolicyEffect.allow;
  string[] principals;
  PolicyAction[] actions;
  string[] resources;
  bool enabled = true;
}

alias CreateAccessPolicyRequest = CreateRequest!(BucketId, AccessPolicySpec);
alias UpdateAccessPolicyRequest = UpdateRequest!(AccessPolicyId, AccessPolicySpec);

// ── Lifecycle rules (parent = bucket) ────────────────────────────────────────

struct LifecycleRuleSpec {
  string name;
  string prefix;
  RuleStatus status = RuleStatus.enabled;
  int expirationDays;
  int transitionDays;
  StorageClass transitionStorageClass = StorageClass.coldline;
  int noncurrentVersionExpirationDays;
}

alias CreateLifecycleRuleRequest = CreateRequest!(BucketId, LifecycleRuleSpec);
alias UpdateLifecycleRuleRequest = UpdateRequest!(LifecycleRuleId, LifecycleRuleSpec);

// ── CORS rules (parent = bucket) ─────────────────────────────────────────────

struct CorsRuleSpec {
  string name;
  string[] allowedOrigins;
  CorsMethod[] allowedMethods;
  string[] allowedHeaders;
  string[] exposedHeaders;
  int maxAgeSeconds = 3600;
}

alias CreateCorsRuleRequest = CreateRequest!(BucketId, CorsRuleSpec);
alias UpdateCorsRuleRequest = UpdateRequest!(CorsRuleId, CorsRuleSpec);

// ── Service bindings (parent = bucket) ───────────────────────────────────────

struct ServiceBindingSpec {
  string name;
  string description;
  BindingPermission permission = BindingPermission.readOnly;
  long expiresAt; /// 0 = never
}

alias CreateServiceBindingRequest = CreateRequest!(BucketId, ServiceBindingSpec);
alias UpdateServiceBindingRequest = UpdateRequest!(ServiceBindingId, ServiceBindingSpec);
