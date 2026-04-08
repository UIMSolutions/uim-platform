/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.kyma.application.usecases.manage.api_rules;

// import uim.platform.kyma.application.dto;
// import uim.platform.kyma.domain.entities.api_rule;
// import uim.platform.kyma.domain.ports.repositories.api_rules;
// import uim.platform.kyma.domain.types;
import uim.platform.kyma;

mixin(ShowModule!());

@safe:
/// Application service for API rule management.
class ManageApiRulesUseCase : UIMUseCase {
  private ApiRuleRepository ruleRepository;

  this(ApiRuleRepository ruleRepository) {
    this.ruleRepository = ruleRepository;
  }

  CommandResult create(CreateApiRuleRequest req) {
    if (req.name.length == 0)
      return CommandResult(false, "", "API rule name is required");
    if (req.serviceName.length == 0)
      return CommandResult(false, "", "Service name is required");
    if (req.host.length == 0)
      return CommandResult(false, "", "Host is required");

    auto existing = ruleRepository.findByName(req.namespaceId, req.name);
    if (existing.ruleId.isEmpty)
      return CommandResult(false, "", "API rule '" ~ req.name ~ "' already exists");

    // import std.uuid : randomUUID;

    auto id = randomUUID().toString();

    ApiRule rule;
    rule.ruleId = id;
    rule.namespaceId = req.namespaceId;
    rule.environmentId = req.environmentId;
    rule.tenantId = req.tenantId;
    rule.name = req.name;
    rule.description = req.description;
    rule.status = ApiRuleStatus.notReady;
    rule.serviceName = req.serviceName;
    rule.servicePort = req.servicePort > 0 ? req.servicePort : 80;
    rule.gateway = req.gateway.length > 0 ? req.gateway
      : "kyma-gateway.kyma-system.svc.cluster.local";
    rule.host = req.host;
    rule.tlsEnabled = req.tlsEnabled;
    rule.tlsSecretName = req.tlsSecretName;
    rule.corsEnabled = req.corsEnabled;
    rule.corsAllowOrigins = req.corsAllowOrigins;
    rule.corsAllowMethods = req.corsAllowMethods;
    rule.corsAllowHeaders = req.corsAllowHeaders;
    rule.labels = req.labels;
    rule.createdBy = req.createdBy;
    rule.createdAt = clockSeconds();
    rule.modifiedAt = rule.createdAt;

    // Convert rule entry DTOs
    ApiRuleEntry[] entries;
    foreach (ref r; req.rules) {
      ApiRuleEntry entry;
      entry.path = r.path;
      entry.accessStrategy = parseAccessStrategy(r.accessStrategy);
      entry.requiredScopes = r.requiredScopes;
      entry.audiences = r.audiences;
      entry.trustedIssuers = r.trustedIssuers;

      ApiHttpMethod[] methods;
      foreach (m; r.methods)
        methods ~= parseHttpMethod(m);
      entry.methods = methods;
      entries ~= entry;
    }
    rule.rules = entries;

    ruleRepository.save(rule);
    return CommandResult(true, id, "");
  }

  CommandResult updateApiRule(ApiRuleId id, UpdateApiRuleRequest req) {
    auto rule = ruleRepository.findById(id);
    if (rule.ruleId.isEmpty)
      return CommandResult(false, "", "API rule not found");

    if (req.description.length > 0)
      rule.description = req.description;
    if (req.serviceName.length > 0)
      rule.serviceName = req.serviceName;
    if (req.servicePort > 0)
      rule.servicePort = req.servicePort;
    if (req.host.length > 0)
      rule.host = req.host;
    rule.tlsEnabled = req.tlsEnabled;
    if (req.tlsSecretName.length > 0)
      rule.tlsSecretName = req.tlsSecretName;
    rule.corsEnabled = req.corsEnabled;
    if (req.corsAllowOrigins.length > 0)
      rule.corsAllowOrigins = req.corsAllowOrigins;
    if (req.corsAllowMethods.length > 0)
      rule.corsAllowMethods = req.corsAllowMethods;
    if (req.corsAllowHeaders.length > 0)
      rule.corsAllowHeaders = req.corsAllowHeaders;
    if (req.labels !is null)
      rule.labels = req.labels;

    if (req.rules.length > 0) {
      ApiRuleEntry[] entries;
      foreach (ref r; req.rules) {
        ApiRuleEntry entry;
        entry.path = r.path;
        entry.accessStrategy = parseAccessStrategy(r.accessStrategy);
        entry.requiredScopes = r.requiredScopes;
        entry.audiences = r.audiences;
        entry.trustedIssuers = r.trustedIssuers;
        ApiHttpMethod[] methods;
        foreach (m; r.methods)
          methods ~= parseHttpMethod(m);
        entry.methods = methods;
        entries ~= entry;
      }
      rule.rules = entries;
    }
    rule.modifiedAt = clockSeconds();

    ruleRepository.update(rule);
    return CommandResult(true, id.toString, "");
  }

  ApiRule getApiRule(ApiRuleId id) {
    return ruleRepository.findById(id);
  }

  ApiRule[] listByNamespace(NamespaceId nsId) {
    return ruleRepository.findByNamespace(nsId);
  }

  ApiRule[] listByEnvironment(KymaEnvironmentId envId) {
    return ruleRepository.findByEnvironment(envId);
  }

  CommandResult deleteApiRule(ApiRuleId id) {
    if (!ruleRepository.existsById(id))
      return CommandResult(false, "", "API rule not found");

    auto rule = ruleRepository.findById(id);
    ruleRepository.remove(id);
    return CommandResult(true, id.toString(), "");
  }

  private AccessStrategy parseAccessStrategy(string strategyName) {
    switch (strategyName.toLower()) {
    case "noAuth":
      return AccessStrategy.noAuth;
    case "oauth2_introspection":
      return AccessStrategy.oauth2Introspection;
    case "jwt":
      return AccessStrategy.jwt;
    case "allow":
      return AccessStrategy.allowAll;
    default:
      return AccessStrategy.noAuth;
    }
  }

  private ApiHttpMethod parseHttpMethod(string method) {
    switch (method.toUpper()) {
    case "GET":
      return ApiHttpMethod.get_;
    case "POST":
      return ApiHttpMethod.post_;
    case "PUT":
      return ApiHttpMethod.put_;
    case "PATCH":
      return ApiHttpMethod.patch_;
    case "DELETE":
      return ApiHttpMethod.delete_;
    case "HEAD":
      return ApiHttpMethod.head_;
    case "OPTIONS":
      return ApiHttpMethod.options_;
    default:
      return ApiHttpMethod.get_;
    }
  }
}


