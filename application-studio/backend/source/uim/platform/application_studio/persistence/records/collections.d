/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.application_studio.persistence.records.collections;

import uim.platform.application_studio;

mixin(ShowModule!());

@safe:

/// Technical collection (table) names of the Application Studio service.
enum StudioCollections : string {
  devSpaceTypes = "dev_space_types",
  extensions = "extensions",
  projectTemplates = "project_templates",
  devSpaces = "dev_spaces",
  projects = "projects",
  serviceBindings = "service_bindings",
  runConfigurations = "run_configurations",
  buildConfigurations = "build_configurations",
}

/// Version of the snapshot record layout. Increment on breaking changes.
enum int studioRecordSchemaVersion = 1;

/// A snapshot file: { "schemaVersion": 1, "collection": "...", "records": [ ... ] }
struct SnapshotEnvelope {
  string collection;
  Json[] records;

  Json toJson() const {
    auto arr = Json.emptyArray;
    foreach (r; records)
      arr ~= r;
    return Json.emptyObject
      .set("schemaVersion", studioRecordSchemaVersion)
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
