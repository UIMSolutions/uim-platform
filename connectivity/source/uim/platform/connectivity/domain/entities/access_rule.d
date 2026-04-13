/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.connectivity.domain.entities.access_rule;

// import uim.platform.connectivity.domain.types;
import uim.platform.connectivity;

mixin(ShowModule!());

@safe:

/// Access control rule for exposed on-premise backend resources.
struct AccessRule {
  RuleId id;
  ConnectorId connectorId;
  TenantId tenantId;
  string description;
  AccessProtocol protocol = AccessProtocol.https;
  string virtualHost;
  ushort virtualPort;
  string urlPathPrefix; // e.g., "/sap/opu/odata"
  AccessPolicy policy = AccessPolicy.allow;
  bool principalPropagation; // allow user context forwarding
  long createdAt;
  long updatedAt;
}
