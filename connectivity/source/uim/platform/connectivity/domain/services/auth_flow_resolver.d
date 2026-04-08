/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.connectivity.domain.services.auth_flow_resolver;

import uim.platform.connectivity.domain.entities.destination;
import uim.platform.connectivity.domain.entities.certificate;
import uim.platform.connectivity.domain.types;

/// Result of resolving an authentication flow for a destination.
struct AuthFlowResult {
  bool valid;
  string[] errors;
  string resolvedAuthHeader; // e.g., "Bearer <token>" or "Basic <b64>"
}

/// Domain service: validates and resolves authentication configuration for destinations.
struct AuthFlowResolver {
  /// Validate that the destination has the required fields for its auth type.
  static AuthFlowResult validate(const ref Destination dest) {
    string[] errors;

    final switch (dest.authType) {
    case AuthenticationType.noAuthentication:
      break;

    case AuthenticationType.basicAuthentication:
      if (dest.user.length == 0)
        errors ~= "Basic authentication requires 'user'";
      if (dest.password.length == 0)
        errors ~= "Basic authentication requires 'password'";
      break;

    case AuthenticationType.oauth2ClientCredentials:
      if (dest.clientid.isEmpty)
        errors ~= "OAuth2 Client Credentials requires 'clientId'";
      if (dest.clientSecret.length == 0)
        errors ~= "OAuth2 Client Credentials requires 'clientSecret'";
      if (dest.tokenServiceUrl.length == 0)
        errors ~= "OAuth2 Client Credentials requires 'tokenServiceUrl'";
      break;

    case AuthenticationType.oauth2SAMLBearerAssertion:
      if (dest.tokenServiceUrl.length == 0)
        errors ~= "OAuth2 SAML Bearer requires 'tokenServiceUrl'";
      if (dest.clientid.isEmpty)
        errors ~= "OAuth2 SAML Bearer requires 'clientId'";
      break;

    case AuthenticationType.oauth2UserTokenExchange:
      if (dest.clientid.isEmpty)
        errors ~= "OAuth2 User Token Exchange requires 'clientId'";
      if (dest.clientSecret.length == 0)
        errors ~= "OAuth2 User Token Exchange requires 'clientSecret'";
      if (dest.tokenServiceUrl.length == 0)
        errors ~= "OAuth2 User Token Exchange requires 'tokenServiceUrl'";
      break;

    case AuthenticationType.oauth2JWTBearer:
      if (dest.clientid.isEmpty)
        errors ~= "OAuth2 JWT Bearer requires 'clientId'";
      if (dest.tokenServiceUrl.length == 0)
        errors ~= "OAuth2 JWT Bearer requires 'tokenServiceUrl'";
      break;

    case AuthenticationType.oauth2Password:
      if (dest.clientid.isEmpty)
        errors ~= "OAuth2 Password requires 'clientId'";
      if (dest.user.length == 0)
        errors ~= "OAuth2 Password requires 'user'";
      if (dest.password.length == 0)
        errors ~= "OAuth2 Password requires 'password'";
      if (dest.tokenServiceUrl.length == 0)
        errors ~= "OAuth2 Password requires 'tokenServiceUrl'";
      break;

    case AuthenticationType.oauth2AuthorizationCode:
      if (dest.clientid.isEmpty)
        errors ~= "OAuth2 Authorization Code requires 'clientId'";
      if (dest.clientSecret.length == 0)
        errors ~= "OAuth2 Authorization Code requires 'clientSecret'";
      if (dest.tokenServiceUrl.length == 0)
        errors ~= "OAuth2 Authorization Code requires 'tokenServiceUrl'";
      break;

    case AuthenticationType.clientCertificateAuthentication:
      if (dest.certificateid.isEmpty)
        errors ~= "Client Certificate authentication requires 'certificateId'";
      break;

    case AuthenticationType.principalPropagation:
      if (
        dest.proxyType != ProxyType.onPremise)
        errors ~= "Principal Propagation is only supported with ProxyType.onPremise";
      break;

    case AuthenticationType.samlAssertion:
      if (dest.tokenServiceUrl.length == 0)
        errors ~= "SAML Assertion requires 'tokenServiceUrl'";
      break;
    }

    // On-premise destinations require cloud connector location
    if (dest.proxyType == ProxyType.onPremise && dest.cloudConnectorLocationid.isEmpty)
      errors ~= "On-premise destinations require 'cloudConnectorLocationId'";

    return AuthFlowResult(errors.length == 0, errors, "");
  }
}
