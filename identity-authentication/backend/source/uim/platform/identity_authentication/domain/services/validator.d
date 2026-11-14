/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Domain validation rules. Each validate() returns the list of violations.
module uim.platform.identity_authentication.domain.services.validator;

import uim.platform.identity_authentication;

mixin(ShowModule!());

@safe:

struct IdentityValidator {
  /// Minimal syntactic e-mail check: local@domain.tld, no spaces.
  static bool isEmail(string value) pure {
    auto at = value.indexOf('@');
    if (at <= 0 || at != value.lastIndexOf('@') || value.canFind(' '))
      return false;
    auto domain = value[at + 1 .. $];
    auto dot = domain.lastIndexOf('.');
    return dot > 0 && dot < cast(ptrdiff_t) domain.length - 1;
  }

  /// Absolute http(s) URL.
  static bool isHttpUrl(string value) pure {
    return (value.startsWith("https://") && value.length > 8) || (value.startsWith("http://") && value.length > 7);
  }

  /// Password policy: at least minLength characters with letters and digits.
  static string[] validatePassword(string password, size_t minLength = 8) {
    string[] errors;
    if (password.length < minLength)
      errors ~= "password must have at least " ~ minLength.to!string ~ " characters";
    if (!password.any!(c => c >= '0' && c <= '9'))
      errors ~= "password must contain a digit";
    if (!password.any!(c => (c >= 'a' && c <= 'z') || (c >= 'A' && c <= 'Z')))
      errors ~= "password must contain a letter";
    return errors;
  }

  static string[] validate(const IAUser u) {
    string[] errors;
    if (u.userName.strip.length == 0)
      errors ~= "userName is required";
    else if (u.userName.canFind(' '))
      errors ~= "userName must not contain spaces";
    if (!isEmail(u.email))
      errors ~= "email '" ~ u.email ~ "' is not a valid e-mail address";
    return errors;
  }

  static string[] validate(const IAGroup g) {
    return g.name.strip.length == 0 ? ["name is required"] : null;
  }

  static string[] validate(const Application a) {
    string[] errors;
    if (a.name.strip.length == 0)
      errors ~= "name is required";
    foreach (uri; a.redirectUris)
      if (!isHttpUrl(uri))
        errors ~= "redirect URI '" ~ uri ~ "' must be an absolute http(s) URL";
    if (a.protocol == SsoProtocol.saml && a.samlAcsUrl.length > 0 && !isHttpUrl(a.samlAcsUrl))
      errors ~= "samlAcsUrl must be an absolute http(s) URL";
    return errors;
  }

  static string[] validate(const AuthorizationPolicy p) {
    string[] errors;
    if (p.name.strip.length == 0)
      errors ~= "name is required";
    foreach (r; p.rules) {
      if (!policyAttributes.canFind(r.attribute))
        errors ~= "rule attribute '" ~ r.attribute ~ "' must be one of " ~ policyAttributes.join(", ");
      if (!policyOperators.canFind(r.operator_))
        errors ~= "rule operator '" ~ r.operator_ ~ "' must be one of " ~ policyOperators.join(", ");
      if (r.value.strip.length == 0)
        errors ~= "rule '" ~ r.attribute ~ "' needs a value";
    }
    return errors;
  }

  static string[] validate(const RiskRule r) {
    string[] errors;
    if (r.name.strip.length == 0)
      errors ~= "name is required";
    if (r.conditions.length == 0)
      errors ~= "at least one condition is required";
    foreach (c; r.conditions) {
      if (!riskConditionTypes.canFind(c.conditionType))
        errors ~= "condition type '" ~ c.conditionType ~ "' must be one of " ~ riskConditionTypes.join(", ");
      if (!riskOperators.canFind(c.operator_))
        errors ~= "condition operator '" ~ c.operator_ ~ "' must be one of " ~ riskOperators.join(", ");
      if (c.value.strip.length == 0)
        errors ~= "condition '" ~ c.conditionType ~ "' needs a value";
    }
    return errors;
  }

  static string[] validate(const IdpConfig c) {
    string[] errors;
    if (c.name.strip.length == 0)
      errors ~= "name is required";
    if (c.idpType == IdpType.oidc) {
      if (!isHttpUrl(c.authorizationEndpoint))
        errors ~= "authorizationEndpoint must be an absolute http(s) URL for OIDC providers";
      if (c.clientId.length == 0)
        errors ~= "clientId is required for OIDC providers";
    }
    if (c.idpType == IdpType.saml && !isHttpUrl(c.metadataUrl))
      errors ~= "metadataUrl must be an absolute http(s) URL for SAML providers";
    foreach (d; c.domainHints)
      if (d.canFind('@') || d.canFind(' '))
        errors ~= "domain hint '" ~ d ~ "' must be a bare domain (example.com)";
    return errors;
  }
}
///
unittest {
  mixin(ShowTest!("IdentityValidator"));

  assert(IdentityValidator.isEmail("jane@example.com"));
  assert(!IdentityValidator.isEmail("jane@example"));
  assert(!IdentityValidator.isEmail("@example.com"));
  assert(!IdentityValidator.isEmail("a@b@c.de"));
  assert(IdentityValidator.validatePassword("abc").length == 2);
  assert(IdentityValidator.validatePassword("Secret123").length == 0);

  auto u = IAUser(TenantId("t"));
  u.userName = "jane";
  u.email = "jane@example.com";
  assert(IdentityValidator.validate(u).length == 0);

  AuthorizationPolicy p;
  p.name = "admins";
  p.rules = [PolicyRule("group", "in", "admins"), PolicyRule("planet", "eq", "")];
  assert(IdentityValidator.validate(p).length == 2);

  IdpConfig idp;
  idp.name = "Azure";
  idp.idpType = IdpType.oidc;
  assert(IdentityValidator.validate(idp).length == 2);
}
