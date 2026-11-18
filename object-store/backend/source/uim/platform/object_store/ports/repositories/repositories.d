/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Driven ports for business data access.
module uim.platform.object_store.ports.repositories.repositories;

import uim.platform.object_store;

mixin(ShowModule!());

@safe:

interface IBucketRepository : ITenantRepository!(Bucket, BucketId) {
  Bucket findByName(TenantId tenantId, string name);
}

/// Children of a bucket.
interface IBucketChildRepository(TEntity, TId) : ITenantRepository!(TEntity, TId) {
  TEntity[] findByBucket(TenantId tenantId, BucketId bucketId);
  /// The child with this name in a bucket (TEntity.init if unknown).
  TEntity findByName(TenantId tenantId, BucketId bucketId, string name);
}

interface IStorageObjectRepository : IBucketChildRepository!(StorageObject, StorageObjectId) {
  /// Objects of a bucket whose key starts with `prefix`, sorted by key.
  StorageObject[] findByPrefix(TenantId tenantId, BucketId bucketId, string prefix);
}

interface IObjectVersionRepository : ITenantRepository!(ObjectVersion, ObjectVersionId) {
  /// Versions of an object, newest first.
  ObjectVersion[] findByObject(TenantId tenantId, StorageObjectId objectId);
  ObjectVersion[] findByBucket(TenantId tenantId, BucketId bucketId);
  /// Number of versions referencing a blob (for garbage collection).
  size_t countByBlob(TenantId tenantId, string blobId);
}

interface IAccessPolicyRepository : IBucketChildRepository!(AccessPolicy, AccessPolicyId) {
}

interface ILifecycleRuleRepository : IBucketChildRepository!(LifecycleRule, LifecycleRuleId) {
}

interface ICorsRuleRepository : IBucketChildRepository!(CorsRule, CorsRuleId) {
}

interface IServiceBindingRepository : IBucketChildRepository!(ServiceBinding, ServiceBindingId) {
  ServiceBinding findByAccessKey(TenantId tenantId, string accessKeyId);
}

/// All driven persistence ports, handed to the interactors by the container.
struct ObjectStoreRepositories {
  IBucketRepository buckets;
  IStorageObjectRepository objects;
  IObjectVersionRepository versions;
  IAccessPolicyRepository policies;
  ILifecycleRuleRepository lifecycleRules;
  ICorsRuleRepository corsRules;
  IServiceBindingRepository bindings;
}
