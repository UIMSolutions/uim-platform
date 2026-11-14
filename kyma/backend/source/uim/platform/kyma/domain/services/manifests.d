/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Domain service: renders aggregates as the Kubernetes custom resources Kyma
/// reconciles (Namespace, Function, APIRule, ServiceInstance, ServiceBinding,
/// Subscription, Kyma). The result can be applied with `kubectl apply -f`.
module uim.platform.kyma.domain.services.manifests;

import uim.platform.kyma;

mixin(ShowModule!());

@safe:

private Json strings(const string[] values) {
  auto arr = Json.emptyArray;
  foreach (v; values)
    arr ~= Json(v);
  return arr;
}

private Json pairs(const KeyValue[] values) {
  auto obj = Json.emptyObject;
  foreach (p; values)
    obj[p.key] = p.value;
  return obj;
}

private Json metadata(string name, string namespace_, const KeyValue[] labels) {
  auto m = Json.emptyObject;
  m["name"] = name;
  if (namespace_.length > 0)
    m["namespace"] = namespace_;
  auto l = pairs(labels);
  l["app.kubernetes.io/managed-by"] = "uim-kyma";
  m["labels"] = l;
  return m;
}

private Json resource(string apiVersion, string kind, Json meta, Json spec) {
  auto r = Json.emptyObject;
  r["apiVersion"] = apiVersion;
  r["kind"] = kind;
  r["metadata"] = meta;
  r["spec"] = spec;
  return r;
}

private Json parsedOrEmpty(string jsonText) {
  if (jsonText.strip.length == 0)
    return Json.emptyObject;
  try
    return parseJsonString(jsonText);
  catch (Exception)
    return Json.emptyObject;
}

private Json quantities(string cpu, string memory) {
  auto q = Json.emptyObject;
  if (cpu.length)
    q["cpu"] = cpu;
  if (memory.length)
    q["memory"] = memory;
  return q;
}

Json toManifest(const KymaNamespace ns) {
  auto labels = ns.labels.dup;
  labels ~= KeyValue("istio-injection", ns.istioInjection ? "enabled" : "disabled");
  auto meta = metadata(ns.name, "", labels);
  meta["annotations"] = pairs(ns.annotations);
  auto r = Json.emptyObject;
  r["apiVersion"] = "v1";
  r["kind"] = "Namespace";
  r["metadata"] = meta;
  return r;
}

Json toManifest(const ServerlessFunction fn) {
  auto spec = Json.emptyObject;
  spec["runtime"] = enumText(fn.runtime);
  auto inline = Json.emptyObject;
  inline["source"] = fn.sourceCode;
  if (fn.dependencies.length)
    inline["dependencies"] = fn.dependencies;
  auto source = Json.emptyObject;
  source["inline"] = inline;
  spec["source"] = source;

  auto env = Json.emptyArray;
  foreach (e; fn.envVars) {
    auto v = Json.emptyObject;
    v["name"] = e.key;
    v["value"] = e.value;
    env ~= v;
  }
  auto handlerVar = Json.emptyObject;
  handlerVar["name"] = "FUNC_HANDLER";
  handlerVar["value"] = fn.handler;
  env ~= handlerVar;
  auto timeoutVar = Json.emptyObject;
  timeoutVar["name"] = "FUNC_TIMEOUT";
  timeoutVar["value"] = fn.timeoutSeconds.to!string;
  env ~= timeoutVar;
  spec["env"] = env;

  auto resources = Json.emptyObject;
  resources["requests"] = quantities(fn.cpuRequest, fn.memoryRequest);
  resources["limits"] = quantities(fn.cpuLimit, fn.memoryLimit);
  auto functionResources = Json.emptyObject;
  functionResources["resources"] = resources;
  spec["resourceConfiguration"] = Json.emptyObject;
  spec["resourceConfiguration"]["function"] = functionResources;

  if (fn.scalingType == ScalingType.fixed) {
    spec["replicas"] = fn.minReplicas;
  } else {
    auto scale = Json.emptyObject;
    scale["minReplicas"] = fn.minReplicas;
    scale["maxReplicas"] = fn.maxReplicas;
    spec["scaleConfig"] = scale;
  }
  return resource("serverless.kyma-project.io/v1alpha2", "Function",
    metadata(fn.name, fn.namespaceName, fn.labels), spec);
}

