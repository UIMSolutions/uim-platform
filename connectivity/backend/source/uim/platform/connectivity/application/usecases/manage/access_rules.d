/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.connectivity.application.usecases.manage.access_rules;

import uim.platform.connectivity;

mixin(ShowModule!());

@safe:

/// Interactor: access control rules of a Cloud Connector.
class ManageAccessRulesUseCase
  : ResourceUseCase!(AccessRule, AccessRuleId, CreateAccessRuleRequest, UpdateAccessRuleRequest),
  IManageAccessRulesUseCase {

  this(ConnectivityRepositories repos, EventRecorder events) {
    super(repos, repos.accessRules, events, "Access rule", "connectivity.access-rule");
  }

  override protected AccessRule build(CreateAccessRuleRequest r) {
    auto connector = requireConnector(r.tenantId, r.parentId);
    auto rule = AccessRule(r.tenantId);
    rule.connectorId = connector.id;
    rule.connectorName = connector.name;
    assignMatching(rule, r.spec);
    check(rule);
    return rule;
  }

  override protected void apply(ref AccessRule rule, AccessRuleSpec spec) {
    assignMatching(rule, spec);
    check(rule);
  }

  protected void check(ref AccessRule rule) {
    rule.virtualHost = rule.virtualHost.strip.toLower;
    rule.internalHost = rule.internalHost.strip;
    rule.urlPathPrefix = rule.protocol.hasPaths ? normalizePath(rule.urlPathPrefix) : "/";
    rule.name = rule.name.strip.length > 0 ? rule.name.strip : ruleNameOf(rule);
    validateDisplayName("Access rule", rule.name);
    validateHost("Virtual host", rule.virtualHost);
    validatePort("Virtual port", rule.virtualPort);
    if (rule.internalHost.length > 0)
      validateHost("Internal host", rule.internalHost);
    if (rule.internalPort != 0)
      validatePort("Internal port", rule.internalPort);
    ensureUnique(repos.accessRules.findByName(rule.tenantId, rule.connectorId, rule.name), rule,
      "Cloud Connector '" ~ rule.connectorName ~ "'");
    foreach (other; repos.accessRules.findByConnector(rule.tenantId, rule.connectorId))
      ensureState(other.id == rule.id || other.protocol != rule.protocol || other.virtualHost != rule.virtualHost
          || other.virtualPort != rule.virtualPort || other.urlPathPrefix != rule.urlPathPrefix
          || other.includeSubPaths != rule.includeSubPaths,
        "Access rule '" ~ other.name ~ "' already covers the same resource");
  }

  UsecaseResult enable(TenantId tenantId, AccessRuleId id, UserId actor) {
    return transition(tenantId, id, actor, "enabled", (ref AccessRule rule) {
      ensureState(!rule.enabled, "Access rule '" ~ rule.name ~ "' is already enabled");
      rule.enabled = true;
    });
  }

  UsecaseResult disable(TenantId tenantId, AccessRuleId id, UserId actor) {
    return transition(tenantId, id, actor, "disabled", (ref AccessRule rule) {
      ensureState(rule.enabled, "Access rule '" ~ rule.name ~ "' is already disabled");
      rule.enabled = false;
    });
  }

  AccessCheckResult checkAccess(AccessCheckRequest r) {
    AccessCheckResult result;
    auto connector = repos.connectors.findById(r.tenantId, ConnectorId(r.connector));
    if (connector.isNull)
      connector = repos.connectors.findByName(r.tenantId, r.connector);
    if (connector.isNull) {
      result.reason = "Cloud Connector '" ~ r.connector ~ "' not found";
      return result;
    }
    result.connectorId = connector.id.value;
    result.connectorName = connector.name;

    auto e = parseEndpoint(r.url);
    if (e.isNull) {
      result.reason = "'" ~ r.url ~ "' is not a valid URL (scheme://host[:port][/path])";
      return result;
    }
    auto protocol = accessProtocolOf(e.scheme);
    result.protocol = enumText(protocol);
    result.virtualHost = e.host;
    result.virtualPort = e.port;
    result.path = protocol.hasPaths ? normalizePath(e.path) : "";

    if (connector.status != ConnectorStatus.connected) {
      result.reason = "Cloud Connector '" ~ connector.name ~ "' is " ~ enumText(connector.status);
    } else {
      auto d = evaluateAccess(repos.accessRules.findByConnector(r.tenantId, connector.id), protocol, e.host, e.port, e.path);
      result.allowed = d.allowed;
      result.ruleId = d.ruleId.value;
      result.ruleName = d.ruleName;
      result.internalHost = d.internalHost;
      result.internalPort = d.internalPort;
      result.principalPropagation = d.principalPropagation;
      result.reason = d.reason;
    }
    events.log(r.tenantId, result.allowed ? ConnectivityEventType.accessGranted : ConnectivityEventType.accessDenied,
      SourceType.cloudConnector, connector.id.value, connector.name, "Access check " ~ r.url ~ ": " ~ result.reason,
      e.host, e.port, r.actor);
    return result;
  }
}
