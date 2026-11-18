/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// The resource catalogue of the object store: which kinds exist, how they
/// are named per protocol, their table columns and actions — plus the
/// operations that are not resources (content, listing, access evaluation,
/// CORS check, credential verification, lifecycle run).
module uim.platform.object_store.presentation.resources.registry;

import uim.platform.object_store;
import uim.platform.object_store.presentation.resources.adapter;

mixin(ShowModule!());

@safe:

/// Payload fields that reference a bucket (accept an id or a unique bucket name).
enum string[] bucketReferenceFields = ["bucketId", "targetBucketId"];

/// Run `action`; business exceptions become ResourceErrors with their status.
T translating(T)(scope T delegate() @safe action) {
  try
    return action();
  catch (ObjectStoreException e)
    throw new ResourceError(e.status, errorCodeOf(e.status), e.msg);
}

/// The caller of a data plane request: an identity, optionally authenticated
/// by service binding credentials.
struct DataPlaneCaller {
  RequestIdentity identity;
  string accessKeyId;
  string secretAccessKey;
}

class ResourceRegistry {
  protected IResourceAdapter[] _adapters;
  ObjectStorePorts ports;

  this(ObjectStorePorts ports) {
    this.ports = ports;
    auto p = ports;

    _adapters ~= new ResourceAdapter!(Bucket, BucketId, CreateBucketRequest, UpdateBucketRequest)(
      p.buckets, "buckets", "Buckets", "Bucket", "Buckets", "")
      .column("Name", "name").column("Provider", "provider").column("Region", "region")
      .column("Class", "storageClass").column("Versioning", "versioningEnabled").column("Encryption", "encryptionType")
      .column("Objects", "objectCount").column("Used Bytes", "usedBytes").column("Quota", "quotaBytes")
      .column("Status", "status").column("ID", "id")
      .action("suspend", "Suspend", (who, id, _) => p.buckets.suspend(who.tenantId, id, who.userId))
      .action("resume", "Resume", (who, id, _) => p.buckets.resume(who.tenantId, id, who.userId))
      .action("empty", "Empty", (who, id, _) => p.buckets.empty(who.tenantId, id, who.userId));

    _adapters ~= new ResourceAdapter!(StorageObject, StorageObjectId, CreateObjectRequest, UpdateObjectRequest)(
      p.objects, "objects", "StorageObjects", "StorageObject", "Objects", "bucketId")
      .column("Key", "name").column("Bucket", "bucketName").column("Type", "contentType").column("Size", "size")
      .column("Class", "storageClass").column("Version", "currentVersion").column("Hold", "legalHold")
      .column("Status", "status").column("Modified", "updatedAt").column("ID", "id")
      .action("archive", "Archive", (who, id, _) => p.objects.archive(who.tenantId, id, who.userId))
      .action("restore", "Restore", (who, id, _) => p.objects.restore(who.tenantId, id, who.userId))
      .action("hold", "Legal Hold", (who, id, _) => p.objects.hold(who.tenantId, id, true, who.userId))
      .action("release", "Release Hold", (who, id, _) => p.objects.hold(who.tenantId, id, false, who.userId))
      .action("copy", "Copy", (who, id, params) => p.objects.copy(who.tenantId, id,
          BucketId(bucketRef(who.tenantId, fieldString(params, "targetBucketId"))), fieldString(params, "targetKey"),
          who.userId), ["targetBucketId", "targetKey"]);

    _adapters ~= new ResourceAdapter!(ObjectVersion, ObjectVersionId, CreateVersionRequest, UpdateVersionRequest)(
      p.versions, "versions", "ObjectVersions", "ObjectVersion", "Versions", "objectId")
      .column("Key", "objectKey").column("Version", "name").column("Size", "size").column("ETag", "etag")
      .column("Latest", "isLatest").column("Marker", "isDeleteMarker").column("Created", "createdAt").column("ID", "id")
      .derived()
      .action("promote", "Make Latest", (who, id, _) => p.versions.promote(who.tenantId, id, who.userId));

    _adapters ~= new ResourceAdapter!(AccessPolicy, AccessPolicyId, CreateAccessPolicyRequest, UpdateAccessPolicyRequest)(
      p.policies, "policies", "AccessPolicies", "AccessPolicy", "Access Policies", "bucketId")
      .column("Name", "name").column("Bucket", "bucketName").column("Effect", "effect")
      .column("Principals", "principals").column("Actions", "actions").column("Resources", "resources")
      .column("Enabled", "enabled").column("ID", "id");

    _adapters ~= new ResourceAdapter!(LifecycleRule, LifecycleRuleId, CreateLifecycleRuleRequest, UpdateLifecycleRuleRequest)(
      p.lifecycleRules, "lifecycle-rules", "LifecycleRules", "LifecycleRule", "Lifecycle Rules", "bucketId")
      .column("Name", "name").column("Bucket", "bucketName").column("Prefix", "prefix").column("Status", "status")
      .column("Transition", "transitionDays").column("To", "transitionStorageClass")
      .column("Expiration", "expirationDays").column("Noncurrent", "noncurrentVersionExpirationDays")
      .column("Last Run", "lastAppliedAt").column("ID", "id")
      .action("apply", "Apply Now", (who, id, _) => p.lifecycleRules.apply(who.tenantId, id, who.userId));

    _adapters ~= new ResourceAdapter!(CorsRule, CorsRuleId, CreateCorsRuleRequest, UpdateCorsRuleRequest)(
      p.corsRules, "cors-rules", "CorsRules", "CorsRule", "CORS Rules", "bucketId")
      .column("Name", "name").column("Bucket", "bucketName").column("Origins", "allowedOrigins")
      .column("Methods", "allowedMethods").column("Headers", "allowedHeaders").column("Max Age", "maxAgeSeconds")
      .column("ID", "id");

    _adapters ~= new ResourceAdapter!(ServiceBinding, ServiceBindingId, CreateServiceBindingRequest, UpdateServiceBindingRequest)(
      p.bindings, "bindings", "ServiceBindings", "ServiceBinding", "Service Bindings", "bucketId")
      .column("Name", "name").column("Bucket", "bucketName").column("Permission", "permission")
      .column("Status", "status").column("Access Key", "accessKeyId").column("Expires", "expiresAt")
      .column("Last Used", "lastUsedAt").column("ID", "id")
      .secret("secretHash").secret("secretSalt").transient("secretAccessKey")
      .onWrite((who, row) {
        auto secret = p.bindings.takeIssuedSecret(who.tenantId, ServiceBindingId(fieldString(row, "id")));
        if (secret.length > 0)
          row["secretAccessKey"] = secret;
        return row;
      })
      .action("rotate", "Rotate Secret", (who, id, _) => p.bindings.rotate(who.tenantId, id, who.userId))
      .action("revoke", "Revoke", (who, id, _) => p.bindings.revoke(who.tenantId, id, who.userId));

    _adapters ~= new CatalogAdapter!Region(() => p.catalog.regions, "regions", "Regions", "Region", "Regions")
      .column("ID", "id").column("Name", "name").column("Provider", "provider").column("Location", "location");
    _adapters ~= new CatalogAdapter!StorageClassInfo(() => p.catalog.storageClasses, "storage-classes",
      "StorageClasses", "StorageClassInfo", "Storage Classes").column("ID", "id").column("Name", "name")
      .column("Min Days", "minStorageDays").column("Cost %", "relativeCost").column("Restore", "requiresRestore")
      .column("Description", "description");
  }

