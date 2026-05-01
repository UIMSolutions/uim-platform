/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.connectivity.application.usecases.manage.access_rules;

// import uim.platform.connectivity.application.dto;
// import uim.platform.connectivity.domain.entities.access_rule;
// import uim.platform.connectivity.domain.ports.repositories.access_rules;
// import uim.platform.connectivity.domain.ports.repositories.connectors;
// import uim.platform.connectivity.domain.types;
import uim.platform.connectivity;

mixin(ShowModule!());

@safe:
/// Application service for access rule CRUD.
class ManageAccessRulesUseCase { // TODO: UIMUseCase {
  private AccessRuleRepository rules;
  private ConnectorRepository connectors;

  this(AccessRuleRepository rules, ConnectorRepository connectors) {
    this.rules = rules;
    this.connectors = connectors;
  }

  CommandResult createRule(CreateAccessRuleRequest req) {
    auto tenantId = req.tenantId;
    // Validate connector exists
    if (!connectors.existsById(tenantId, req.connectorId))
      return CommandResult(false, "", "Connector not found");

    if (req.virtualHost.length == 0)
      return CommandResult(false, "", "Virtual host is required");

    AccessRule rule;
    rule.initEntity(tenantId);
    rule.connectorId = req.connectorId;
    rule.description = req.description;
    rule.protocol = req.protocol.to!AccessProtocol;
    rule.virtualHost = req.virtualHost;
    rule.virtualPort = req.virtualPort;
    rule.urlPathPrefix = req.urlPathPrefix;
    rule.policy = req.policy.toLower().to!AccessPolicy;
    rule.principalPropagation = req.principalPropagation;

    rules.save(rule);
    return CommandResult(true, rule.id.toString, "");
  }

  CommandResult updateRule(RuleId id, UpdateAccessRuleRequest req) {
    auto rule = rules.findById(id);
    if (rule.isEmpty)
      return CommandResult(false, "", "Access rule not found");

    AccessRule updated = rule;

    if (req.description.length > 0)
      updated.description = req.description;
    if (req.protocol.length > 0)
      updated.protocol = req.protocol.to!AccessProtocol;
    if (req.virtualHost.length > 0)
      updated.virtualHost = req.virtualHost;
    if (req.virtualPort != 0)
      updated.virtualPort = req.virtualPort;
    if (req.urlPathPrefix.length > 0)
      updated.urlPathPrefix = req.urlPathPrefix;
    if (req.policy.length > 0)
      updated.policy = req.policy.toLower().to!AccessPolicy;
    updated.principalPropagation = req.principalPropagation;

    rules.update(updated);
    return CommandResult(true, updated.id.toString, "");
  }

  AccessRule getRule(RuleId id) {
    return rules.findById(id);
  }

  AccessRule[] listByConnector(ConnectorId connectorId) {
    return rules.findByConnector(connectorId);
  }

  AccessRule[] listByTenant(TenantId tenantId) {
    return rules.findByTenant(tenantId);
  }

  CommandResult deleteRule(RuleId id) {
    if (!rules.existsById(id))
      return CommandResult(false, "", "Access rule not found");

    rules.remove(id);
    return CommandResult(true, id.toString, "");
  }
}
