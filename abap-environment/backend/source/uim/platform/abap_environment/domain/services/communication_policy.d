/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Rules of communication arrangements: scenario ids, credentials, endpoints.
module uim.platform.abap_environment.domain.services.communication_policy;

import std.ascii : isDigit, isUpper;
import uim.platform.abap_environment;

mixin(ShowModule!());

@safe:

/// "SAP_COM_0510" or a customer scenario starting with Z or Y ("Z_TRAVEL_COM").
void validateScenarioId(string scenario) {
  validate(scenario.length > 0, "Communication scenario is required");
  if (scenario.startsWith("SAP_COM_")) {
    auto number = scenario["SAP_COM_".length .. $];
    validate(number.length == 4 && number.all!(c => isDigit(c)),
      "SAP communication scenarios look like SAP_COM_0510 (got '" ~ scenario ~ "')");
    return;
  }
  validate(scenario[0] == 'Z' || scenario[0] == 'Y',
    "Customer communication scenarios must start with Z or Y (got '" ~ scenario ~ "')");
  validateAbapName("Communication scenario", scenario, 40);
}

/// The credentials the authentication method needs must be present.
void validateCredentials(const ref CommunicationArrangement a) {
  final switch (a.authMethod) {
  case CommunicationAuthMethod.basicAuthentication:
    validate(a.communicationUser.length > 0, "Basic authentication needs a communication user");
    break;
  case CommunicationAuthMethod.oauth2ClientCredentials:
    validate(a.clientId.length > 0, "OAuth 2.0 client credentials need a client ID");
    validate(isHttpUrl(a.tokenEndpoint), "OAuth 2.0 client credentials need an http(s) token endpoint");
    break;
  case CommunicationAuthMethod.oauth2SamlBearerAssertion:
    validate(a.clientId.length > 0, "OAuth 2.0 SAML bearer assertion needs a client ID");
    validate(isHttpUrl(a.tokenEndpoint), "OAuth 2.0 SAML bearer assertion needs an http(s) token endpoint");
    break;
  case CommunicationAuthMethod.clientCertificate:
    validate(a.certificateId.length > 0, "Client certificate authentication needs a certificate ID");
    break;
  case CommunicationAuthMethod.noAuthentication:
    validate(a.direction != CommunicationDirection.inbound && a.direction != CommunicationDirection.both,
      "Inbound communication always requires authentication");
    break;
  }
}

/// Endpoint URLs and ports are well formed; names are unique per list.
void validateEndpoints(string what, const CommunicationEndpoint[] endpoints) {
  string[] names;
  foreach (e; endpoints) {
    validate(e.url.length > 0, what ~ ": every service needs a URL or path");
    validate(e.url.startsWith("/") || isHttpUrl(e.url), what ~ ": '" ~ e.url ~ "' must be a path or an http(s) URL");
    validate(e.port >= 0 && e.port <= 65_535, what ~ ": port " ~ e.port.to!string ~ " is out of range");
    if (e.name.length > 0) {
      validate(!names.canFind(e.name), what ~ ": duplicate service '" ~ e.name ~ "'");
      names ~= e.name;
    }
  }
}

/// Inbound arrangements need inbound services only when the direction includes them.
void validateArrangement(const ref CommunicationArrangement a) {
  validateDisplayName("Communication arrangement", a.name);
  validateScenarioId(a.scenarioId.value);
  validateCredentials(a);
  validateEndpoints("Inbound services", a.inboundServices);
  validateEndpoints("Outbound services", a.outboundServices);
  validate(a.direction != CommunicationDirection.inbound || a.outboundServices.length == 0,
    "An inbound arrangement cannot define outbound services");
  validate(a.direction != CommunicationDirection.outbound || a.inboundServices.length == 0,
    "An outbound arrangement cannot define inbound services");
}

///
unittest {
  validateScenarioId("SAP_COM_0510");
  validateScenarioId("Z_TRAVEL_COM");
  bool failed(void delegate() @safe f) {
    try
      f();
    catch (AbapValidationException)
      return true;
    return false;
  }

  assert(failed(() => validateScenarioId("SAP_COM_51")));
  assert(failed(() => validateScenarioId("TRAVEL")));

  CommunicationArrangement a;
  a.name = "Travel";
  a.scenarioId = CommunicationScenarioId("SAP_COM_0510");
  assert(failed(() => validateArrangement(a))); // basic auth without user
  a.communicationUser = "COMM_USER";
  validateArrangement(a);
  a.authMethod = CommunicationAuthMethod.oauth2ClientCredentials;
  a.clientId = "cid";
  assert(failed(() => validateArrangement(a))); // no token endpoint
  a.tokenEndpoint = "https://idp.example.com/oauth/token";
  validateArrangement(a);
  a.outboundServices = [CommunicationEndpoint("x", "/x")];
  assert(failed(() => validateArrangement(a))); // inbound arrangement with outbound services
}
