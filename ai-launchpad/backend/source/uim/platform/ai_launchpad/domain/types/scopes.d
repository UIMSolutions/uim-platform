/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Authorization scopes (XSUAA local scope names; the built-in login maps
/// roles to the same names).
///   Read     read everything except the administration (launchpad, runtimes,
///            life cycle, registry, prompts, statistics)
///   Operate  validate connections, start / stop executions and deployments,
///            run prompts in the playground, reconcile with the runtime
///   Develop  maintain scenarios, configurations, models, datasets, prompt
///            collections and prompts (implies Operate)
///   Manage   maintain workspaces, connections and resource groups
///            (implies Develop)
///   Admin    administration: users, roles, audit log, launchpad tiles
module uim.platform.ai_launchpad.domain.types.scopes;

import uim.platform.ai_launchpad;

mixin(ShowModule!());

@safe:

enum string readScope = "Read";
enum string operateScope = "Operate";
enum string developScope = "Develop";
enum string manageScope = "Manage";
enum string adminScope = "Admin";

enum string[] knownScopes = [readScope, operateScope, developScope, manageScope, adminScope];

/// The canonical name of a scope ("" if unknown; case insensitive).
string canonicalScope(string name) {
  import std.uni : icmp;

  auto t = name.strip;
  foreach (k; knownScopes)
    if (icmp(k, t) == 0)
      return k;
  return "";
}

/// Validated, de-duplicated scopes in canonical order. Every scope implies
/// Read; Manage implies Develop; Develop implies Operate.
string[] normalizeScopes(const string[] scopes) {
  bool[string] wanted;
  foreach (s; scopes) {
    if (s.strip.length == 0)
      continue;
    auto canonical = canonicalScope(s);
    if (canonical.length == 0)
      throw AilpException.invalid("Unknown scope '" ~ s.strip ~ "' (allowed: " ~ knownScopes.join(", ") ~ ")");
    wanted[canonical] = true;
  }
  if (wanted.length)
    wanted[readScope] = true;
  if (manageScope in wanted)
    wanted[developScope] = true;
  if (developScope in wanted)
    wanted[operateScope] = true;
  string[] result;
  foreach (k; knownScopes)
    if (k in wanted)
      result ~= k;
  return result;
}

///
unittest {
  assert(normalizeScopes(["manage", " admin "]) == knownScopes);
  assert(normalizeScopes(["develop"]) == ["Read", "Operate", "Develop"]);
  assert(normalizeScopes(["operate"]) == ["Read", "Operate"]);
  assert(normalizeScopes(["Admin"]) == ["Read", "Admin"]);
  assert(normalizeScopes([]).length == 0 && normalizeScopes(["Read"]) == ["Read"]);
  assert(canonicalScope("ADMIN") == "Admin" && canonicalScope("root") == "");
  assert(failsWith(AilpErrorKind.invalid, () { normalizeScopes(["root"]); }));
}
