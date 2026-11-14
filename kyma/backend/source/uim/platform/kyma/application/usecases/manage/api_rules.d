/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.kyma.application.usecases.manage.api_rules;

import uim.platform.kyma;

mixin(ShowModule!());

@safe:

/// Interactor: API rules. Hosts default to <name>.<cluster domain> and are unique per runtime.
class ManageApiRulesUseCase
  : ResourceUseCase!(ApiRule, ApiRuleId, CreateApiRuleRequest, UpdateApiRuleRequest),
  IManageApiRulesUseCase {
  protected ApiRuleValidator validator;

  this(KymaRepositories repos, IKymaEventPublisher publisher, IClusterGateway cluster, ApiRuleValidator validator) {
    super(repos, repos.apiRules, publisher, cluster, "API rule", "kyma.apirule");
    this.validator = validator;
  }

  override protected ApiRule build(CreateApiRuleRequest r) {
    auto ns = requireNamespace(r.tenantId, r.parentId);
    requireModule(r.tenantId, ns.environmentId, WorkloadKind.apiRule);
    auto env = requireEnvironment(r.tenantId, ns.environmentId);
    auto rule = ApiRule(r.tenantId);
    rule.environmentId = ns.environmentId;
    rule.namespaceId = ns.id;
    rule.namespaceName = ns.name;
    assignMatching(rule, r.spec);
    if (rule.host.length == 0)
      rule.host = ApiRuleValidator.defaultHost(rule.name, env.shootDomain);
    rule.status = ApiRuleStatus.notReady;
    validator.validate(rule);
    ensureState(repos.apiRules.findByName(r.tenantId, ns.id, rule.name).isNull,
      "API rule '" ~ rule.name ~ "' already exists in namespace '" ~ ns.name ~ "'");
    checkHost(rule);
    return rule;
  }

  override protected void apply(ref ApiRule rule, ApiRuleSpec spec) {
    assignMatching(rule, spec, ["name"]);
    if (rule.host.length == 0)
      rule.host = ApiRuleValidator.defaultHost(rule.name,
        repos.environments.findById(rule.tenantId, rule.environmentId).shootDomain);
    validator.validate(rule);
    checkHost(rule);
    rule.status = ApiRuleStatus.notReady;
  }

  protected void checkHost(const ref ApiRule rule) {
    auto other = repos.apiRules.findByHost(rule.tenantId, rule.environmentId, rule.host);
    ensureState(other.isNull || other.id == rule.id,
      "Host '" ~ rule.host ~ "' is already exposed by API rule '" ~ other.namespaceName ~ "/" ~ other.name ~ "'");
  }

  override protected Json render(ApiRule rule) {
    return toManifest(rule);
  }
}
