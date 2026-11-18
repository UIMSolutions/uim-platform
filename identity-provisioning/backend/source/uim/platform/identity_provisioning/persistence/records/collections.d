/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity_provisioning.persistence.records.collections;

import uim.platform.identity_provisioning;

mixin(ShowModule!());

@safe:

/// Technical collection (table) names of the provisioning service.
enum ProvisioningCollections : string {
  sourceSystems = "ips_source_systems",
  targetSystems = "ips_target_systems",
  proxySystems = "ips_proxy_systems",
  transformations = "ips_transformations",
  jobs = "ips_jobs",
  logs = "ips_logs",
  entities = "ips_provisioned_entities",
}

/// Version of the snapshot record layout. Increment on breaking changes.
enum int provisioningRecordSchemaVersion = 1;

/// A snapshot file: { "schemaVersion": 1, "collection": "...", "records": [ ... ] }
struct SnapshotEnvelope {
  string collection;
  Json[] records;

  Json toJson() const {
    auto arr = Json.emptyArray;
    foreach (r; records)
      arr ~= r;
    return Json.emptyObject
      .set("schemaVersion", provisioningRecordSchemaVersion)
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
