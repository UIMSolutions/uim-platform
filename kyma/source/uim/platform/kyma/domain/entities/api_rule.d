/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.kyma.domain.entities.api_rule;

import uim.platform.kyma;

// mixin(ShowModule!());

@safe:
/// An API rule — exposes a service or function via the API Gateway.
struct ApiRule {
  mixin TenantEntity!ApiRuleId;

  NamespaceId namespaceId;
  KymaEnvironmentId environmentId;
  string name;
  string description;
  ApiRuleStatus status = ApiRuleStatus.notReady;

  // Service reference
  string serviceName;
  int servicePort;

  // Gateway
  string gateway;
  string host;

  // Rules (access strategies per path)
  ApiRuleEntry[] rules;

  // TLS
  bool tlsEnabled = true;
  string tlsSecretName;

  // CORS
  bool corsEnabled;
  string[] corsAllowOrigins;
  string[] corsAllowMethods;
  string[] corsAllowHeaders;

  // Labels
  string[string] labels;

  Json toJson() const {
    return entityToJson
      .set("namespaceId", namespaceId.value)
      .set("environmentId", environmentId.value)
      .set("name", name)
      .set("description", description)
      .set("status", status.toString)
      .set("serviceName", serviceName)
      .set("servicePort", servicePort)
      .set("gateway", gateway)
      .set("host", host)
      .set("rules", rules.map!(r => r.toJson()).array.toJson)
      .set("tlsEnabled", tlsEnabled)
      .set("tlsSecretName", tlsSecretName)
      .set("corsEnabled", corsEnabled)
      .set("corsAllowOrigins", corsAllowOrigins.array.toJson)
      .set("corsAllowMethods", corsAllowMethods.array.toJson)
      .set("corsAllowHeaders", corsAllowHeaders.array.toJson)
      .set("labels", labels)
      .set("trustedIssuers", rules.flatMap!(r => r.trustedIssuers).array.toJson)
      .set("tlsEnabled", tlsEnabled)
      .set("tlsSecretName", tlsSecretName)
      .set("corsEnabled", corsEnabled)
      .set("labels", labels);
  }

}
/// A single rule entry within an API rule.
struct ApiRuleEntry {
  string path;
  ApiHttpMethod[] methods;
  AccessStrategy accessStrategy = AccessStrategy.noAuth;
  string[] requiredScopes;
  string[] audiences;
  string[] trustedIssuers;

  Json toJson() const {
    return Json.emptyObject
      .set("path", path)
      .set("methods", methods.map!(m => m.toString()).array.toJson)
      .set("accessStrategy", accessStrategy.toString())
      .set("requiredScopes", requiredScopes.array.toJson)
      .set("audiences", audiences.array.toJson)
      .set("trustedIssuers", trustedIssuers.array.toJson);
  }
}
