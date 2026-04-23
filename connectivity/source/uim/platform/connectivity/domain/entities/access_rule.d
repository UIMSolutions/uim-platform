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

  AccessRule createFromRequest(CreateAccessRuleRequest req) {
    AccessRule rule;
    rule.id = randomUUID();
    rule.connectorId = req.connectorId;
    rule.tenantId = req.tenantId;
    rule.description = req.description;
    rule.protocol = parseAccessProtocol(req.protocol);
    rule.virtualHost = req.virtualHost;
    rule.virtualPort = req.virtualPort;
    rule.urlPathPrefix = req.urlPathPrefix;
    rule.policy = req.policy.toLower().to!AccessPolicy;
    rule.principalPropagation = req.principalPropagation;
    return rule;
  }

  AccessRule updateFromRequest(UpdateAccessRuleRequest req) {
    AccessRule updated = this;
    if (req.description.length > 0)
      updated.description = req.description;
    if (req.protocol.length > 0)
      updated.protocol = parseAccessProtocol(req.protocol);
    if (req.virtualHost.length > 0)
      updated.virtualHost = req.virtualHost;
    if (req.virtualPort != 0)
      updated.virtualPort = req.virtualPort;
    if (req.urlPathPrefix.length > 0)
      updated.urlPathPrefix = req.urlPathPrefix;
    if (req.policy.length > 0)
      updated.policy = req.policy.toLower().to!AccessPolicy;
    updated.principalPropagation = req.principalPropagation;

    return updated;
  }
}
