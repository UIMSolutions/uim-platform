/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Which settings each authentication type of a destination requires.
module uim.platform.connectivity.domain.services.auth_flow;

import uim.platform.connectivity;

mixin(ShowModule!());

@safe:

/// True for the OAuth / SAML flows that need a token service.
bool needsTokenService(AuthenticationType t) pure nothrow {
  switch (t) {
  case AuthenticationType.oauth2ClientCredentials, AuthenticationType.oauth2SAMLBearerAssertion,
      AuthenticationType.oauth2UserTokenExchange, AuthenticationType.oauth2JWTBearer,
      AuthenticationType.oauth2Password, AuthenticationType.oauth2AuthorizationCode,
      AuthenticationType.samlAssertion:
    return true;
  default:
    return false;
  }
}

/// Authentication types a destination type supports.
bool supportsAuthentication(DestinationType d, AuthenticationType t) pure nothrow {
  final switch (d) {
  case DestinationType.http:
    return true;
  case DestinationType.rfc:
    return t == AuthenticationType.noAuthentication || t == AuthenticationType.basicAuthentication
      || t == AuthenticationType.principalPropagation || t == AuthenticationType.clientCertificateAuthentication;
  case DestinationType.mail, DestinationType.ldap:
    return t == AuthenticationType.noAuthentication || t == AuthenticationType.basicAuthentication
      || t == AuthenticationType.clientCertificateAuthentication;
  case DestinationType.tcp:
    return t == AuthenticationType.noAuthentication || t == AuthenticationType.clientCertificateAuthentication;
  }
}

/// All problems of the authentication / routing configuration of a destination
/// (empty = complete). Certificates are checked against the store by the application layer.
string[] authenticationErrors(const Destination d) {
  string[] errors;
  void need(bool ok, string message) {
    if (!ok)
      errors ~= message;
  }

  auto auth = enumText(d.authenticationType);
  need(supportsAuthentication(d.destinationType, d.authenticationType),
    enumText(d.destinationType) ~ " destinations do not support " ~ auth);

  final switch (d.authenticationType) {
  case AuthenticationType.noAuthentication:
    break;
  case AuthenticationType.basicAuthentication:
    need(d.user.length > 0, "basicAuthentication requires 'user'");
    need(d.password.length > 0, "basicAuthentication requires 'password'");
    break;
  case AuthenticationType.oauth2ClientCredentials, AuthenticationType.oauth2UserTokenExchange,
      AuthenticationType.oauth2AuthorizationCode:
    need(d.clientId.length > 0, auth ~ " requires 'clientId'");
    need(d.clientSecret.length > 0 || !d.certificateId.isEmpty, auth ~ " requires 'clientSecret' or a client certificate");
    break;
  case AuthenticationType.oauth2SAMLBearerAssertion, AuthenticationType.oauth2JWTBearer:
    need(d.clientId.length > 0, auth ~ " requires 'clientId'");
    break;
  case AuthenticationType.oauth2Password:
    need(d.clientId.length > 0, auth ~ " requires 'clientId'");
    need(d.user.length > 0, auth ~ " requires 'user'");
    need(d.password.length > 0, auth ~ " requires 'password'");
    break;
  case AuthenticationType.clientCertificateAuthentication:
    need(!d.certificateId.isEmpty, auth ~ " requires 'certificateId'");
    break;
  case AuthenticationType.principalPropagation:
    need(d.proxyType == ProxyType.onPremise, "principalPropagation is only supported for onPremise destinations");
    break;
  case AuthenticationType.samlAssertion:
    break;
  }

  if (needsTokenService(d.authenticationType)) {
    need(d.tokenServiceUrl.length > 0, auth ~ " requires 'tokenServiceUrl'");
    if (d.tokenServiceUrl.length > 0)
      need(d.tokenServiceUrl.startsWith("https://"), "'tokenServiceUrl' must be an https URL");
  }
  return errors;
}

/// Throw a validation exception listing every problem.
void validateAuthentication(const Destination d) {
  auto errors = authenticationErrors(d);
  validate(errors.length == 0, "Invalid authentication settings: " ~ errors.join("; "));
}

///
unittest {
  Destination d;
  d.url = "https://api.example.com";
  assert(authenticationErrors(d).length == 0);

  d.authenticationType = AuthenticationType.oauth2ClientCredentials;
  assert(authenticationErrors(d).length == 3);
  d.clientId = "cid";
  d.clientSecret = "s";
  d.tokenServiceUrl = "http://auth/token";
  assert(authenticationErrors(d) == ["'tokenServiceUrl' must be an https URL"]);
  d.tokenServiceUrl = "https://auth/token";
  assert(authenticationErrors(d).length == 0);

  d.authenticationType = AuthenticationType.principalPropagation;
  assert(authenticationErrors(d).length == 1);
  d.proxyType = ProxyType.onPremise;
  assert(authenticationErrors(d).length == 0);

  d.destinationType = DestinationType.mail;
  assert(authenticationErrors(d)[0].canFind("do not support"));
}
