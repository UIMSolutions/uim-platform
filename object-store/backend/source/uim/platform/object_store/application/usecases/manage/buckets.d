/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.object_store.application.usecases.manage.buckets;

import uim.platform.object_store;

mixin(ShowModule!());

@safe:

/// Interactor: buckets. Names follow the S3 rules and are unique per tenant;
/// name, provider and region are fixed; a bucket must be empty before it is
/// deleted, and deleting it deletes its policies, rules and bindings.
class ManageBucketsUseCase : ResourceUseCase!(Bucket, BucketId, CreateBucketRequest, UpdateBucketRequest),
  IManageBucketsUseCase {

  protected ObjectStorageService storage;
  protected IKeyManagementGateway kms;

  this(ObjectStoreRepositories repos, EventRecorder events, ObjectStorageService storage, IKeyManagementGateway kms) {
    super(repos, repos.buckets, events, "Bucket", "objectstore.bucket");
    this.storage = storage;
    this.kms = kms;
  }

  override protected Bucket build(CreateBucketRequest r) {
    auto limits = storage.storageLimits;
    auto b = Bucket(r.tenantId);
    assignMatching(b, r.spec);
    b.name = b.name.strip;
    validateBucketName(b.name);
    b.region = requireRegion(b.provider, b.region, limits.defaultRegion);
    check(b);
    ensureUnique(repos.buckets.findByName(r.tenantId, b.name), b, "this tenant");
    validate(repos.buckets.countByTenant(r.tenantId) < limits.maxBucketsPerTenant,
      "A tenant can have at most %d buckets".format(limits.maxBucketsPerTenant));
    b.status = BucketStatus.active;
    return b;
  }

  override protected void apply(ref Bucket b, BucketSpec spec) {
    ensureState(spec.provider == b.provider, "The provider of bucket '" ~ b.name ~ "' cannot change");
    ensureState(spec.region.strip.length == 0 || spec.region.strip.toLower == b.region,
      "The region of bucket '" ~ b.name ~ "' cannot change");
    assignMatching(b, spec, ["name", "provider", "region"]);
    check(b);
  }

  protected void check(ref Bucket b) {
    validateEncryption(b);
    if (b.encryptionType == EncryptionType.sseKms) {
      auto problem = kms.checkKey(b.tenantId, b.provider, b.encryptionKeyId);
      validate(problem.length == 0, problem);
    }
    validateQuota(b);
  }

  override protected void beforeRemove(Bucket b) {
    auto objects = repos.objects.findByBucket(b.tenantId, b.id);
    ensureState(objects.length == 0,
      "Bucket '%s' is not empty (%d object(s)) — empty it first".format(b.name, objects.length));
  }

  override protected void afterRemove(Bucket b, UserId actor) {
    foreach (p; repos.policies.findByBucket(b.tenantId, b.id))
      repos.policies.remove(p);
    foreach (r; repos.lifecycleRules.findByBucket(b.tenantId, b.id))
      repos.lifecycleRules.remove(r);
    foreach (c; repos.corsRules.findByBucket(b.tenantId, b.id))
      repos.corsRules.remove(c);
    foreach (s; repos.bindings.findByBucket(b.tenantId, b.id))
      repos.bindings.remove(s);
  }

  Bucket findByName(TenantId tenantId, string name) {
    return repos.buckets.findByName(tenantId, name);
  }

  UsecaseResult suspend(TenantId tenantId, BucketId id, UserId actor) {
    return transition(tenantId, id, actor, "suspended", (ref b) {
      ensureState(b.status == BucketStatus.active, "Bucket '" ~ b.name ~ "' is already suspended");
      b.status = BucketStatus.suspended;
    });
  }

  UsecaseResult resume(TenantId tenantId, BucketId id, UserId actor) {
    return transition(tenantId, id, actor, "resumed", (ref b) {
      ensureState(b.status == BucketStatus.suspended, "Bucket '" ~ b.name ~ "' is not suspended");
      b.status = BucketStatus.active;
    });
  }

  UsecaseResult empty(TenantId tenantId, BucketId id, UserId actor) {
    return guarded(() {
      auto b = require(tenantId, id);
      ensureWritable(b);
      auto objects = repos.objects.findByBucket(tenantId, id);
      auto held = objects.filter!(o => o.legalHold).array;
      ensureState(held.length == 0, "Bucket '%s' has %d object(s) under legal hold (e.g. '%s')".format(b.name,
        held.length, held.length ? held[0].name : ""));
      foreach (o; objects)
        storage.purgeObject(o);
      storage.recount(tenantId, id);
      publish(b, "emptied");
      return succeeded(b.id.value, "Bucket '%s' emptied: %d object(s) deleted".format(b.name, objects.length));
    });
  }
}
