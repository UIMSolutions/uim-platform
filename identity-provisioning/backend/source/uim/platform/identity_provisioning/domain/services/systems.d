/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Validation rules of system connections.
module uim.platform.identity_provisioning.domain.services.systems;

import uim.platform.identity_provisioning;

mixin(ShowModule!());

@safe:

/// The URL schemes accepted for a system type.
string[] urlSchemes(SystemType type) {
  final switch (type) {
  case SystemType.ldap:
    return ["ldap://", "ldaps://"];
  case SystemType.csv:
    return ["file://", "https://", "http://"];
  case SystemType.ias, SystemType.sapHr, SystemType.successFactors, SystemType.scim, SystemType.azureAd:
    return ["https://", "http://"];
  case SystemType.custom:
    return [];
  }
}

/// Validate the connection settings of a system in `role`. Returns the
/// normalized settings (trimmed URL without trailing "/").
ConnectionSettings validateConnection(ConnectionSettings s, SystemRole role) {
  validate(supportsRole(s.systemType, role), "System type '" ~ enumText(s.systemType) ~ "' cannot be used as "
      ~ enumText(role) ~ " system (see /system-types)");
  s.url = s.url.strip;
  while (s.url.length > 1 && s.url.endsWith("/") && !s.url.endsWith("://"))
    s.url = s.url[0 .. $ - 1];
  validate(s.url.length > 0, "URL is required");
  auto schemes = urlSchemes(s.systemType);
  if (schemes.length > 0) {
    bool ok;
    foreach (scheme; schemes)
      if (s.url.startsWith(scheme) && s.url.length > scheme.length)
        ok = true;
    validate(ok, "URL of a " ~ enumText(s.systemType) ~ " system must start with " ~ schemes.join(" or ")
        ~ " (got '" ~ s.url ~ "')");
  }
  final switch (s.authenticationType) {
  case AuthenticationType.none, AuthenticationType.certificate:
    break;
  case AuthenticationType.basic:
    validate(s.user.strip.length > 0, "User is required for basic authentication");
    break;
  case AuthenticationType.oauth2ClientCredentials:
    validate(s.user.strip.length > 0, "Client ID (user) is required for OAuth 2.0 client credentials");
    break;
  }
  string[] keys;
  foreach (p; s.properties) {
    validate(p.key.strip.length > 0, "Property names must not be empty");
    validate(!keys.canFind(p.key), "Property '" ~ p.key ~ "' is defined twice");
    keys ~= p.key;
  }
  return s;
}

///
unittest {
  bool fails(ConnectionSettings s, SystemRole role) {
    try
      validateConnection(s, role);
    catch (ProvisioningValidationException)
      return true;
    return false;
  }

  ConnectionSettings s;
  s.systemType = SystemType.ias;
  s.url = " https://acme.accounts.ondemand.com/ ";
  s.authenticationType = AuthenticationType.oauth2ClientCredentials;
  s.user = "client";
  assert(validateConnection(s, SystemRole.target).url == "https://acme.accounts.ondemand.com");
  s.user = "";
  assert(fails(s, SystemRole.target));
  s.user = "client";
  s.url = "ldap://x";
  assert(fails(s, SystemRole.target));
  s.systemType = SystemType.ldap;
  assert(!fails(s, SystemRole.source));
  s.systemType = SystemType.csv;
  s.url = "file:///data/hr.csv";
  assert(fails(s, SystemRole.target) && !fails(s, SystemRole.source));
  s.properties = [Attribute("a", "1"), Attribute("a", "2")];
  assert(fails(s, SystemRole.source));
}
