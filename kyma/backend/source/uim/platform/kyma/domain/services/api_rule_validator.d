/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.kyma.domain.services.api_rule_validator;

import uim.platform.kyma;

mixin(ShowModule!());

@safe:

/// Domain service: rules for API rules (APIRule v2).
class ApiRuleValidator {
  void validate(const ref ApiRule rule) {
    import uim.platform.kyma.domain.exceptions.kyma : check = validate;

    validateResourceName("API rule", rule.name);
    check(rule.serviceName.length > 0, "API rule needs a backend service name");
    check(isDnsLabel(rule.serviceName), "Service name '" ~ rule.serviceName ~ "' is not a valid DNS-1123 label");
    check(rule.servicePort >= 1 && rule.servicePort <= 65_535, "Service port must be between 1 and 65535");
    check(rule.host.length > 0, "API rule host is required");
    check(isDnsName(rule.host), "Host '" ~ rule.host ~ "' is not a valid DNS name");
    check(rule.rules.length > 0, "API rule needs at least one access rule");
    foreach (r; rule.rules) {
      check(r.path.startsWith("/"), "Rule path '" ~ r.path ~ "' must start with '/'");
      check(r.methods.length > 0, "Rule for '" ~ r.path ~ "' must allow at least one HTTP method");
      if (r.accessStrategy == AccessStrategy.jwt)
        check(r.trustedIssuers.length > 0, "JWT rule for '" ~ r.path ~ "' needs at least one trusted issuer");
      foreach (issuer; r.trustedIssuers)
        check(issuer.startsWith("https://"), "Trusted issuer '" ~ issuer ~ "' must use https");
    }
    check(!rule.corsEnabled || rule.corsAllowOrigins.length > 0, "CORS is enabled but no allowed origins are set");
  }

  /// Default host of an API rule: <name>.<cluster domain>.
  static string defaultHost(string ruleName, string shootDomain) {
    return ruleName ~ "." ~ shootDomain;
  }
}

///
unittest {
  auto rule = ApiRule(TenantId("t"));
  rule.name = "orders";
  rule.serviceName = "orders";
  rule.host = ApiRuleValidator.defaultHost("orders", "c-1.kyma.ondemand.com");
  rule.rules = [ApiRuleEntry("/*", [ApiHttpMethod.get_], AccessStrategy.noAuth)];
  new ApiRuleValidator().validate(rule);

  rule.rules[0].accessStrategy = AccessStrategy.jwt;
  bool failed;
  try new ApiRuleValidator().validate(rule);
  catch (KymaValidationException) failed = true;
  assert(failed);
}
