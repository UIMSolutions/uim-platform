/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.abap_environment.persistence.records.collections;

import uim.platform.abap_environment;

mixin(ShowModule!());

@safe:

/// Technical collection (table) names of the ABAP environment service.
enum AbapCollections : string {
  systems = "systems",
  softwareComponents = "software_components",
  communicationArrangements = "communication_arrangements",
  serviceBindings = "service_bindings",
  businessUsers = "business_users",
  businessRoles = "business_roles",
  transportRequests = "transport_requests",
  applicationJobs = "application_jobs",
}

/// Version of the snapshot record layout. Increment on breaking changes.
enum int abapRecordSchemaVersion = 1;

/// A snapshot file: { "schemaVersion": 1, "collection": "...", "records": [ ... ] }
struct SnapshotEnvelope {
  string collection;
  Json[] records;

  Json toJson() const {
    auto arr = Json.emptyArray;
    foreach (r; records)
      arr ~= r;
    return Json.emptyObject
      .set("schemaVersion", abapRecordSchemaVersion)
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
