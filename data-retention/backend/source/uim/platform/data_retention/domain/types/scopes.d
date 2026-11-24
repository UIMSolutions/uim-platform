/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Authorization scopes (XSUAA local scope names; the built-in JWT login
/// uses the same names).
///   Read    read master data, purposes, rules, data subjects, requests and jobs
///   Manage  maintain all of it, run end-of-purpose checks, process deletion
///           requests, run archiving and destruction jobs
///   Admin   manage the user accounts of the built-in login
module uim.platform.data_retention.domain.types.scopes;

import uim.platform.data_retention;

mixin(ShowModule!());

@safe:

enum string readScope = "Read";
enum string manageScope = "Manage";
enum string adminScope = "Admin";

enum string[] knownScopes = [readScope, manageScope, adminScope];

/// Validated, de-duplicated scopes in canonical order; Manage and Admin imply Read.
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
      throw DataRetentionException.invalid("Unknown scope '" ~ t ~ "' (allowed: " ~ knownScopes.join(", ") ~ ")");
    wanted[canonical] = true;
  }
  if (wanted.length)
    wanted[readScope] = true;
  string[] result;
  foreach (k; knownScopes)
    if (k in wanted)
      result ~= k;
  return result;
}

///
unittest {
  assert(normalizeScopes(["manage", " admin "]) == ["Read", "Manage", "Admin"]);
  assert(normalizeScopes([]).length == 0 && normalizeScopes(["Read"]) == ["Read"]);
  assert(failsWith(DrErrorKind.invalid, () { normalizeScopes(["root"]); }));
}
