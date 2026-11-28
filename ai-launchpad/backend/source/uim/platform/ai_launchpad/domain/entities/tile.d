/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// A tile of the launchpad: title, subtitle, icon and footer, the group
/// (section) it belongs to, its target (an app route of the launchpad or an
/// external URL), an optional KPI (a statistic shown as number) and the
/// scope a user needs to see it.
module uim.platform.ai_launchpad.domain.entities.tile;

import uim.platform.ai_launchpad;

mixin(ShowModule!());

@safe:

struct Tile {
  mixin TenantEntity!TileId;

  string title;
  string subtitle;
  string info; /// footer text
  string icon = "sap-icon://product";
  string groupName = "General";
  int sortOrder = 100;
  TileTargetType targetType = TileTargetType.app;
  string target; /// app: route (e.g. "lifecycle/executions"); url: http(s) URL
  string kpi; /// name of a statistic ("" = no number)
  string kpiUnit;
  string requiredScope; /// "" = every authenticated user
  bool visible = true;

  /// True if a user with the scopes may see the tile.
  bool permits(const string[] scopes) const {
    return requiredScope.length == 0 || scopes.canFind(requiredScope);
  }

  void validate(const string[] knownKpis) const {
    requireId(id.value, "Tile ID");
    requireText(title, "Tile title");
    requireMaxLength(title, 80, "Tile title");
    requireMaxLength(subtitle, 120, "Tile subtitle");
    requireMaxLength(info, 80, "Tile footer");
    requireMaxLength(groupName, 80, "Tile group");
    requireText(groupName, "Tile group");
    requireRange(sortOrder, 0, 100_000, "Sort order");
    if (icon.length && !icon.startsWith("sap-icon://"))
      throw AilpException.invalid("The icon must be an SAP icon URI (sap-icon://…), not '" ~ icon ~ "'");
    requireText(target, "Tile target");
    final switch (targetType) {
    case TileTargetType.app:
      if (!isAppRoute(target))
        throw AilpException.invalid("App target '" ~ target ~ "' must be a route such as 'lifecycle/executions'");
      break;
    case TileTargetType.url:
      requireUrl(target, "Tile URL", true);
      break;
    }
    if (kpi.length && !knownKpis.canFind(kpi))
      throw AilpException.invalid("Unknown KPI '" ~ kpi ~ "' (allowed: " ~ knownKpis.join(", ") ~ ")");
    requireMaxLength(kpiUnit, 20, "KPI unit");
    if (requiredScope.length && !knownScopes.canFind(requiredScope))
      throw AilpException.invalid("Unknown scope '" ~ requiredScope ~ "' (allowed: " ~ knownScopes.join(", ") ~ ")");
  }
}

/// "lifecycle", "lifecycle/executions", "admin/users": lower case segments.
bool isAppRoute(string route) pure {
  if (route.length == 0 || route.length > 120 || route[0] == '/' || route[$ - 1] == '/')
    return false;
  foreach (c; route)
    if (!((c >= 'a' && c <= 'z') || (c >= '0' && c <= '9') || c == '-' || c == '/'))
      return false;
  return !route.canFind("//");
}

///
unittest {
  Tile t;
  t.id = TileId("executions");
  t.title = "Executions";
  t.target = "lifecycle/executions";
  t.kpi = "runningExecutions";
  t.requiredScope = "Read";
  t.validate(["runningExecutions"]);
  assert(t.permits(["Read"]) && !t.permits(["Admin"]));
  t.kpi = "bogus";
  assert(failsWith(AilpErrorKind.invalid, () { t.validate(["runningExecutions"]); }));
  t.kpi = "";
  t.targetType = TileTargetType.url;
  t.target = "https://help.sap.com/docs/ai-launchpad";
  t.validate([]);
  assert(isAppRoute("admin/users") && !isAppRoute("/admin") && !isAppRoute("Admin") && !isAppRoute("a//b"));
}