  IResourceAdapter[] adapters() {
    return _adapters;
  }

  /// Adapter by REST path / CLI command (null if unknown).
  IResourceAdapter byPath(string path) {
    foreach (a; _adapters)
      if (a.path == path)
        return a;
    return null;
  }

  /// Adapter by OData entity set (null if unknown).
  IResourceAdapter bySet(string setName) {
    foreach (a; _adapters)
      if (a.setName == setName)
        return a;
    return null;
  }

  /// Adapter owning an OData action name (null if unknown); `action` receives the action.
  IResourceAdapter byODataAction(string odataName, out ResourceAction action) {
    foreach (a; _adapters)
      foreach (act; a.actions)
        if (act.odataName == odataName) {
          action = act;
          return a;
        }
    return null;
  }

  /// An id, or the id of the unique resource of `adapter` with that name.
  string resolve(IResourceAdapter adapter, TenantId tenantId, string idOrName) {
    if (adapter.get(tenantId, idOrName).type != Json.Type.null_)
      return idOrName;
    auto matches = adapter.list(tenantId, ["name": idOrName]);
    if (matches.length == 1)
      return matches[0]["id"].get!string;
    if (matches.length > 1)
      throw new ResourceError(400, "Ambiguous", "'" ~ idOrName ~ "' matches " ~ matches.length.to!string
          ~ " " ~ adapter.path ~ " — use the id");
    throw new ResourceError(404, "NotFound", adapter.typeName ~ " '" ~ idOrName ~ "' not found");
  }

