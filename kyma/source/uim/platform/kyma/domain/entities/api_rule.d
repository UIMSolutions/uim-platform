/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.kyma.domain.entities.api_rule;

// import uim.platform.kyma.domain.types;
import uim.platform.kyma;

mixin(ShowModule!());

@safe:
/// An API rule — exposes a service or function via the API Gateway.
struct ApiRule {
  mixin TenantEntity!(ApiRuleId id);
  
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
    auto j = entityToJson
      .set("namespaceId", namespaceId.value)
      .set("environmentId", environmentId.value)
      .set("name", name)
      .set("description", description)
      .set("status", status.toString)
      .set("serviceName", serviceName)
      .set("servicePort", servicePort)
      .set("gateway", gateway)
      .set("host", host)
      .set("rules", rules.map!(r => Json.init
        .set("path", r.path)
        .set("methods", r.methods.map!(m => m.toString()).array)
        .set("accessStrategy", r.accessStrategy.toString())
        .set("requiredScopes", r.requiredScopes.array)
        .set("audiences", r.audiences.array)
        .set("trustedIssuers", r.trustedIssuers.array)).array)
      .set("tlsEnabled", tlsEnabled)
      .set("tlsSecretName", tlsSecretName)
      .set("corsEnabled", corsEnabled)
      .set("corsAllowOrigins", corsAllowOrigins.array)
      .set("corsAllowMethods", corsAllowMethods.array)
      .set("corsAllowHeaders", corsAllowHeaders.array)
      .set("labels", labels);

    return j;
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
}
