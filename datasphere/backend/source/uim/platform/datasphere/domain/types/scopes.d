/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Authorization scopes (XSUAA local scope names; the built-in JWT login
/// uses the same names).
///   Read      read spaces, connections, models, catalog, schedules and runs
///   Integrate run replications, data flows, view persistence, tasks and
///             task chains; validate connections; deploy objects
///   Model     maintain views, data flows, remote tables, data access
///             controls and the catalog (implies Integrate)
///   Manage    maintain spaces, members, connections, tasks and task chains
///             (implies Model)
///   Admin     manage the user accounts of the built-in login
module uim.platform.datasphere.domain.types.scopes;

import uim.platform.datasphere;

mixin(ShowModule!());

@safe:

enum string readScope = "Read";
enum string integrateScope = "Integrate";
enum string modelScope = "Model";
enum string manageScope = "Manage";
enum string adminScope = "Admin";

enum string[] knownScopes = [readScope, integrateScope, modelScope, manageScope, adminScope];

/// Validated, de-duplicated scopes in canonical order. Every scope implies
/// Read; Manage implies Model; Model implies Integrate.
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
      throw DspException.invalid("Unknown scope '" ~ t ~ "' (allowed: " ~ knownScopes.join(", ") ~ ")");
    wanted[canonical] = true;
  }
  if (wanted.length)
    wanted[readScope] = true;
  if (manageScope in wanted)
    wanted[modelScope] = true;
  if (modelScope in wanted)
    wanted[integrateScope] = true;
  string[] result;
  foreach (k; knownScopes)
    if (k in wanted)
      result ~= k;
  return result;
}

///
unittest {
  assert(normalizeScopes(["manage", " admin "]) == knownScopes);
  assert(normalizeScopes(["model"]) == ["Read", "Integrate", "Model"]);
  assert(normalizeScopes(["integrate"]) == ["Read", "Integrate"]);
  assert(normalizeScopes([]).length == 0 && normalizeScopes(["Read"]) == ["Read"]);
  assert(failsWith(DspErrorKind.invalid, () { normalizeScopes(["root"]); }));
}
