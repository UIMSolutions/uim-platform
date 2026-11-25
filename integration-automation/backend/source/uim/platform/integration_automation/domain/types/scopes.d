/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Authorization scopes (XSUAA local scope names; the built-in JWT login
/// uses the same names).
///   Read     read the landscape, scenarios, workflows, tasks and logs
///   Execute  run workflows: create, start, suspend, resume, terminate;
///            start, complete, fail, skip, retry and assign tasks
///   Manage   maintain systems, destinations, scenarios and their task
///            templates; test connections, purge logs (implies Execute)
///   Admin    manage the user accounts of the built-in login
module uim.platform.integration_automation.domain.types.scopes;

import uim.platform.integration_automation;

mixin(ShowModule!());

@safe:

enum string readScope = "Read";
enum string executeScope = "Execute";
enum string manageScope = "Manage";
enum string adminScope = "Admin";

enum string[] knownScopes = [readScope, executeScope, manageScope, adminScope];

/// Validated, de-duplicated scopes in canonical order. Every scope implies
/// Read; Manage implies Execute.
string[] normalizeScopes(const string[] scopes) {
  import std.uni : icmp;

  bool[string] wanted;
  foreach (s; scopes) {
    auto t = s.strip;
    if (t.length == 0)
      continue;
    string canonical;
    foreach (k; knownScopes)
      if (icmp(k, t) == 0)
        canonical = k;
    if (canonical.length == 0)
      throw IaException.invalid("Unknown scope '" ~ t ~ "' (allowed: " ~ knownScopes.join(", ") ~ ")");
    wanted[canonical] = true;
  }
  if (wanted.length)
    wanted[readScope] = true;
  if (manageScope in wanted)
    wanted[executeScope] = true;
  string[] result;
  foreach (k; knownScopes)
    if (k in wanted)
      result ~= k;
  return result;
}

///
unittest {
  assert(normalizeScopes(["manage", " admin "]) == ["Read", "Execute", "Manage", "Admin"]);
  assert(normalizeScopes(["execute"]) == ["Read", "Execute"]);
  assert(normalizeScopes([]).length == 0 && normalizeScopes(["Read"]) == ["Read"]);
  assert(failsWith(IaErrorKind.invalid, () { normalizeScopes(["root"]); }));
}
