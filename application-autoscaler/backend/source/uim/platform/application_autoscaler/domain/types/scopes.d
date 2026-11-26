/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Authorization scopes (XSUAA local scope names; the built-in JWT login
/// uses the same names).
///   Read     read bindings, policies, rules, schedules, metrics, history
///   Operate  submit metric values, run scaling evaluations, scale manually,
///            suspend and resume autoscaling of a binding
///   Manage   maintain bindings, policies, rules and schedules; attach and
///            detach policies (implies Operate)
///   Admin    manage the user accounts of the built-in login
module uim.platform.application_autoscaler.domain.types.scopes;

import uim.platform.application_autoscaler;

mixin(ShowModule!());

@safe:

enum string readScope = "Read";
enum string operateScope = "Operate";
enum string manageScope = "Manage";
enum string adminScope = "Admin";

enum string[] knownScopes = [readScope, operateScope, manageScope, adminScope];

/// Validated, de-duplicated scopes in canonical order. Every scope implies
/// Read; Manage implies Operate.
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
      throw AasException.invalid("Unknown scope '" ~ t ~ "' (allowed: " ~ knownScopes.join(", ") ~ ")");
    wanted[canonical] = true;
  }
  if (wanted.length)
    wanted[readScope] = true;
  if (manageScope in wanted)
    wanted[operateScope] = true;
  string[] result;
  foreach (k; knownScopes)
    if (k in wanted)
      result ~= k;
  return result;
}

///
unittest {
  assert(normalizeScopes(["manage", " admin "]) == ["Read", "Operate", "Manage", "Admin"]);
  assert(normalizeScopes(["operate"]) == ["Read", "Operate"]);
  assert(normalizeScopes([]).length == 0 && normalizeScopes(["Read"]) == ["Read"]);
  assert(failsWith(AasErrorKind.invalid, () { normalizeScopes(["root"]); }));
}
