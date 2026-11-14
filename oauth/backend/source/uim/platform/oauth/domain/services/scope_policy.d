/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Which scopes may be granted to a client.
module uim.platform.oauth.domain.services.scope_policy;

import uim.platform.oauth;

mixin(ShowModule!());

@safe:

/// The scopes to grant for a request (RFC 6749 §3.3):
///   * nothing requested → all allowed scopes of the client
///   * requested scopes must be allowed for the client (else invalid_scope)
///   * only active scopes are granted (activeScopes = names of active OAuthScopes)
string[] grantScopes(const string[] requested, const string[] allowed, const string[] activeScopes) {
  auto wanted = normalizeScopes(requested);
  if (wanted.length == 0)
    wanted = normalizeScopes(allowed);
  foreach (s; wanted)
    if (!allowed.canFind(s))
      protocolError(OAuthError.invalidScope, "Scope '" ~ s ~ "' is not allowed for this client");
  string[] granted;
  foreach (s; wanted)
    if (activeScopes.canFind(s))
      granted ~= s;
  if (requested.length > 0 && granted.length < wanted.length)
    protocolError(OAuthError.invalidScope, "Requested scope is inactive: " ~ wanted.filter!(s => !granted.canFind(s)).array.joinScopes);
  return granted;
}

/// Scopes for a refresh: the original grant, or a subset of it (RFC 6749 §6).
string[] refreshScopes(const string[] requested, const string[] original) {
  auto wanted = normalizeScopes(requested);
  if (wanted.length == 0)
    return original.dup;
  if (!isScopeSubset(wanted, original))
    protocolError(OAuthError.invalidScope, "A refresh may only narrow the original scope");
  return wanted;
}

///
unittest {
  auto allowed = ["a", "b", "c"];
  auto active = ["a", "b"];
  assert(grantScopes([], allowed, active) == ["a", "b"]); // inactive c silently dropped
  assert(grantScopes(["b"], allowed, active) == ["b"]);
  assert(failsWithProtocol(OAuthError.invalidScope, () { grantScopes(["x"], allowed, active); }));
  assert(failsWithProtocol(OAuthError.invalidScope, () { grantScopes(["c"], allowed, active); }));
  assert(refreshScopes([], ["a", "b"]) == ["a", "b"] && refreshScopes(["a"], ["a", "b"]) == ["a"]);
  assert(failsWithProtocol(OAuthError.invalidScope, () { refreshScopes(["z"], ["a"]); }));
}
