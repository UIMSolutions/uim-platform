/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.workzone.persistence.records.collections;

import uim.platform.workzone;

mixin(ShowModule!());

@safe:

/// Technical collection (table) names of the Work Zone service.
enum WorkzoneCollections : string {
  workspaces = "workspaces",
  workpages = "workpages",
  widgets = "widgets",
  channels = "channels",
  content = "content_items",
  feedEntries = "feed_entries",
  events = "events",
  surveys = "surveys",
  forumTopics = "forum_topics",
  knowledgeBase = "kb_articles",
  tasks = "tasks",
  notifications = "notifications",
  cards = "cards",
  apps = "apps",
  contentProviders = "content_providers",
  shellPlugins = "shell_plugins",
  sites = "sites",
  navigationItems = "navigation_items",
  themes = "themes",
  pageTemplates = "page_templates",
  roles = "roles",
  groups = "groups",
  tags = "tags",
  userProfiles = "user_profiles",
}

/// Version of the snapshot record layout. Increment on breaking changes.
enum int workzoneRecordSchemaVersion = 1;

/// A snapshot file: { "schemaVersion": 1, "collection": "...", "records": [ ... ] }
struct SnapshotEnvelope {
  string collection;
  Json[] records;

  Json toJson() const {
    auto arr = Json.emptyArray;
    foreach (r; records)
      arr ~= r;
    return Json.emptyObject
      .set("schemaVersion", workzoneRecordSchemaVersion)
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
