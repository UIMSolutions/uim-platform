/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.abap_environment.domain.entities.communication_arrangement;

// import uim.platform.abap_environment.domain.types;
import uim.platform.abap_environment;

mixin(ShowModule!());

@safe:
/// Inbound/outbound communication endpoint configuration.
struct CommunicationEndpoint {
  string url;
  CommunicationProtocol protocol = CommunicationProtocol.httpRest;
  ushort port;
  bool active = true;

  Json toJson() const {
    return Json.emptyObject
      .set("url", url)
      .set("protocol", protocol.to!string)
      .set("port", port)
      .set("active", active);
  }
}

/// Communication arrangement linking scenario, system, and credentials.
struct CommunicationArrangement {
  mixin TenantEntity!(CommunicationArrangementId);
  SystemInstanceId systemInstanceId;
  CommunicationScenarioId scenarioId;
  string name;
  string description;

  CommunicationDirection direction = CommunicationDirection.inbound;
  ArrangementStatus status = ArrangementStatus.active;

  /// Authentication
  CommunicationAuthMethod authMethod = CommunicationAuthMethod.basicAuthentication;
  string communicationUser;
  string communicationPassword;
  string clientId;
  string clientSecret;
  string tokenEndpoint;
  string certificateId;

  /// Endpoints
  CommunicationEndpoint[] inboundServices;
  CommunicationEndpoint[] outboundServices;

  Json toJson() const {
    auto j = entityToJson
      .set("systemInstanceId", systemInstanceId)
      .set("scenarioId", scenarioId)
      .set("name", name)
      .set("description", description)
      .set("direction", direction.to!string)
      .set("status", status.to!string)
      .set("authMethod", authMethod.to!string);

    if (inboundServices.length > 0) {
      auto services = inboundServices.map!(e => e.toJson).array.toJson;
      j = j.set("inboundServices", services);
    }

    if (outboundServices.length > 0) {
      auto services = outboundServices.map!(e => e.toJson).array.toJson;
      j = j.set("outboundServices", services);
    }

    return j;
  }
}
