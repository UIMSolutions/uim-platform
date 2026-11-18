/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.object_store.infrastructure.container;

import std.path : buildPath;
import uim.platform.object_store;

mixin(ShowModule!());

@safe:

/// Dependency injection container — wires domain, application and persistence.
/// Presentation adapters (REST, content API, OData, CLI, GUI) are created by
/// the entry points (app.d, cli.d, gui.d) on top of this container and only see `ports`.
class Container {
  ObjectStoreConfig config;

  // ── Driven adapters ───────────────────────────────────────────────────
  ISnapshotStorage storage; // null in "memory" mode
  IBlobStorage blobs;
  ObjectStoreRepositories repositories;
  IObjectStoreEventPublisher publisher;
  IKeyManagementGateway kms;

  // ── Application services ──────────────────────────────────────────────
  EventRecorder events;
  ObjectStorageService objectStorage;

  // ── Driving ports ─────────────────────────────────────────────────────
  ObjectStorePorts ports;

  this(ObjectStoreConfig config) {
    this.config = config;
    wirePersistence();
    wireApplication();
  }

  protected void wirePersistence() {
    if (config.usesFileStorage) {
      storage = new JsonFileSnapshotStorage(config.dataDir);
      blobs = new FileBlobStorage(buildPath(config.dataDir, "blobs"));
    } else {
      blobs = new MemoryBlobStorage();
    }

    auto store(TEntity, TId)(string collection) {
      ITenantStore!(TEntity, TId) s = storage is null
        ? new TenantStore!(TEntity, TId)()
        : new SnapshotTenantStore!(TEntity, TId, RecordMapper!TEntity)(storage, collection);
      return s;
    }

    with (repositories) {
      buckets = new BucketRepository(store!(Bucket, BucketId)(ObjectStoreCollections.buckets));
      objects = new StorageObjectRepository(store!(StorageObject, StorageObjectId)(ObjectStoreCollections.objects));
      versions = new ObjectVersionRepository(store!(ObjectVersion, ObjectVersionId)(ObjectStoreCollections.versions));
      policies = new AccessPolicyRepository(store!(AccessPolicy, AccessPolicyId)(ObjectStoreCollections.policies));
      lifecycleRules = new LifecycleRuleRepository(
        store!(LifecycleRule, LifecycleRuleId)(ObjectStoreCollections.lifecycleRules));
      corsRules = new CorsRuleRepository(store!(CorsRule, CorsRuleId)(ObjectStoreCollections.corsRules));
      bindings = new ServiceBindingRepository(
        store!(ServiceBinding, ServiceBindingId)(ObjectStoreCollections.bindings));
    }
    publisher = new LogEventPublisher();
    kms = new SimulatedKeyManagementClient();
  }

  protected void wireApplication() {
    auto r = repositories;
    events = new EventRecorder(publisher);
    objectStorage = new ObjectStorageService(r, blobs, config.limits);

    ports.buckets = new ManageBucketsUseCase(r, events, objectStorage, kms);
    ports.objects = new ManageObjectsUseCase(r, events, objectStorage);
    ports.versions = new ManageVersionsUseCase(r, events, objectStorage);
    ports.policies = new ManageAccessPoliciesUseCase(r, events);
    ports.lifecycleRules = new ManageLifecycleRulesUseCase(r, events, objectStorage);
    ports.corsRules = new ManageCorsRulesUseCase(r, events);
    ports.bindings = new ManageServiceBindingsUseCase(r, events);
    ports.catalog = new ObjectStoreCatalogService(config.enabledProviders);
    ports.statistics = new ObjectStoreStatisticsService(r);
  }
}

/// Build the full dependency graph.
Container buildContainer(ObjectStoreConfig config) {
  return new Container(config);
}

