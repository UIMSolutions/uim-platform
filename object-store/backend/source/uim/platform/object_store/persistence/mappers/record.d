/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.object_store.persistence.mappers.record;

import uim.platform.object_store;

mixin(ShowModule!());

@safe:

/// Generic mapper between entities and database records, driven by
/// compile-time reflection (see helpers.codec). Records keep timestamps as raw
/// std-time numbers and enums by name; unknown or missing fields fall back to
/// the entity defaults, so older snapshots stay readable.
struct RecordMapper(TEntity) {
  static Json toRecord(const TEntity entity) {
    return encode(entity, false);
  }

  static TEntity fromRecord(Json record) {
    return decode!TEntity(record);
  }
}

alias BucketMapper = RecordMapper!Bucket;
alias StorageObjectMapper = RecordMapper!StorageObject;
alias ObjectVersionMapper = RecordMapper!ObjectVersion;
alias AccessPolicyMapper = RecordMapper!AccessPolicy;
alias LifecycleRuleMapper = RecordMapper!LifecycleRule;
alias CorsRuleMapper = RecordMapper!CorsRule;
alias ServiceBindingMapper = RecordMapper!ServiceBinding;

///
unittest {
  mixin(ShowTest!("RecordMapper"));

  auto b = Bucket(TenantId("t1"));
  b.name = "photos";
  b.provider = IaasProvider.azure;
  b.encryptionType = EncryptionType.sseKms;
  b.quotaBytes = 5L * 1024 * 1024 * 1024;
  b.labels = [MetadataEntry("team", "web")];
  auto record = BucketMapper.toRecord(b);
  assert(record["provider"].get!string == "azure");
  assert(record["encryptionType"].get!string == "sseKms");
  assert(record["quotaBytes"].get!long == 5L * 1024 * 1024 * 1024);
  assert(record["createdAt"].type == Json.Type.int_);
  assert(BucketMapper.fromRecord(record) == b);

  auto p = AccessPolicy(TenantId("t1"));
  p.actions = [PolicyAction.read, PolicyAction.delete_];
  auto back = AccessPolicyMapper.fromRecord(AccessPolicyMapper.toRecord(p));
  assert(back == p && AccessPolicyMapper.toRecord(p)["actions"][1].get!string == "delete");

  // older snapshots (e.g. of the previous object-store release) stay readable
  auto o = StorageObjectMapper.fromRecord(parseJsonString(`{"id": "o1", "tenantId": "t1", "name": "a.txt",
    "storageClass": "coldline", "status": "archived"}`));
  assert(o.storageClass == StorageClass.coldline && o.status == ObjectStatus.archived);
  assert(o.contentType == "application/octet-stream");
}
