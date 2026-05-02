module uim.platform.abap_environment.application.dtos.communication_arrangement;

import uim.platform.abap_environment;

mixin(ShowModule!());

@safe:
struct CreateCommunicationArrangementRequest {
  TenantId tenantId;
  SystemInstanceId systemInstanceId;
  CommunicationScenarioId scenarioId;
  string name;
  string description;
  string direction; // "inbound", "outbound"
  string authMethod; // "basicAuthentication", ...
  string communicationUser;
  string communicationPassword;
  string clientId;
  string clientSecret;
  string tokenEndpoint;
  string certificateId;
  CommunicationEndpoint[] inboundServices;
  CommunicationEndpoint[] outboundServices;

  Json toJson() const {
    return Json.emptyObject
      .set("tenantId", tenantId.value)
      .set("systemInstanceId", systemInstanceId.value)
      .set("scenarioId", scenarioId.value)
      .set("name", name)
      .set("description", description)
      .set("direction", direction)
      .set("authMethod", authMethod)
      .set("communicationUser", communicationUser)
      .set("communicationPassword", communicationPassword)
      .set("clientId", clientId)
      .set("clientSecret", clientSecret)
      .set("tokenEndpoint", tokenEndpoint)
      .set("certificateId", certificateId)
      .set("inboundServices", inboundServices.map!(s => s.toJson()).array)
      .set("outboundServices", outboundServices.map!(s => s.toJson()).array);
  }
}

struct UpdateCommunicationArrangementRequest {
  string description;
  string status; // "active", "inactive"
  string authMethod;
  string communicationUser;
  string communicationPassword;
  string clientId;
  string clientSecret;
  string tokenEndpoint;
  CommunicationEndpoint[] inboundServices;
  CommunicationEndpoint[] outboundServices;

  Json toJson() const {
    return Json.emptyObject
      .set("description", description)
      .set("status", status)
      .set("authMethod", authMethod)
      .set("communicationUser", communicationUser)
      .set("communicationPassword", communicationPassword)
      .set("clientId", clientId)
      .set("clientSecret", clientSecret)
      .set("tokenEndpoint", tokenEndpoint)
      .set("inboundServices", inboundServices.map!(s => s.toJson()).array)
      .set("outboundServices", outboundServices.map!(s => s.toJson()).array);
  }
}