///
unittest {
  mixin(ShowTest!("Container — end-to-end scenario"));

  ObjectStoreConfig cfg;
  cfg.storage = "memory";
  cfg.maxObjectSize = 1024;
  auto c = buildContainer(cfg);
  auto p = c.ports;
  auto t = TenantId("t1");
  auto who = UserId("jane");
  auto bytes(string s) {
    return cast(const(ubyte)[]) s;
  }

  // ── buckets ───────────────────────────────────────────────────────────
  CreateBucketRequest br;
  br.tenantId = t;
  br.actor = who;
  br.spec.name = "Photos";
  assert(p.buckets.create(br).code == 422); // uppercase
  br.spec.name = "photos";
  br.spec.region = "westeurope";
  assert(p.buckets.create(br).code == 422); // azure region on aws
  br.spec.region = "";
  br.spec.versioningEnabled = true;
  br.spec.quotaBytes = 40;
  br.spec.encryptionType = EncryptionType.sseKms;
  assert(p.buckets.create(br).code == 422); // key id missing
  br.spec.encryptionKeyId = "arn:aws:kms:eu-central-1:123456789012:key/abc";
  auto created = p.buckets.create(br);
  assert(created.isSuccess, created.message);
  auto photos = BucketId(created.id);
  assert(p.buckets.get(t, photos).region == "eu-central-1");
  assert(p.buckets.create(br).code == 409); // duplicate

  // ── objects and versions ─────────────────────────────────────────────
  PutObjectRequest put;
  put.tenantId = t;
  put.actor = who;
  put.bucketId = photos;
  put.key = "2026/cat.txt";
  put.data = bytes("meow");
  put.contentType = "text/plain";
  put.metadata = [MetadataEntry("camera", "x100")];
  auto w1 = p.objects.put(put);
  assert(w1.isSuccess, w1.message);
  auto catId = StorageObjectId(w1.id);
  auto cat = p.objects.get(t, catId);
  assert(cat.size == 4 && cat.etag == contentEtag(bytes("meow")) && cat.currentVersion == 1);
  assert(cat.metadata[0].value == "x100");

  put.data = bytes("meow meow");
  put.metadata = null;
  assert(p.objects.put(put).isSuccess);
  cat = p.objects.get(t, catId);
  assert(cat.currentVersion == 2 && cat.versionCount == 2 && cat.metadata.length == 1); // metadata kept
  assert(p.buckets.get(t, photos).usedBytes == 13 && p.buckets.get(t, photos).objectCount == 1);
  assert(bytesToText(p.objects.read(t, photos, "2026/cat.txt").data) == "meow meow");
  assert(bytesToText(p.objects.read(t, photos, "2026/cat.txt", 1).data) == "meow");

  put.data = bytes("123456789012345678901234567890"); // 13 + 30 > 40
  assert(p.objects.put(put).code == 422);

  CreateObjectRequest co;
  co.tenantId = t;
  co.actor = who;
  co.parentId = photos;
  co.spec.name = "2026/dog.bin";
  co.spec.content = "d29vZg=="; // "woof"
  co.spec.contentEncoding = ContentEncoding.base64;
  co.spec.contentType = "application/octet-stream";
  auto dog = p.objects.create(co);
  assert(dog.isSuccess, dog.message);
  assert(bytesToText(p.objects.read(t, photos, "2026/dog.bin").data) == "woof");
  assert(p.objects.create(co).code == 409);

  auto listing = p.objects.listing(t, photos, "", "/");
  assert(listing.commonPrefixes == ["2026/"] && listing.objects.length == 0);
  assert(p.objects.listing(t, photos, "2026/", "/").objects.length == 2);

  // versions: promote v1, delete marker, restore by deleting the marker
  auto versions = p.versions.listByObject(t, catId);
  assert(versions.length == 2 && versions[0].isLatest && versions[0].versionNumber == 2);
  auto promoted = p.versions.promote(t, versions[1].id, who);
  assert(promoted.isSuccess, promoted.message);
  assert(bytesToText(p.objects.read(t, photos, "2026/cat.txt").data) == "meow");
  assert(p.objects.get(t, catId).currentVersion == 3);
  assert(c.blobs.exists(t, contentAddress(bytes("meow")))); // promoted version shares the blob

  assert(p.objects.remove(t, catId, who).isSuccess); // delete marker
  assert(p.objects.get(t, catId).status == ObjectStatus.deleted);
  bool missing;
  try p.objects.read(t, photos, "2026/cat.txt");
  catch (ObjectStoreNotFoundException) missing = true;
  assert(missing);
  auto marker = p.versions.listByObject(t, catId)[0];
  assert(marker.isDeleteMarker);
  assert(p.versions.remove(t, marker.id, who).isSuccess);
  assert(p.objects.get(t, catId).status == ObjectStatus.active);

  CreateVersionRequest cv;
  cv.tenantId = t;
  assert(p.versions.create(cv).code == 405);

  // copy, legal hold, archive / restore
  auto copied = p.objects.copy(t, StorageObjectId(dog.id), BucketId.init, "2026/dog-copy.bin", who);
  assert(copied.isSuccess, copied.message);
  assert(p.objects.get(t, StorageObjectId(copied.id)).etag == p.objects.get(t, StorageObjectId(dog.id)).etag);
  assert(p.objects.hold(t, catId, true, who).isSuccess);
  assert(p.objects.remove(t, catId, who).code == 409);
  put.data = bytes("x");
  assert(p.objects.put(put).code == 409);
  assert(p.objects.hold(t, catId, false, who).isSuccess);
  assert(p.objects.archive(t, catId, who).isSuccess);
  bool archived;
  try p.objects.read(t, photos, "2026/cat.txt");
  catch (ObjectStoreConflictException) archived = true;
  assert(archived);
  assert(p.objects.restore(t, catId, who).isSuccess);
  assert(p.objects.get(t, catId).storageClass == StorageClass.standard);

  // ── access policies ──────────────────────────────────────────────────
  CreateAccessPolicyRequest pr;
  pr.tenantId = t;
  pr.actor = who;
  pr.parentId = photos;
  pr.spec.name = "readers";
  pr.spec.principals = ["*"];
  pr.spec.actions = [PolicyAction.read, PolicyAction.list];
  assert(p.policies.create(pr).isSuccess);
  pr.spec.name = "no-raw";
  pr.spec.effect = PolicyEffect.deny;
  pr.spec.resources = ["raw/*"];
  assert(p.policies.create(pr).isSuccess);
  EvaluateAccessRequest ev;
  ev.tenantId = t;
  ev.bucketId = photos;
  ev.principal = "bob";
  ev.action = PolicyAction.read;
  ev.key = "2026/cat.txt";
  assert(p.policies.evaluate(ev).allowed);
  ev.key = "raw/a.cr2";
  assert(p.policies.evaluate(ev).matchedPolicy == "no-raw");
  ev.principal = "";
  ev.key = "2026/cat.txt";
  assert(!p.policies.evaluate(ev).allowed); // anonymous + public access blocked

  // ── CORS ─────────────────────────────────────────────────────────────
  CreateCorsRuleRequest cr;
  cr.tenantId = t;
  cr.actor = who;
  cr.parentId = photos;
  cr.spec.name = "web";
  cr.spec.allowedOrigins = ["https://*.example.com"];
  cr.spec.allowedMethods = [CorsMethod.get];
  assert(p.corsRules.create(cr).isSuccess);
  CheckCorsRequest cc;
  cc.tenantId = t;
  cc.bucketId = photos;
  cc.origin = "https://shop.example.com";
  cc.method = CorsMethod.get;
  assert(p.corsRules.check(cc).allowed);

  // ── service bindings ─────────────────────────────────────────────────
  CreateServiceBindingRequest sb;
  sb.tenantId = t;
  sb.actor = who;
  sb.parentId = photos;
  sb.spec.name = "ci";
  sb.spec.permission = BindingPermission.readWrite;
  auto binding = p.bindings.create(sb);
  assert(binding.isSuccess, binding.message);
  auto bid = ServiceBindingId(binding.id);
  auto secret = p.bindings.takeIssuedSecret(t, bid);
  assert(secret.length == 40 && p.bindings.takeIssuedSecret(t, bid) == "");
  auto accessKey = p.bindings.get(t, bid).accessKeyId;
  assert(p.bindings.get(t, bid).secretHash != secret);
  assert(p.bindings.verify(t, accessKey, secret).valid);
  assert(!p.bindings.verify(t, accessKey, "wrong").valid);
  assert(p.bindings.rotate(t, bid, who).isSuccess);
  auto rotated = p.bindings.takeIssuedSecret(t, bid);
  assert(!p.bindings.verify(t, accessKey, secret).valid && p.bindings.verify(t, accessKey, rotated).valid);
  assert(p.bindings.revoke(t, bid, who).isSuccess);
  assert(p.bindings.verify(t, accessKey, rotated).reason.canFind("revoked"));
  assert(p.bindings.rotate(t, bid, who).code == 409);

  // ── lifecycle ────────────────────────────────────────────────────────
  CreateLifecycleRuleRequest lr;
  lr.tenantId = t;
  lr.actor = who;
  lr.parentId = photos;
  lr.spec.name = "cold-2026";
  lr.spec.prefix = "2026/";
  assert(p.lifecycleRules.create(lr).code == 422); // no action
  lr.spec.transitionDays = 30;
  lr.spec.transitionStorageClass = StorageClass.coldline;
  lr.spec.noncurrentVersionExpirationDays = 7;
  assert(p.lifecycleRules.create(lr).isSuccess);
  auto later = nowStdTime() + 31 * stdTimeDay;
  auto report = p.lifecycleRules.run(t, BucketId.init, later, UserId("lifecycle"));
  assert(report.bucketsEvaluated == 1 && report.transitioned == 3, report.messages.join("; "));
  assert(report.versionsPurged == 2, report.messages.join("; ")); // cat v1 and v2 (v3 is latest)
  assert(p.objects.get(t, catId).storageClass == StorageClass.coldline);
  assert(!c.blobs.exists(t, contentAddress(bytes("meow meow"))) && c.blobs.exists(t, contentAddress(bytes("meow"))));

  // ── statistics, suspend, empty, delete ───────────────────────────────
  auto stats = p.statistics.statistics(t);
  assert(stats.buckets == 1 && stats.objects == 3 && stats.bucketsEncrypted == 1 && stats.bindingsRevoked == 1);
  assert(stats.accessPolicies == 2 && stats.corsRules == 1 && stats.lifecycleRules == 1);
  assert(stats.usage[StorageClass.coldline].objects == 3);

  assert(p.buckets.suspend(t, photos, who).isSuccess);
  put.key = "new.txt";
  assert(p.objects.put(put).code == 409);
  assert(p.buckets.resume(t, photos, who).isSuccess);
  assert(p.buckets.remove(t, photos, who).code == 409); // not empty
  assert(p.buckets.empty(t, photos, who).isSuccess);
  assert(p.buckets.get(t, photos).usedBytes == 0);
  assert((cast(MemoryBlobStorage) c.blobs).count(t) == 0);
  assert(p.buckets.remove(t, photos, who).isSuccess);
  assert(p.policies.list(t).length == 0 && p.bindings.list(t).length == 0);

  // unversioned buckets overwrite in place
  br.spec.name = "logs";
  br.spec.versioningEnabled = false;
  br.spec.quotaBytes = 0;
  br.spec.encryptionType = EncryptionType.sseS3;
  auto logs = BucketId(p.buckets.create(br).id);
  put.bucketId = logs;
  put.key = "app.log";
  put.data = bytes("a");
  p.objects.put(put);
  put.data = bytes("bb");
  auto again = p.objects.put(put);
  assert(p.versions.listByObject(t, StorageObjectId(again.id)).length == 1);
  assert(p.buckets.get(t, logs).usedBytes == 2);
  put.data = new ubyte[2000];
  assert(p.objects.put(put).code == 413);
  assert(p.objects.remove(t, StorageObjectId(again.id), who).isSuccess);
  assert(p.objects.list(t).length == 0);
}
