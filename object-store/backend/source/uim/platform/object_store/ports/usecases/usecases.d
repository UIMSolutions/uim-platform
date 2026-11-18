/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Driving ports of the use cases (implemented by application.usecases).
///
/// Mutations return a UsecaseResult; on failure `code` carries an HTTP-like
/// status (403 access denied, 404 not found, 405 not supported, 409 conflict,
/// 422 business rule violated).
module uim.platform.object_store.ports.usecases.usecases;

import uim.platform.object_store;

mixin(ShowModule!());

@safe:

/// Shape shared by all aggregates: create / update / remove / read.
interface IManageResource(TEntity, TId, TCreate, TUpdate) {
  UsecaseResult create(TCreate request);
  UsecaseResult update(TUpdate request);
  UsecaseResult remove(TenantId tenantId, TId id, UserId actor);

  /// TEntity.init (isNull) if not found.
  TEntity get(TenantId tenantId, TId id);
  TEntity[] list(TenantId tenantId);
}

/// Buckets: create, configure, suspend / resume, empty, delete (must be empty).
interface IManageBucketsUseCase : IManageResource!(Bucket, BucketId, CreateBucketRequest, UpdateBucketRequest) {
  /// active → suspended (read-only).
  UsecaseResult suspend(TenantId tenantId, BucketId id, UserId actor);
  /// suspended → active.
  UsecaseResult resume(TenantId tenantId, BucketId id, UserId actor);
  /// Permanently delete every object and version (refused if any is on legal hold).
  UsecaseResult empty(TenantId tenantId, BucketId id, UserId actor);
  Bucket findByName(TenantId tenantId, string name);
}

/// Objects: management plane (metadata, storage class, legal hold, copy) and
/// data plane (put / read content, listing).
interface IManageObjectsUseCase : IManageResource!(StorageObject, StorageObjectId, CreateObjectRequest, UpdateObjectRequest) {
  /// Write content (creates the object or a new version).
  UsecaseResult put(PutObjectRequest request);
  /// Content of the latest version, or of `versionNumber` (> 0).
  ObjectContent read(TenantId tenantId, BucketId bucketId, string key, int versionNumber = 0);
  /// Objects below `prefix`; with a delimiter, deeper keys are grouped into common prefixes.
  ObjectListing listing(TenantId tenantId, BucketId bucketId, string prefix, string delimiter);
  StorageObject findByKey(TenantId tenantId, BucketId bucketId, string key);

  /// Move to the archive storage class (content not readable until restored).
  UsecaseResult archive(TenantId tenantId, StorageObjectId id, UserId actor);
  /// Bring an archived object back to the bucket's default storage class.
  UsecaseResult restore(TenantId tenantId, StorageObjectId id, UserId actor);
  /// Set / clear the legal hold.
  UsecaseResult hold(TenantId tenantId, StorageObjectId id, bool enabled, UserId actor);
  /// Copy the latest version to another key / bucket (result id = the copy).
  UsecaseResult copy(TenantId tenantId, StorageObjectId id, BucketId targetBucket, string targetKey, UserId actor);
}

/// Versions: read, delete permanently, promote an old version to the latest.
interface IManageVersionsUseCase : IManageResource!(ObjectVersion, ObjectVersionId, CreateVersionRequest, UpdateVersionRequest) {
  ObjectVersion[] listByObject(TenantId tenantId, StorageObjectId objectId);
  /// Make this version the latest again (result id = the new latest version).
  UsecaseResult promote(TenantId tenantId, ObjectVersionId id, UserId actor);
}

interface IManageAccessPoliciesUseCase : IManageResource!(AccessPolicy, AccessPolicyId,
    CreateAccessPolicyRequest, UpdateAccessPolicyRequest) {
  AccessDecision evaluate(EvaluateAccessRequest request);
}

interface IManageLifecycleRulesUseCase : IManageResource!(LifecycleRule, LifecycleRuleId,
    CreateLifecycleRuleRequest, UpdateLifecycleRuleRequest) {
  /// Run the enabled rules of one bucket (or of all buckets for BucketId.init) at `now`.
  LifecycleRunReport run(TenantId tenantId, BucketId bucketId, long now, UserId actor);
  /// Run the rules of the bucket of this rule (result id = the rule).
  UsecaseResult apply(TenantId tenantId, LifecycleRuleId id, UserId actor);
}

interface IManageCorsRulesUseCase : IManageResource!(CorsRule, CorsRuleId, CreateCorsRuleRequest, UpdateCorsRuleRequest) {
  CorsDecision check(CheckCorsRequest request);
}

interface IManageServiceBindingsUseCase : IManageResource!(ServiceBinding, ServiceBindingId,
    CreateServiceBindingRequest, UpdateServiceBindingRequest) {
  /// active → revoked (final).
  UsecaseResult revoke(TenantId tenantId, ServiceBindingId id, UserId actor);
  /// New secret access key (the old one stops working immediately).
  UsecaseResult rotate(TenantId tenantId, ServiceBindingId id, UserId actor);
  /// Check an access key pair; records the last use of valid keys.
  CredentialCheck verify(TenantId tenantId, string accessKeyId, string secretAccessKey);
  /// The secret issued by the last create / rotate of this binding in this
  /// process — returned once, then forgotten ("" if none).
  string takeIssuedSecret(TenantId tenantId, ServiceBindingId id);
}
