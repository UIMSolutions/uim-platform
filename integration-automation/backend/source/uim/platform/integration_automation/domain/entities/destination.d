/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// A destination: how automated tasks reach an API of a system (protocol,
/// URL, authentication and proxy route). Mirrors the concepts of the SAP
/// BTP Destination service; secrets are never stored here.
module uim.platform.integration_automation.domain.entities.destination;

import uim.platform.integration_automation;

mixin(ShowModule!());

@safe:

struct Destination {
  mixin TenantEntity!DestinationId;

  string name; /// unique per tenant, e.g. "S4_BUSINESS_PARTNER"
  string description;
  SystemConnectionId systemId; /// optional: the system the destination points to
  DestinationType destinationType = DestinationType.http;
  string url; /// base URL (http, odata, soap, restApi)
  AuthenticationType authentication = AuthenticationType.noAuthentication;
  ProxyType proxyType = ProxyType.internet;
  string locationId; /// Cloud Connector location (proxyType onPremise)
  string user; /// technical user name (basic), the password lives in the credential store
  string tokenServiceUrl; /// OAuth2 token endpoint
  string audience;
  string scope_; /// OAuth2 scope
  bool enabled = true;

  bool isHttpBased() const {
    return destinationType != DestinationType.rfc;
  }

  void validate() const {
    requireId(id.value, "Destination ID");
    requireText(name, "Name");
    requireMaxLength(name, 200, "Name");
    if (name.canFind!(c => c == ' ' || c == '/' || c == '\\'))
      throw IaException.invalid("Destination name '" ~ name ~ "' must not contain blanks or slashes");
    requireMaxLength(description, 2000, "Description");
    requireMaxLength(url, 2048, "URL");
    if (isHttpBased && !isHttpUrl(url))
      throw IaException.invalid("URL '" ~ url ~ "' must start with http:// or https://");
    if ((authentication == AuthenticationType.oauth2ClientCredentials || authentication == AuthenticationType.oauth2Saml)
      && !isHttpUrl(tokenServiceUrl))
      throw IaException.invalid("OAuth2 authentication needs a token service URL (http:// or https://)");
    if (tokenServiceUrl.length && !isHttpUrl(tokenServiceUrl))
      throw IaException.invalid("Token service URL '" ~ tokenServiceUrl ~ "' must start with http:// or https://");
    if (authentication == AuthenticationType.basic)
      requireText(user, "User (basic authentication)");
    if (authentication == AuthenticationType.principalPropagation && proxyType != ProxyType.onPremise)
      throw IaException.invalid("Principal propagation needs the proxy type onPremise (Cloud Connector)");
    requireMaxLength(locationId, 64, "Location ID");
    requireMaxLength(user, 256, "User");
  }
}

/// "http://…" or "https://…" with a host.
bool isHttpUrl(string url) pure {
  auto u = url.strip;
  foreach (scheme; ["https://", "http://"])
    if (u.length > scheme.length && u[0 .. scheme.length] == scheme)
      return true;
  return false;
}

///
unittest {
  Destination d;
  d.id = DestinationId("d1");
  d.name = "S4_API";
  d.url = "https://s4.example.com/sap/opu/odata4";
  d.validate();
  d.authentication = AuthenticationType.oauth2ClientCredentials;
  assert(failsWith(IaErrorKind.invalid, () { d.validate(); }));
  d.tokenServiceUrl = "https://auth.example.com/oauth/token";
  d.validate();
  d.destinationType = DestinationType.rfc;
  d.url = "";
  d.validate();
  d.name = "with blank";
  assert(failsWith(IaErrorKind.invalid, () { d.validate(); }));
  assert(isHttpUrl("http://a") && !isHttpUrl("ftp://a") && !isHttpUrl("https://"));
}
