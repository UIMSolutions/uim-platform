/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.abap_environment.domain.entities.communication_arrangement;

import uim.platform.abap_environment;

mixin(ShowModule!());

@safe:

/// A communication arrangement: scenario + communication system + credentials.
/// `communicationPassword` and `clientSecret` are secrets — adapters mask them.
struct CommunicationArrangement {
  mixin TenantEntity!CommunicationArrangementId;

  SystemInstanceId systemInstanceId;
  string systemName;
  string name;
  string description;
  CommunicationScenarioId scenarioId; /// e.g. "SAP_COM_0510"
  CommunicationDirection direction = CommunicationDirection.inbound;
  ArrangementStatus status = ArrangementStatus.active;
  string communicationSystem; /// host of the partner system

  // Authentication
  CommunicationAuthMethod authMethod = CommunicationAuthMethod.basicAuthentication;
  string communicationUser;
  string communicationPassword;
  string clientId;
  string clientSecret;
  string tokenEndpoint;
  string certificateId;

  CommunicationEndpoint[] inboundServices;
  CommunicationEndpoint[] outboundServices;
}
