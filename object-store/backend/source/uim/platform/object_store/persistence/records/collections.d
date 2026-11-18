/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.object_store.persistence.records.collections;

import uim.platform.object_store;

mixin(ShowModule!());

@safe:

/// Technical collection (table) names of the object store service.
enum ObjectStoreCollections : string {
  buckets = "object_store_buckets",
  objects = "object_store_objects",
  versions = "object_store_versions",
  policies = "object_store_access_policies",
  lifecycleRules = "object_store_lifecycle_rules",
  corsRules = "object_store_cors_rules",
  bindings = "object_store_service_bindings",
}

/// Version of the snapshot record layout. Increment on breaking changes.
enum int objectStoreRecordSchemaVersion = 1;

/// A snapshot file: { "schemaVersion": 1, "collection": "...", "records": [ ... ] }
struct SnapshotEnvelope {
  string collection;
  Json[] records;

  Json toJson() const {
    auto arr = Json.emptyArray;
    foreach (r; records)
      arr ~= r;
    return Json.emptyObject
      .set("schemaVersion", objectStoreRecordSchemaVersion)
      .set("collection", collection)
      .set("records", arr);
  }

  static SnapshotEnvelope fromJson(string collection, Json json) {
    SnapshotEnvelope env;
    env.collection = collection;
    if (json.type == Json.Type.object && "records" in json && json["records"].type == Json.Type.array)
      foreach (r; json["records"].get!(Json[]))
        env.records ~= r;
    return env;
  }
}
