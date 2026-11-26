/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Authorization scopes (XSUAA local scope names; the built-in JWT login
/// uses the same names).
///   Read     read the landscape, catalog, subscriptions, messages, dead letters
///   Publish  publish events (technical users of producer systems)
///   Operate  dispatch and redeliver messages, pull and acknowledge queued
///            messages, requeue and discard dead letters, pause and resume
///            subscriptions, purge (implies Publish)
///   Manage   maintain formations, systems, event types, channels,
///            subscriptions and filters (implies Operate)
///   Admin    manage the user accounts of the built-in login
module uim.platform.application_events.domain.types.scopes;

import uim.platform.application_events;

mixin(ShowModule!());

@safe:

enum string readScope = "Read";
enum string publishScope = "Publish";
enum string operateScope = "Operate";
enum string manageScope = "Manage";
enum string adminScope = "Admin";

enum string[] knownScopes = [readScope, publishScope, operateScope, manageScope, adminScope];

/// Validated, de-duplicated scopes in canonical order. Every scope implies
/// Read; Manage implies Operate; Operate implies Publish.
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
      throw AehException.invalid("Unknown scope '" ~ t ~ "' (allowed: " ~ knownScopes.join(", ") ~ ")");
    wanted[canonical] = true;
  }
  if (wanted.length)
    wanted[readScope] = true;
  if (manageScope in wanted)
    wanted[operateScope] = true;
  if (operateScope in wanted)
    wanted[publishScope] = true;
  string[] result;
  foreach (k; knownScopes)
    if (k in wanted)
      result ~= k;
  return result;
}

///
unittest {
  assert(normalizeScopes(["manage", " admin "]) == ["Read", "Publish", "Operate", "Manage", "Admin"]);
  assert(normalizeScopes(["publish"]) == ["Read", "Publish"]);
  assert(normalizeScopes(["operate"]) == ["Read", "Publish", "Operate"]);
  assert(normalizeScopes([]).length == 0 && normalizeScopes(["Read"]) == ["Read"]);
  assert(failsWith(AehErrorKind.invalid, () { normalizeScopes(["root"]); }));
}