  /// A bucket id from an id or a bucket name ("" stays "").
  string bucketRef(TenantId tenantId, string idOrName) {
    return idOrName.length == 0 ? "" : resolve(byPath("buckets"), tenantId, idOrName);
  }

  /// A copy of `body` with every bucket reference given by name replaced by its id.
  Json withReferences(TenantId tenantId, Json body) {
    if (body.type != Json.Type.object)
      return body;
    auto result = Json.emptyObject;
    foreach (k, v; body.get!(Json[string]))
      result[k] = bucketReferenceFields.canFind(k) && jsonText(v).length > 0
        ? Json(bucketRef(tenantId, jsonText(v))) : v;
    return result;
  }

  // ── operations ──────────────────────────────────────────────────────────

  /// Statistics payload.
  Json statistics(TenantId tenantId) {
    return encode(ports.statistics.statistics(tenantId), true);
  }

  /// Evaluate access. Body: bucketId (id or name), principal, action, key.
  Json evaluateAccess(TenantId tenantId, Json body) {
    EvaluateAccessRequest r;
    r.tenantId = tenantId;
    r.bucketId = BucketId(requireBucketRef(tenantId, body));
    r.principal = fieldString(body, "principal");
    r.action = requireEnum!PolicyAction(fieldString(body, "action", "read"), "action");
    r.key = fieldString(body, "key");
    return translating(() => encode(ports.policies.evaluate(r), true));
  }

  /// CORS preflight check. Body: bucketId, origin, method, requestHeaders.
  Json checkCors(TenantId tenantId, Json body) {
    CheckCorsRequest r;
    r.tenantId = tenantId;
    r.bucketId = BucketId(requireBucketRef(tenantId, body));
    r.origin = fieldString(body, "origin");
    r.method = requireEnum!CorsMethod(fieldString(body, "method", "get"), "method");
    r.requestHeaders = fieldStrings(body, "requestHeaders");
    return translating(() => encode(ports.corsRules.check(r), true));
  }

  /// Verify binding credentials. Body: accessKeyId, secretAccessKey.
  Json verifyCredentials(TenantId tenantId, Json body) {
    return encode(ports.bindings.verify(tenantId, fieldString(body, "accessKeyId"),
        fieldString(body, "secretAccessKey")), true);
  }

  /// Run the lifecycle rules now. Body: bucketId ("" = all buckets).
  Json applyLifecycle(RequestIdentity who, Json body) {
    auto bucket = BucketId(bucketRef(who.tenantId, fieldString(body, "bucketId")));
    return translating(() => encode(ports.lifecycleRules.run(who.tenantId, bucket, nowStdTime(), who.userId), true));
  }

  /// S3 style listing of a bucket.
  Json listObjects(TenantId tenantId, string bucket, string prefix, string delimiter) {
    auto id = BucketId(bucketRef(tenantId, bucket));
    auto l = translating(() => ports.objects.listing(tenantId, id, prefix, delimiter));
    auto objects = Json.emptyArray;
    foreach (o; l.objects)
      objects ~= encode(o, true);
    auto folders = Json.emptyArray;
    foreach (f; l.commonPrefixes)
      folders ~= Json(f);
    return Json.emptyObject.set("bucketName", l.bucketName).set("prefix", prefix).set("delimiter", delimiter)
      .set("objects", objects).set("commonPrefixes", folders).set("count", l.objects.length);
  }

  // ── data plane (content) ────────────────────────────────────────────────

