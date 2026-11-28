/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Built-in roles and the scopes of a user (the union of the scopes of the
/// assigned roles, normalized).
module uim.platform.ai_launchpad.domain.services.roles;

import uim.platform.ai_launchpad;

mixin(ShowModule!());

@safe:

enum string administratorRole = "Administrator";
enum string viewerRole = "Viewer";

struct RoleDefinition {
  string id;
  string name;
  string description;
  string[] scopes;
}

/// The built-in roles (also the XSUAA role templates).
RoleDefinition[] builtInRoleDefinitions() {
  return [
    RoleDefinition(viewerRole, "Viewer", "Read the launchpad, runtimes, the ML life cycle, the registry and prompts",
      [readScope]),
    RoleDefinition("Operator", "Operator", "Validate connections, start and stop executions and deployments, run prompts",
      [readScope, operateScope]),
    RoleDefinition("Developer", "AI Developer",
      "Maintain scenarios, configurations, models, datasets and prompts; operate", [
        readScope, operateScope, developScope
      ]),
    RoleDefinition("Manager", "AI Manager", "Maintain workspaces, connections and resource groups; develop and operate",
      [readScope, operateScope, developScope, manageScope]),
    RoleDefinition(administratorRole, "Administrator", "Everything, including users, roles, the audit log and tiles",
      knownScopes.dup)
  ];
}

bool isBuiltInRole(string id) {
  return builtInRoleDefinitions.any!(r => r.id == id);
}

/// The scopes granted by the role ids (unknown role ids grant nothing).
string[] effectiveScopes(const Role[] roles, const string[] roleIds) {
  string[] scopes;
  foreach (r; roles)
    if (roleIds.canFind(r.id.value))
      scopes ~= r.scopes;
  return normalizeScopes(scopes);
}

///
unittest {
  auto defs = builtInRoleDefinitions();
  assert(defs.length == 5 && defs[$ - 1].scopes == knownScopes && isBuiltInRole("Operator") && !isBuiltInRole("x"));
  Role viewer, ops;
  viewer.id = RoleId("Viewer");
  viewer.scopes = ["Read"];
  ops.id = RoleId("ops");
  ops.scopes = ["Operate"];
  assert(effectiveScopes([viewer, ops], ["Viewer", "ops", "ghost"]) == ["Read", "Operate"]);
  assert(effectiveScopes([viewer], []).length == 0);
}
