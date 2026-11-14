/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.kyma.application.dtos.function_;

import uim.platform.kyma;

mixin(ShowModule!());

@safe:

struct FunctionSpec {
  string name;
  string description;
  FunctionRuntime runtime = FunctionRuntime.nodejs20;
  string sourceCode;
  string handler = "main";
  string dependencies;
  ScalingType scalingType = ScalingType.auto_;
  int minReplicas = 1;
  int maxReplicas = 5;
  string cpuRequest;
  string cpuLimit;
  string memoryRequest;
  string memoryLimit;
  KeyValue[] envVars;
  KeyValue[] labels;
  int timeoutSeconds = 180;
}

alias CreateFunctionRequest = CreateRequest!(NamespaceId, FunctionSpec);
alias UpdateFunctionRequest = UpdateRequest!(ServerlessFunctionId, FunctionSpec);
