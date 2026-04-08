/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.connectivity.application.usecases.manage.manage.access_rules;

// import uim.platform.connectivity.application.dto;
// import uim.platform.connectivity.domain.entities.access_rule;
// import uim.platform.connectivity.domain.ports.repositories.access_rules;
// import uim.platform.connectivity.domain.ports.repositories.connectors;
// import uim.platform.connectivity.domain.types;
import uim.platform.connectivity;

mixin(ShowModule!());

@safe:
/// Application service for access rule CRUD.
class ManageAccessRulesUseCase : UIMUseCase {
  private AccessRuleRepository ruleRepo;
  private ConnectorRepository connectorRepo;

  this(AccessRuleRepository ruleRepo, ConnectorRepository connectorRepo) {
    this.ruleRepo = ruleRepo;
    this.connectorRepo = connectorRepo;
  }

  CommandResult createRule(CreateAccessRuleRequest req) {
    // Validate connector exists
    auto cc = connectorRepo.findById(req.connectorId);
    if (cc.id.isEmpty)
      return CommandResult(false, "", "Connector not found");

    if (req.virtualHost.length == 0)
      return CommandResult(false, "", "Virtual host is required");

    // import std.uuid : randomUUID;

    auto id = randomUUID().toString();

    AccessRule rule;
    rule.id = id;
    rule.connectorId = req.connectorId;
    rule.tenantId = req.tenantId;
    rule.description = req.description;
    rule.protocol = parseAccessProtocol(req.protocol);
    rule.virtualHost = req.virtualHost;
    rule.virtualPort = req.virtualPort;
    rule.urlPathPrefix = req.urlPathPrefix;
    rule.policy = parseAccessPolicy(req.policy);
    rule.principalPropagation = req.principalPropagation;

    ruleRepo.save(rule);
    return CommandResult(true, id, "");
  }

  CommandResult updateRule(RuleId id, UpdateAccessRuleRequest req) {
    auto rule = ruleRepo.findById(id);
    if (rule.id.isEmpty)
      return CommandResult(false, "", "Access rule not found");

    if (req.description.length > 0)
      rule.description = req.description;
    if (req.urlPathPrefix.length > 0)
      rule.urlPathPrefix = req.urlPathPrefix;
    if (req.policy.length > 0)
      rule.policy = parseAccessPolicy(req.policy);
    rule.principalPropagation = req.principalPropagation;

    ruleRepo.update(rule);
    return CommandResult(true, id, "");
  }

  AccessRule getRule(RuleId id) {
    return ruleRepo.findById(id);
  }

  AccessRule[] listByConnector(ConnectorId connectorId) {
    return ruleRepo.findByConnector(connectorId);
  }

  AccessRule[] listByTenant(TenantId tenantId) {
    return ruleRepo.findByTenant(tenantId);
  }

  CommandResult deleteRule(RuleId id) {
    auto rule = ruleRepo.findById(id);
    if (rule.id.isEmpty)
      return CommandResult(false, "", "Access rule not found");

    ruleRepo.remove(id);
    return CommandResult(true, id, "");
  }
}

private AccessProtocol parseAccessProtocol(string s) {
  switch (s) {
  case "http":
    return AccessProtocol.http;
  case "https":
    return AccessProtocol.https;
  case "rfc":
    return AccessProtocol.rfc;
  case "tcp":
    return AccessProtocol.tcp;
  case "ldap":
    return AccessProtocol.ldap;
  default:
    return AccessProtocol.https;
  }
}

private AccessPolicy parseAccessPolicy(string s) {
  switch (s) {
  case "allow":
    return AccessPolicy.allow;
  case "deny":
    return AccessPolicy.deny;
  default:
    return AccessPolicy.allow;
  }
}
