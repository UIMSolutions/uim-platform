/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.connectivity.persistence.records.collections;

import uim.platform.connectivity;

mixin(ShowModule!());

@safe:

/// Technical collection (table) names of the connectivity service.
enum ConnectivityCollections : string {
  destinations = "destinations",
  connectors = "cloud_connectors",
  channels = "service_channels",
  accessRules = "access_rules",
  certificates = "certificates",
  logs = "connectivity_logs",
}

/// Version of the snapshot record layout. Increment on breaking changes.
enum int connectivityRecordSchemaVersion = 1;

/// A snapshot file: { "schemaVersion": 1, "collection": "...", "records": [ ... ] }
struct SnapshotEnvelope {
  string collection;
  Json[] records;

  Json toJson() const {
    auto arr = Json.emptyArray;
    foreach (r; records)
      arr ~= r;
    return Json.emptyObject
      .set("schemaVersion", connectivityRecordSchemaVersion)
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