  /// Authorize a data plane call. With binding credentials the binding must be
  /// valid, belong to the bucket and permit the action; in every case the
  /// enabled access policies of the bucket (if any) must allow it.
  /// Returns the effective principal.
  string authorize(DataPlaneCaller caller, BucketId bucketId, PolicyAction action, string key) {
    auto tenantId = caller.identity.tenantId;
    string principal = caller.identity.userId.value.length > 0 ? caller.identity.userId.value : anonymousPrincipal;
    if (caller.accessKeyId.length > 0) {
      auto check = ports.bindings.verify(tenantId, caller.accessKeyId, caller.secretAccessKey);
      if (!check.valid)
        throw new ResourceError(403, "AccessDenied", check.reason);
      if (check.bucketId != bucketId.value)
        throw new ResourceError(403, "AccessDenied", "Service binding '" ~ check.bindingName
            ~ "' is not bound to this bucket");
      if (!permits(check.permission, action))
        throw new ResourceError(403, "AccessDenied", "Service binding '" ~ check.bindingName ~ "' is "
            ~ enumText(check.permission) ~ " — " ~ enumText(action) ~ " is not permitted");
      principal = bindingPrincipal(check.bindingName);
    }
    auto policies = ports.policies.list(tenantId).filter!(x => x.bucketId == bucketId && x.enabled).array;
    if (policies.length > 0) {
      EvaluateAccessRequest r;
      r.tenantId = tenantId;
      r.bucketId = bucketId;
      r.principal = principal;
      r.action = action;
      r.key = key;
      auto decision = translating(() => ports.policies.evaluate(r));
      if (!decision.allowed)
        throw new ResourceError(403, "AccessDenied", decision.reason);
    }
    return principal;
  }

  /// Write object content.
  Json putContent(DataPlaneCaller caller, string bucket, string key, const(ubyte)[] data, string contentType,
      MetadataEntry[] metadata) {
    auto who = caller.identity;
    auto id = BucketId(bucketRef(who.tenantId, bucket));
    auto principal = authorize(caller, id, PolicyAction.write, key);
    PutObjectRequest r;
    r.tenantId = who.tenantId;
    r.actor = UserId(principal);
    r.bucketId = id;
    r.key = key;
    r.data = data;
    r.contentType = contentType;
    r.metadata = metadata;
    r.replaceMetadata = metadata.length > 0;
    auto result = checked(ports.objects.put(r));
    return encode(ports.objects.get(who.tenantId, StorageObjectId(result.id)), true);
  }

  /// Write object content from a JSON body (OData action / Fiori upload).
  /// Body: bucketId (id or name), key, content, contentEncoding (text|base64), contentType, metadata.
  Json putContentJson(RequestIdentity who, Json body) {
    DataPlaneCaller caller;
    caller.identity = who;
    auto bucket = requireBucketRef(who.tenantId, body);
    auto key = fieldString(body, "key", fieldString(body, "name"));
    auto encoding = requireEnum!ContentEncoding(fieldString(body, "contentEncoding", "text"), "contentEncoding");
    auto data = translating(() => decodeContent(fieldString(body, "content"), encoding));
    MetadataEntry[] metadata;
    if (auto m = "metadata" in body)
      metadata = decodeKeyValues!MetadataEntry(*m);
    return putContent(caller, bucket, key, data, fieldString(body, "contentType"), metadata);
  }

  /// Read object content (latest or `versionNumber`).
  ObjectContent getContent(DataPlaneCaller caller, string bucket, string key, int versionNumber) {
    auto id = BucketId(bucketRef(caller.identity.tenantId, bucket));
    authorize(caller, id, PolicyAction.read, key);
    return translating(() => ports.objects.read(caller.identity.tenantId, id, key, versionNumber));
  }

  /// Delete an object by key.
  Json deleteContent(DataPlaneCaller caller, string bucket, string key) {
    auto tenantId = caller.identity.tenantId;
    auto id = BucketId(bucketRef(tenantId, bucket));
    auto principal = authorize(caller, id, PolicyAction.delete_, key);
    auto obj = ports.objects.findByKey(tenantId, id, key);
    if (obj.isNull)
      throw new ResourceError(404, "NotFound", "Object '" ~ key ~ "' not found");
    auto result = checked(ports.objects.remove(tenantId, obj.id, UserId(principal)));
    return Json.emptyObject.set("id", obj.id.value).set("message", result.message);
  }

  /// List a bucket through the data plane (needs "list").
  Json listContent(DataPlaneCaller caller, string bucket, string prefix, string delimiter) {
    auto id = BucketId(bucketRef(caller.identity.tenantId, bucket));
    authorize(caller, id, PolicyAction.list, prefix);
    return listObjects(caller.identity.tenantId, id.value, prefix, delimiter);
  }

  protected string requireBucketRef(TenantId tenantId, Json body) {
    auto ref_ = fieldString(body, "bucketId", fieldString(body, "bucket"));
    if (ref_.length == 0)
      throw new ResourceError(400, "MissingParameter", "bucketId is required");
    return bucketRef(tenantId, ref_);
  }

