/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.kyma.domain.entities.api_rule;

import uim.platform.kyma;

mixin(ShowModule!());

@safe:

/// An API rule (gateway.kyma-project.io APIRule): exposes a service through the
/// Istio ingress gateway with per-path access strategies.
struct ApiRule {
  mixin TenantEntity!ApiRuleId;

  KymaEnvironmentId environmentId;
  NamespaceId namespaceId;
  string namespaceName;
  string name;
  string description;
  ApiRuleStatus status = ApiRuleStatus.notReady;

  // Backend service
  string serviceName;
  int servicePort = 80;

  // Exposure
  string gateway = "kyma-system/kyma-gateway";
  string host;
  ApiRuleEntry[] rules;

  // CORS
  bool corsEnabled;
  string[] corsAllowOrigins;
  string[] corsAllowMethods;
  string[] corsAllowHeaders;

  KeyValue[] labels;

  /// Public URL of the exposed service.
  string url() const {
    return "https://" ~ host;
  }
}
