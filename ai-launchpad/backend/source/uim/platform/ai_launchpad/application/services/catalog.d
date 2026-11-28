/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// The default tile catalog of the launchpad (created on the first start of
/// a tenant, restorable by an administrator).
module uim.platform.ai_launchpad.application.services.catalog;

import uim.platform.ai_launchpad;

mixin(ShowModule!());

@safe:

struct DefaultTile {
  string id;
  TileInput input;
}

private DefaultTile tile(string id, string group, int order, string title, string subtitle, string icon, string target,
  string kpi = "", string kpiUnit = "", string scope_ = readScope, string info = "") {
  TileInput i;
  i.title = title;
  i.subtitle = subtitle;
  i.icon = icon;
  i.groupName = group;
  i.sortOrder = order;
  i.target = target;
  i.kpi = kpi;
  i.kpiUnit = kpiUnit;
  i.requiredScope = scope_;
  i.info = info;
  return DefaultTile(id, i);
}

enum string groupRuntimes = "AI Runtimes";
enum string groupLifecycle = "ML Operations";
enum string groupRegistry = "ML Registry";
enum string groupGenAi = "Generative AI Hub";
enum string groupAdmin = "Administration";
enum string groupHelp = "Help";

DefaultTile[] defaultTiles() {
  auto docs = tile("documentation", groupHelp, 900, "Documentation", "SAP AI Launchpad", "sap-icon://sys-help",
    "https://help.sap.com/docs/ai-launchpad", "", "", "", "help.sap.com");
  docs.input.targetType = "url";
  return [
    tile("workspaces", groupRuntimes, 10, "Workspaces", "Teams and their runtimes", "sap-icon://group-2",
      "runtimes/workspaces", "workspaces"),
    tile("connections", groupRuntimes, 20, "AI Runtimes", "Connections to SAP AI Core", "sap-icon://connected",
      "runtimes/connections", "activeConnections", "active"),
    tile("resource-groups", groupRuntimes, 30, "Resource Groups", "Isolated runtime capacity", "sap-icon://folder-full",
      "runtimes/resource-groups", "resourceGroups"),
    tile("scenarios", groupLifecycle, 100, "Scenarios", "AI use cases", "sap-icon://puzzle", "lifecycle/scenarios",
      "scenarios"),
    tile("configurations", groupLifecycle, 110, "Configurations", "Parameters and input artifacts", "sap-icon://action-settings",
      "lifecycle/configurations", "configurations"),
    tile("executions", groupLifecycle, 120, "Executions", "Training runs", "sap-icon://process", "lifecycle/executions",
      "runningExecutions", "active"),
    tile("deployments", groupLifecycle, 130, "Deployments", "Inference endpoints", "sap-icon://cloud",
      "lifecycle/deployments", "runningDeployments", "running"),
    tile("models", groupRegistry, 200, "Models", "Trained models and versions", "sap-icon://machine", "lifecycle/models",
      "models"),
    tile("datasets", groupRegistry, 210, "Datasets", "Training and evaluation data", "sap-icon://database",
      "lifecycle/datasets", "datasets"),
    tile("prompts", groupGenAi, 300, "Prompt Management", "Templates and versions", "sap-icon://discussion-2",
      "genai/prompts", "prompts"),
    tile("prompt-collections", groupGenAi, 310, "Prompt Collections", "Prompts by topic", "sap-icon://course-book",
      "genai/collections", "promptCollections"),
    tile("playground", groupGenAi, 320, "Playground", "Try prompts with inputs", "sap-icon://lab", "genai/playground",
      "promptRuns", "runs", operateScope),
    tile("users", groupAdmin, 800, "Users", "Accounts of the built-in login", "sap-icon://employee", "admin/users", "users",
      "", adminScope),
    tile("roles", groupAdmin, 810, "Roles", "Scopes granted to users", "sap-icon://key-user-settings", "admin/roles",
      "roles", "", adminScope),
    tile("audit-log", groupAdmin, 820, "Audit Log", "Security and change log", "sap-icon://log", "admin/logs",
      "warningsLast24h", "warnings 24 h", adminScope),
    tile("tiles", groupAdmin, 830, "Launchpad Tiles", "Tile catalog", "sap-icon://grid", "admin/tiles", "tiles", "",
      adminScope),
    docs
  ];
}

///
unittest {
  auto tiles = defaultTiles();
  assert(tiles.length == 17 && tiles[$ - 1].input.targetType == "url");
  foreach (d; tiles) {
    Tile t;
    t.id = TileId(d.id);
    t.title = d.input.title;
    t.subtitle = d.input.subtitle;
    t.info = d.input.info;
    t.icon = d.input.icon;
    t.groupName = d.input.groupName;
    t.sortOrder = d.input.sortOrder;
    t.targetType = parseDomainEnum!TileTargetType(d.input.targetType);
    t.target = d.input.target;
    t.kpi = d.input.kpi;
    t.kpiUnit = d.input.kpiUnit;
    t.requiredScope = d.input.requiredScope;
    t.validate(statisticNames);
  }
}