  protected static E requireEnum(E)(string value, string field) {
    if (!isEnumText!E(value))
      throw new ResourceError(400, "InvalidParameter", field ~ " must be one of " ~ enumTexts!E.join(", ")
          ~ " (got '" ~ value ~ "')");
    return parseEnum!E(value, E.init);
  }
}

///
unittest {
  mixin(ShowTest!("ResourceRegistry"));

  ObjectStoreConfig cfg;
  cfg.storage = "memory";
  auto registry = new ResourceRegistry(buildContainer(cfg).ports);
  RequestIdentity who;
  who.tenantId = TenantId("t1");
  who.userId = UserId("cli");

  auto buckets = registry.byPath("buckets");
  auto bucket = buckets.create(who, parseJsonString(
      `{"name": "media", "provider": "gcp", "versioningEnabled": "yes", "labels": "team=web,env=dev"}`));
  assert(bucket["region"].get!string == "europe-west3" && bucket["labels"].length == 2);
  assert(bucket["status"].get!string == "active" && bucket["usedBytes"].get!long == 0);

  // objects reference the bucket by name; JSON content
  auto objects = registry.byPath("objects");
  auto obj = objects.create(who, registry.withReferences(who.tenantId, parseJsonString(
      `{"bucketId": "media", "name": "docs/readme.md", "content": "# Hello", "contentType": "text/markdown"}`)));
  assert(obj["bucketId"].get!string == bucket["id"].get!string && obj["size"].get!long == 7);
  assert(obj["etag"].get!string == contentEtag(cast(const(ubyte)[]) "# Hello"));

  // PATCH with content → new version; PATCH without content keeps it
  auto patched = objects.update(who, obj["id"].get!string, parseJsonString(`{"content": "# Hello World"}`));
  assert(patched["currentVersion"].get!long == 2 && patched["contentType"].get!string == "text/markdown");
  patched = objects.update(who, obj["id"].get!string, parseJsonString(`{"metadata": {"owner": "jane"}}`));
  assert(patched["currentVersion"].get!long == 2 && patched["metadata"][0]["key"].get!string == "owner");

  // copy action answers with the copy; versions are derived
  auto copy = objects.invoke(who, obj["id"].get!string, "copy", parseJsonString(`{"targetKey": "docs/copy.md"}`));
  assert(copy["name"].get!string == "docs/copy.md" && copy["id"].get!string != obj["id"].get!string);
  auto versions = registry.byPath("versions");
  assert(versions.list(who.tenantId, ["objectId": obj["id"].get!string]).length == 2);
  int status;
  try versions.create(who, Json.emptyObject);
  catch (ResourceError e) status = e.status;
  assert(status == 405);
  auto v1 = versions.list(who.tenantId, ["objectId": obj["id"].get!string, "versionNumber": "1"])[0];
  auto promoted = versions.invoke(who, v1["id"].get!string, "promote", Json.emptyObject);
  assert(promoted["versionNumber"].get!long == 3 && promoted["isLatest"].get!bool);

  // listing with folders
  auto listing = registry.listObjects(who.tenantId, "media", "", "/");
  assert(listing["commonPrefixes"][0].get!string == "docs/" && listing["objects"].length == 0);

  // bindings return the secret once and mask the hash
  auto bindings = registry.byPath("bindings");
  auto binding = bindings.create(who, registry.withReferences(who.tenantId,
      parseJsonString(`{"bucketId": "media", "name": "uploader", "permission": "readWrite"}`)));
  auto secret = binding["secretAccessKey"].get!string;
  assert(secret.length == 40 && binding["secretHash"].get!string == secretMask);
  assert("secretAccessKey" !in bindings.get(who.tenantId, binding["id"].get!string));
  auto check = registry.verifyCredentials(who.tenantId, Json.emptyObject
      .set("accessKeyId", binding["accessKeyId"].get!string).set("secretAccessKey", secret));
  assert(check["valid"].get!bool && check["permission"].get!string == "readWrite");

  // data plane: binding credentials and policies
  DataPlaneCaller ci;
  ci.identity = who;
  ci.accessKeyId = binding["accessKeyId"].get!string;
  ci.secretAccessKey = secret;
  auto written = registry.putContent(ci, "media", "builds/app.zip", cast(const(ubyte)[]) "PK", "application/zip", null);
  assert(written["createdBy"].get!string == "binding:uploader");
  assert(bytesToText(registry.getContent(ci, "media", "builds/app.zip", 0).data) == "PK");
  ci.secretAccessKey = "nope";
  status = 0;
  try registry.getContent(ci, "media", "builds/app.zip", 0);
  catch (ResourceError e) status = e.status;
  assert(status == 403);

  registry.byPath("policies").create(who, registry.withReferences(who.tenantId, parseJsonString(
      `{"bucketId": "media", "name": "deny-builds", "effect": "deny", "principals": "*", "actions": "delete",
        "resources": "builds/*"}`)));
  registry.byPath("policies").create(who, registry.withReferences(who.tenantId, parseJsonString(
      `{"bucketId": "media", "name": "team", "principals": "cli,binding:*", "actions": "all"}`)));
  DataPlaneCaller user;
  user.identity = who;
  status = 0;
  try registry.deleteContent(user, "media", "builds/app.zip");
  catch (ResourceError e) status = e.status;
  assert(status == 403);
  assert(registry.deleteContent(user, "media", "docs/copy.md")["message"].get!string.canFind("delete marker"));
  auto decision = registry.evaluateAccess(who.tenantId, parseJsonString(
      `{"bucketId": "media", "principal": "eve", "action": "read", "key": "docs/readme.md"}`));
  assert(!decision["allowed"].get!bool);
  status = 0;
  try registry.evaluateAccess(who.tenantId, parseJsonString(`{"bucketId": "media", "action": "fly"}`));
  catch (ResourceError e) status = e.status;
  assert(status == 400);

  // JSON upload (Fiori): upsert with base64 content
  auto up = registry.putContentJson(who, parseJsonString(
      `{"bucketId": "media", "key": "img/dot.gif", "content": "R0lGODlh", "contentEncoding": "base64",
        "contentType": "image/gif", "metadata": {"alt": "dot"}}`));
  assert(up["size"].get!long == 6 && up["metadata"][0]["value"].get!string == "dot");
  up = registry.putContentJson(who, parseJsonString(`{"bucketId": "media", "key": "img/dot.gif", "content": "GIF"}`));
  assert(up["currentVersion"].get!long == 2 && up["metadata"].length == 1);

  // CORS, lifecycle, statistics, reference data
  registry.byPath("cors-rules").create(who, registry.withReferences(who.tenantId, parseJsonString(
      `{"bucketId": "media", "name": "web", "allowedOrigins": "https://*.example.com", "allowedMethods": "GET,PUT",
        "allowedHeaders": "*"}`)));
  auto cors = registry.checkCors(who.tenantId, parseJsonString(
      `{"bucketId": "media", "origin": "https://app.example.com", "method": "PUT", "requestHeaders": "content-type"}`));
  assert(cors["allowed"].get!bool && cors["allowMethods"][1].get!string == "PUT");
  auto rules = registry.byPath("lifecycle-rules");
  rules.create(who, registry.withReferences(who.tenantId, parseJsonString(
      `{"bucketId": "media", "name": "expire-builds", "prefix": "builds/", "expirationDays": "30"}`)));
  assert(registry.applyLifecycle(who, parseJsonString(`{"bucketId": "media"}`))["rulesEvaluated"].get!long == 1);
  auto stats = registry.statistics(who.tenantId);
  assert(stats["buckets"].get!long == 1 && stats["bindingsActive"].get!long == 1);
  assert(registry.byPath("regions").list(who.tenantId, ["provider": "azure"]).length == 5);
  assert(registry.bySet("StorageClasses").get(who.tenantId, "archive")["requiresRestore"].get!bool);

  ResourceAction action;
  assert(registry.byODataAction("CopyStorageObject", action) is objects && action.parameters.length == 2);
  assert(registry.byODataAction("RotateServiceBinding", action) is bindings);
  assert(registry.bySet("ServiceBindings").fields.any!(f => f.name == "secretAccessKey"));

  // business errors become ResourceErrors with HTTP status
  status = 0;
  try buckets.remove(who, bucket["id"].get!string);
  catch (ResourceError e) status = e.status;
  assert(status == 409);
  buckets.invoke(who, bucket["id"].get!string, "empty", Json.emptyObject);
  buckets.remove(who, bucket["id"].get!string);
  assert(buckets.list(who.tenantId).length == 0);
}
