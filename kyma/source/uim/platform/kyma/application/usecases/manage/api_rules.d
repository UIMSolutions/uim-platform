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
class ManageApiRulesUseCase { // TODO: UIMUseCase {
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

    if (ruleRepository.existsByName(req.namespaceId, req.name))
      return CommandResult(false, "", "API rule '" ~ req.name ~ "' already exists");

    ApiRule rule;
    with (rule) {
      id = randomUUID();
      namespaceId = req.namespaceId;
      environmentId = req.environmentId;
      tenantId = req.tenantId;
      name = req.name;
      description = req.description;
      status = ApiRuleStatus.notReady;
      serviceName = req.serviceName;
      servicePort = req.servicePort > 0 ? req.servicePort : 80;
      gateway = req.gateway.length > 0 ? req.gateway : "kyma-gateway.kyma-system.svc.cluster.local";
      host = req.host;
      tlsEnabled = req.tlsEnabled;
      tlsSecretName = req.tlsSecretName;
      corsEnabled = req.corsEnabled;
      corsAllowOrigins = req.corsAllowOrigins;
      corsAllowMethods = req.corsAllowMethods;
      corsAllowHeaders = req.corsAllowHeaders;
      labels = req.labels;
      createdBy = req.createdBy;
      createdAt = clockSeconds();
      modifiedAt = createdAt;
    }

    // Convert rule entry DTOs
    ApiRuleEntry[] entries;
    foreach (r; req.rules) {
      ApiRuleEntry entry;
      entry.path = r.path;
      entry.accessStrategy = parseAccessStrategy(r.accessStrategy);
      entry.requiredScopes = r.requiredScopes;
      entry.audiences = r.audiences;
      entry.trustedIssuers = r.trustedIssuers;

      ApiHttpMethod[] methods = r.methods.map!(m => parseHttpMethod(m)).array;
      entry.methods = methods;
      entries ~= entry;
    }
    rule.rules = entries;

    ruleRepository.save(rule);
    return CommandResult(true, rule.id.toString, "");
  }

  CommandResult updateApiRule(string id, UpdateApiRuleRequest req) {
    return updateApiRule(ApiRuleId(id), req);
  }

  CommandResult updateApiRule(ApiRuleId id, UpdateApiRuleRequest req) {
    if (!ruleRepository.existsById(id))
      return CommandResult(false, "", "API rule not found");

    auto rule = ruleRepository.findById(id);
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
      foreach (r; req.rules) {
        ApiRuleEntry entry;
        with (entry) {
          path = r.path;
          accessStrategy = parseAccessStrategy(r.accessStrategy);
          requiredScopes = r.requiredScopes;
          audiences = r.audiences;
          trustedIssuers = r.trustedIssuers;
          methods = r.methods.map!(m => parseHttpMethod(m)).array;
        }
        entries ~= entry;
      }
      rule.rules = entries;
    }
    rule.modifiedAt = clockSeconds();

    ruleRepository.update(rule);
    return CommandResult(true, id.toString, "");
  }

  bool hasApiRule(string id) {
    return hasApiRule(ApiRuleId(id));
  }

  bool hasApiRule(ApiRuleId id) {
    return ruleRepository.existsById(id);
  }

  ApiRule getApiRule(string id) {
    return getApiRule(ApiRuleId(id));
  }

  ApiRule getApiRule(ApiRuleId id) {
    return ruleRepository.findById(id);
  }

  ApiRule[] listByNamespace(string nsId) {
    return listByNamespace(NamespaceId(nsId));
  }

  ApiRule[] listByNamespace(NamespaceId nsId) {
    return ruleRepository.findByNamespace(nsId);
  }

  ApiRule[] listByEnvironment(string envId) {
    return listByEnvironment(KymaEnvironmentId(envId));
  }

  ApiRule[] listByEnvironment(KymaEnvironmentId envId) {
    return ruleRepository.findByEnvironment(envId);
  }

  CommandResult deleteApiRule(string id) {
    return deleteApiRule(ApiRuleId(id));
  }

  CommandResult deleteApiRule(ApiRuleId id) {
    if (!ruleRepository.existsById(id))
      return CommandResult(false, "", "API rule not found");

    auto rule = ruleRepository.findById(id);
    ruleRepository.remove(id);
    return CommandResult(true, rule.id.toString(), "");
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
