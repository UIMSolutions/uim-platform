/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.connectivity.domain.enumerations.destinations;

import uim.platform.connectivity;

mixin(ShowModule!());

@safe:

/// Protocol family of a destination.
enum DestinationType {
  http,
  rfc,
  mail,
  ldap,
  tcp,
}

/// How the connectivity service authenticates against the target.
enum AuthenticationType {
  noAuthentication,
  basicAuthentication,
  oauth2ClientCredentials,
  oauth2SAMLBearerAssertion,
  oauth2UserTokenExchange,
  oauth2JWTBearer,
  oauth2Password,
  oauth2AuthorizationCode,
  clientCertificateAuthentication,
  principalPropagation,
  samlAssertion,
}

/// How the target is reached.
enum ProxyType {
  internet, /// directly
  onPremise, /// through a Cloud Connector (cloudConnectorLocationId)
  privateLink, /// through a private endpoint
}

/// Result of the last connection check of a destination.
enum DestinationStatus {
  unchecked,
  reachable,
  unreachable, /// configuration is fine, the target or its route is not
  misconfigured, /// authentication / certificate / connector settings are incomplete
}
