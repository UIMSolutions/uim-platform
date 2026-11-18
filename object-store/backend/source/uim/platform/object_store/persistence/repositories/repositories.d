/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.object_store.persistence.repositories.repositories;

import uim.platform.object_store;

mixin(ShowModule!());

@safe:

class BucketRepository : ObjectStoreRepository!(Bucket, BucketId), IBucketRepository {
  this() {
    super();
  }

  this(ITenantStore!(Bucket, BucketId) store) {
    super(store);
  }

  Bucket findByName(TenantId tenantId, string name) {
    return first(tenantId, (e) => e.name == name);
  }
}

/// Repository of a bucket child (policies, rules, bindings, objects).
class BucketChildRepository(TEntity, TId) : ObjectStoreRepository!(TEntity, TId), IBucketChildRepository!(TEntity, TId) {
  this() {
    super();
  }

  this(ITenantStore!(TEntity, TId) store) {
    super(store);
  }

  TEntity[] findByBucket(TenantId tenantId, BucketId bucketId) {
    auto result = where(tenantId, (e) => e.bucketId == bucketId);
    result.sort!((a, b) => a.name < b.name);
    return result;
  }

  TEntity findByName(TenantId tenantId, BucketId bucketId, string name) {
    return first(tenantId, (e) => e.bucketId == bucketId && e.name == name);
  }
}

class StorageObjectRepository : BucketChildRepository!(StorageObject, StorageObjectId), IStorageObjectRepository {
  this() {
    super();
  }

  this(ITenantStore!(StorageObject, StorageObjectId) store) {
    super(store);
  }

  StorageObject[] findByPrefix(TenantId tenantId, BucketId bucketId, string prefix) {
    auto result = where(tenantId, (e) => e.bucketId == bucketId && e.name.startsWith(prefix));
    result.sort!((a, b) => a.name < b.name);
    return result;
  }
}

class ObjectVersionRepository : ObjectStoreRepository!(ObjectVersion, ObjectVersionId), IObjectVersionRepository {
  this() {
    super();
  }

  this(ITenantStore!(ObjectVersion, ObjectVersionId) store) {
    super(store);
  }

  ObjectVersion[] findByObject(TenantId tenantId, StorageObjectId objectId) {
    auto result = where(tenantId, (e) => e.objectId == objectId);
    result.sort!((a, b) => a.versionNumber > b.versionNumber);
    return result;
  }

  ObjectVersion[] findByBucket(TenantId tenantId, BucketId bucketId) {
    return where(tenantId, (e) => e.bucketId == bucketId);
  }

  size_t countByBlob(TenantId tenantId, string blobId) {
    return where(tenantId, (e) => e.blobId == blobId).length;
  }
}

alias AccessPolicyBase = BucketChildRepository!(AccessPolicy, AccessPolicyId);
alias LifecycleRuleBase = BucketChildRepository!(LifecycleRule, LifecycleRuleId);
alias CorsRuleBase = BucketChildRepository!(CorsRule, CorsRuleId);

class AccessPolicyRepository : AccessPolicyBase, IAccessPolicyRepository {
  this() {
    super();
  }

  this(ITenantStore!(AccessPolicy, AccessPolicyId) store) {
    super(store);
  }
}

class LifecycleRuleRepository : LifecycleRuleBase, ILifecycleRuleRepository {
  this() {
    super();
  }

  this(ITenantStore!(LifecycleRule, LifecycleRuleId) store) {
    super(store);
  }
}

class CorsRuleRepository : CorsRuleBase, ICorsRuleRepository {
  this() {
    super();
  }

  this(ITenantStore!(CorsRule, CorsRuleId) store) {
    super(store);
  }
}

class ServiceBindingRepository : BucketChildRepository!(ServiceBinding, ServiceBindingId), IServiceBindingRepository {
  this() {
    super();
  }

  this(ITenantStore!(ServiceBinding, ServiceBindingId) store) {
    super(store);
  }

  ServiceBinding findByAccessKey(TenantId tenantId, string accessKeyId) {
    return first(tenantId, (e) => e.accessKeyId == accessKeyId);
  }
}

///
unittest {
  mixin(ShowTest!("Repositories"));

  assert(tenantRepositoryTest(new BucketRepository()));
  assert(tenantRepositoryTest(new StorageObjectRepository()));
  assert(tenantRepositoryTest(new ObjectVersionRepository()));
  assert(tenantRepositoryTest(new AccessPolicyRepository()));
  assert(tenantRepositoryTest(new LifecycleRuleRepository()));
  assert(tenantRepositoryTest(new CorsRuleRepository()));
  assert(tenantRepositoryTest(new ServiceBindingRepository()));

  auto t = TenantId("t1");
  auto bucket = BucketId("b1");
  auto objects = new StorageObjectRepository();
  foreach (key; ["logs/b.log", "img/a.png", "logs/a.log"]) {
    auto o = StorageObject(t);
    o.bucketId = bucket;
    o.name = key;
    objects.save(o);
  }
  assert(objects.findByPrefix(t, bucket, "logs/").map!(o => o.name).array == ["logs/a.log", "logs/b.log"]);
  assert(objects.findByBucket(t, bucket)[0].name == "img/a.png");
  assert(!objects.findByName(t, bucket, "img/a.png").isNull);
  assert(objects.findByName(t, BucketId("b2"), "img/a.png").isNull);

  auto versions = new ObjectVersionRepository();
  foreach (n; [1, 3, 2]) {
    auto v = ObjectVersion(t);
    v.objectId = StorageObjectId("o1");
    v.versionNumber = n;
    v.blobId = n == 2 ? "x" : "y";
    versions.save(v);
  }
  assert(versions.findByObject(t, StorageObjectId("o1")).map!(v => v.versionNumber).array == [3, 2, 1]);
  assert(versions.countByBlob(t, "y") == 2);
}
