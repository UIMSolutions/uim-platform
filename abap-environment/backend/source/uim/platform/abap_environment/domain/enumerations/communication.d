/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.abap_environment.domain.enumerations.communication;

import uim.platform.abap_environment;

mixin(ShowModule!());

@safe:

/// Direction of a communication arrangement.
enum CommunicationDirection {
  inbound,
  outbound,
  both,
}

/// Protocol of a communication endpoint.
enum CommunicationProtocol {
  httpRest,
  httpSoap,
  rfc,
  odataV2,
  odataV4,
}

/// Authentication of a communication arrangement.
enum CommunicationAuthMethod {
  basicAuthentication,
  oauth2ClientCredentials,
  oauth2SamlBearerAssertion,
  clientCertificate,
  noAuthentication,
}

/// Status of a communication arrangement.
enum ArrangementStatus {
  active,
  inactive,
  error,
}
