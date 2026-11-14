/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.kyma.domain.services.function_validator;

import uim.platform.kyma;

mixin(ShowModule!());

@safe:

/// Domain service: rules for serverless functions.
class FunctionValidator {
  /// Throws KymaValidationException if the function cannot be deployed.
  void validate(const ref ServerlessFunction fn) {
    import uim.platform.kyma.domain.exceptions.kyma : check = validate;

    validateResourceName("Function", fn.name);
    check(fn.sourceCode.strip.length > 0, "Function source code must not be empty");
    check(fn.handler.length > 0, "Function handler must be specified");
    check(fn.minReplicas >= 0, "minReplicas must not be negative");
    check(fn.maxReplicas >= 1, "maxReplicas must be at least 1");
    check(fn.maxReplicas >= fn.minReplicas, "maxReplicas must be >= minReplicas");
    check(fn.scalingType == ScalingType.auto_ || fn.minReplicas == fn.maxReplicas,
      "Fixed scaling requires minReplicas == maxReplicas");
    check(fn.timeoutSeconds > 0 && fn.timeoutSeconds <= 900, "Timeout must be between 1 and 900 seconds");
    foreach (e; fn.envVars)
      check(isEnvVarName(e.key), "Invalid environment variable name '" ~ e.key ~ "'");
    validateResources("Function", fn.cpuRequest, fn.cpuLimit, fn.memoryRequest, fn.memoryLimit);
    check(fn.dependencies.length == 0 || dependenciesMatchRuntime(fn),
      fn.runtime == FunctionRuntime.python312
        ? "Python dependencies must be a requirements.txt (not JSON)"
        : "Node.js dependencies must be a package.json document");
  }

  /// C identifier style: letters, digits, "_", not starting with a digit.
  static bool isEnvVarName(string s) pure nothrow {
    if (s.length == 0 || (s[0] >= '0' && s[0] <= '9'))
      return false;
    foreach (c; s)
      if (!((c >= 'a' && c <= 'z') || (c >= 'A' && c <= 'Z') || (c >= '0' && c <= '9') || c == '_'))
        return false;
    return true;
  }

  protected static bool dependenciesMatchRuntime(const ref ServerlessFunction fn) {
    auto text = fn.dependencies.strip;
    bool json = text.startsWith("{");
    return fn.runtime == FunctionRuntime.python312 ? !json : json;
  }
}

///
unittest {
  auto v = new FunctionValidator();
  auto fn = ServerlessFunction(TenantId("t"));
  fn.name = "hello";
  fn.sourceCode = "module.exports = { main: () => 'hi' }";
  fn.envVars = [KeyValue("GREETING", "hi")];
  v.validate(fn);

  fn.envVars = [KeyValue("1BAD", "x")];
  bool failed;
  try v.validate(fn);
  catch (KymaValidationException) failed = true;
  assert(failed);
}
