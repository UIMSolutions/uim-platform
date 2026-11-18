/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// IAM style evaluation of bucket access policies.
module uim.platform.object_store.domain.services.access_evaluator;

import uim.platform.object_store;

mixin(ShowModule!());

@safe:

/// The principal of unauthenticated callers.
enum string anonymousPrincipal = "anonymous";

/// The principal of a service binding.
string bindingPrincipal(string bindingName) pure {
  return "binding:" ~ bindingName;
}

/// True if a statement applies to the principal. With public access blocked,
/// wildcard statements never apply to anonymous callers.
private bool principalMatches(const AccessPolicy p, string principal, bool publicAccessBlocked) {
  foreach (pattern; p.principals) {
    if (principal == anonymousPrincipal && publicAccessBlocked && pattern != anonymousPrincipal)
      continue;
    if (wildcardMatch(principal, pattern))
      return true;
  }
  return false;
}

private bool actionMatches(const AccessPolicy p, PolicyAction action) {
  return p.actions.canFind(PolicyAction.all) || p.actions.canFind(action);
}

private bool resourceMatches(const AccessPolicy p, string key) {
  if (p.resources.length == 0)
    return true;
  return p.resources.any!(r => wildcardMatch(key, r));
}

/// Evaluate the policies of one bucket:
///   1. an enabled deny statement that matches → denied
///   2. an enabled allow statement that matches → allowed
///   3. otherwise → implicitly denied
/// `key` is the object key (or the prefix for "list").
AccessDecision evaluateAccess(const AccessPolicy[] policies, string principal, PolicyAction action,
    string key, bool publicAccessBlocked) {
  AccessDecision d;
  d.principal = principal;
  d.action = action;
  d.key = key;

  ptrdiff_t allow = -1;
  foreach (i, ref p; policies) {
    if (!p.enabled || !principalMatches(p, principal, publicAccessBlocked) || !actionMatches(p, action)
        || !resourceMatches(p, key))
      continue;
    if (p.effect == PolicyEffect.deny) {
      d.allowed = false;
      d.effect = PolicyEffect.deny;
      d.matchedPolicy = p.name;
      d.reason = "Explicitly denied by policy '" ~ p.name ~ "'";
      return d;
    }
    if (allow < 0)
      allow = i;
  }
  if (allow >= 0) {
    d.allowed = true;
    d.effect = PolicyEffect.allow;
    d.matchedPolicy = policies[allow].name;
    d.reason = "Allowed by policy '" ~ policies[allow].name ~ "'";
  } else {
    d.reason = "No policy allows " ~ enumText(action) ~ " on '" ~ key ~ "' for " ~ principal;
  }
  return d;
}

///
unittest {
  mixin(ShowTest!("evaluateAccess"));

  AccessPolicy readAll;
  readAll.name = "read-all";
  readAll.principals = ["*"];
  readAll.actions = [PolicyAction.read, PolicyAction.list];
  readAll.resources = ["*"];

  AccessPolicy denySecrets;
  denySecrets.name = "no-secrets";
  denySecrets.effect = PolicyEffect.deny;
  denySecrets.principals = ["*"];
  denySecrets.actions = [PolicyAction.all];
  denySecrets.resources = ["secrets/*"];

  AccessPolicy uploader;
  uploader.name = "uploader";
  uploader.principals = ["binding:ci-*"];
  uploader.actions = [PolicyAction.write];
  uploader.resources = ["builds/*"];

  auto policies = [readAll, denySecrets, uploader];
  assert(evaluateAccess(policies, "jane", PolicyAction.read, "docs/a.txt", true).allowed);
  auto denied = evaluateAccess(policies, "jane", PolicyAction.read, "secrets/key.pem", true);
  assert(!denied.allowed && denied.matchedPolicy == "no-secrets");
  assert(evaluateAccess(policies, "binding:ci-main", PolicyAction.write, "builds/app.zip", true).allowed);
  assert(!evaluateAccess(policies, "binding:ci-main", PolicyAction.write, "docs/x", true).allowed);
  assert(!evaluateAccess(policies, anonymousPrincipal, PolicyAction.read, "docs/a.txt", true).allowed);
  assert(evaluateAccess(policies, anonymousPrincipal, PolicyAction.read, "docs/a.txt", false).allowed);
  policies[0].enabled = false;
  assert(!evaluateAccess(policies, "jane", PolicyAction.read, "docs/a.txt", true).allowed);
}
