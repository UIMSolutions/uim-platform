/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.kyma.domain.services.function_validator;

import uim.platform.kyma.domain.entities.serverless_function;
import uim.platform.kyma.domain.types;

/// Domain service: validates serverless function configurations.
class FunctionValidator {
  /// Validate function configuration before deployment.
  string validate(ServerlessFunction fn)
  {
    if (fn.name.length == 0)
      return "Function name is required";
    if (fn.sourceCode.length == 0)
      return "Function source code cannot be empty";
    if (fn.handler.length == 0)
      return "Handler must be specified";
    if (fn.minReplicas < 0)
      return "Minimum replicas cannot be negative";
    if (fn.maxReplicas < fn.minReplicas)
      return "Maximum replicas must be >= minimum replicas";
    if (fn.timeoutSeconds <= 0 || fn.timeoutSeconds > 900)
      return "Timeout must be between 1 and 900 seconds";
    return "";
  }

  /// Check if a runtime is supported.
  bool isRuntimeSupported(FunctionRuntime runtime)
  {
    return runtime == FunctionRuntime.nodejs18 || runtime == FunctionRuntime.nodejs20
      || runtime == FunctionRuntime.python39 || runtime == FunctionRuntime.python312;
  }

  /// Validate resource limits.
  string validateResources(string cpuReq, string cpuLim, string memReq, string memLim)
  {
    // Basic presence checks for resource constraints
    if (cpuReq.length > 0 && cpuLim.length == 0)
      return "CPU limit is required when CPU request is set";
    if (memReq.length > 0 && memLim.length == 0)
      return "Memory limit is required when memory request is set";
    return "";
  }
}
