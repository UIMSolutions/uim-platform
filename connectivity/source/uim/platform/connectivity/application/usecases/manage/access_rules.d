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
    // Validate connector exists
    if (!connectors.existsById(tenantId, req.connectorId))
      return CommandResult(false, "", "Connector not found");

    if (req.virtualHost.length == 0)
      return CommandResult(false, "", "Virtual host is required");

    AccessRule rule = AccessRule.createFromRequest(req);

    rules.save(rule);
    return CommandResult(true, rule.id.toString, "");
  }

  CommandResult updateRule(RuleId id, UpdateAccessRuleRequest req) {
    auto rule = rules.findById(id);
    if (rule.isEmpty)
      return CommandResult(false, "", "Access rule not found");

    rules.update(rule);
    return CommandResult(true, rule.id.toString, "");
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
    return CommandResult(true, rule.id.toString, "");
  }
}

