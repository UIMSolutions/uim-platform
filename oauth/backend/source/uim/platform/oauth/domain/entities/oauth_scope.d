/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.oauth.domain.entities.oauth_scope;

import uim.platform.oauth;

mixin(ShowModule!());

@safe:

/// A scope that clients may be granted, grouped by the application
/// (resource server) that checks it. The name is the scope value itself,
/// unique per tenant (e.g. "orders.read").
struct OAuthScope {
  mixin TenantEntity!OAuthScopeId;

  string applicationId; /// resource server / xsappname the scope belongs to
  string name;
  string description;
  ScopeStatus status = ScopeStatus.active;

  bool isActive() const {
    return status == ScopeStatus.active;
  }

  void validate() const {
    requireText(applicationId, "Application ID");
    if (!isValidScopeName(name))
      throw OAuthException.invalid("Scope name '" ~ name ~ "' must be 1-128 printable characters without spaces or quotes");
  }
}

///
unittest {
  OAuthScope s;
  s.applicationId = "orders";
  s.name = "orders.read";
  s.validate();
  s.name = "orders read";
  assert(failsWith(OAuthErrorKind.invalid, () { s.validate(); }));
}