Json toManifest(const ApiRule rule) {
  auto spec = Json.emptyObject;
  spec["hosts"] = strings([rule.host]);
  spec["gateway"] = rule.gateway;
  auto service = Json.emptyObject;
  service["name"] = rule.serviceName;
  service["port"] = rule.servicePort;
  spec["service"] = service;

  auto rules = Json.emptyArray;
  foreach (r; rule.rules) {
    auto j = Json.emptyObject;
    j["path"] = r.path;
    string[] methods;
    foreach (m; r.methods)
      methods ~= enumText(m);
    j["methods"] = strings(methods);
    final switch (r.accessStrategy) {
    case AccessStrategy.noAuth:
      j["noAuth"] = true;
      break;
    case AccessStrategy.jwt:
      auto auth = Json.emptyArray;
      foreach (issuer; r.trustedIssuers) {
        auto a = Json.emptyObject;
        a["issuer"] = issuer;
        a["jwksUri"] = issuer.stripRight("/") ~ "/token_keys";
        auth ~= a;
      }
      auto jwt = Json.emptyObject;
      jwt["authentications"] = auth;
      if (r.requiredScopes.length) {
        auto authz = Json.emptyObject;
        authz["requiredScopes"] = strings(r.requiredScopes);
        if (r.audiences.length)
          authz["audiences"] = strings(r.audiences);
        auto list = Json.emptyArray;
        list ~= authz;
        jwt["authorizations"] = list;
      }
      j["jwt"] = jwt;
      break;
    case AccessStrategy.oauth2Introspection, AccessStrategy.extAuth:
      auto ext = Json.emptyObject;
      ext["authorizers"] = strings(["oauth2-proxy"]);
      j["extAuth"] = ext;
      break;
    }
    rules ~= j;
  }
  spec["rules"] = rules;

  if (rule.corsEnabled) {
    auto cors = Json.emptyObject;
    cors["allowOrigins"] = strings(rule.corsAllowOrigins);
    cors["allowMethods"] = strings(rule.corsAllowMethods);
    cors["allowHeaders"] = strings(rule.corsAllowHeaders);
    spec["corsPolicy"] = cors;
  }
  return resource("gateway.kyma-project.io/v2", "APIRule",
    metadata(rule.name, rule.namespaceName, rule.labels), spec);
}

Json toManifest(const ServiceInstance si) {
  auto spec = Json.emptyObject;
  spec["serviceOfferingName"] = si.serviceOfferingName;
  spec["servicePlanName"] = si.servicePlanName;
  if (si.externalName.length)
    spec["externalName"] = si.externalName;
  spec["parameters"] = parsedOrEmpty(si.parametersJson);
  return resource("services.cloud.sap.com/v1", "ServiceInstance",
    metadata(si.name, si.namespaceName, si.labels), spec);
}

Json toManifest(const ServiceBinding sb) {
  auto spec = Json.emptyObject;
  spec["serviceInstanceName"] = sb.serviceInstanceName;
  spec["secretName"] = sb.secretName;
  spec["parameters"] = parsedOrEmpty(sb.parametersJson);
  return resource("services.cloud.sap.com/v1", "ServiceBinding",
    metadata(sb.name, sb.namespaceName, sb.labels), spec);
}

Json toManifest(const EventSubscription sub) {
  auto spec = Json.emptyObject;
  spec["source"] = sub.source;
  spec["types"] = strings(sub.eventTypes);
  spec["typeMatching"] = enumText(sub.typeEncoding) == "exact" ? "exact" : "standard";
  spec["sink"] = sub.sinkUrl;
  auto config = Json.emptyObject;
  config["maxInFlightMessages"] = sub.maxInFlightMessages.to!string;
  spec["config"] = config;
  if (sub.filterAttributes.length)
    spec["filter"] = pairs(sub.filterAttributes);
  return resource("eventing.kyma-project.io/v1alpha2", "Subscription",
    metadata(sub.name, sub.namespaceName, sub.labels), spec);
}

/// The Kyma CR of an environment, listing its modules.
Json toManifest(const KymaEnvironment env, const KymaModule[] modules) {
  auto spec = Json.emptyObject;
  spec["channel"] = "regular";
  auto list = Json.emptyArray;
  foreach (m; modules) {
    if (!m.status.isActive)
      continue;
    auto j = Json.emptyObject;
    j["name"] = m.name;
    j["channel"] = enumText(m.channel);
    j["customResourcePolicy"] = m.customResourcePolicy;
    list ~= j;
  }
  spec["modules"] = list;
  return resource("operator.kyma-project.io/v1beta2", "Kyma",
    metadata(env.name, "kyma-system", null), spec);
}

///
unittest {
  auto fn = ServerlessFunction(TenantId("t"));
  fn.name = "hello";
  fn.namespaceName = "shop";
  fn.sourceCode = "x";
  auto m = toManifest(fn);
  assert(m["kind"].get!string == "Function");
  assert(m["metadata"]["namespace"].get!string == "shop");
  assert(m["spec"]["scaleConfig"]["maxReplicas"].get!long == 5);

  auto rule = ApiRule(TenantId("t"));
  rule.name = "r";
  rule.host = "r.example.com";
  rule.rules = [ApiRuleEntry("/*", [ApiHttpMethod.get_], AccessStrategy.noAuth)];
  assert(toManifest(rule)["spec"]["rules"][0]["noAuth"].get!bool);
}
