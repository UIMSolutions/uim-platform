/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.kyma.domain.enumerations.workloads;

import uim.platform.kyma;

mixin(ShowModule!());

@safe:

/// Status of a Kubernetes namespace.
enum NamespaceStatus {
  active,
  terminating,
}

/// How resource quotas of a namespace are enforced.
enum QuotaEnforcement {
  enforce,
  warn_,
  none,
}

/// Serverless runtimes supported by the Kyma serverless module.
enum FunctionRuntime {
  nodejs20,
  nodejs22,
  python312,
}

/// Lifecycle of a serverless function (build → deploy → run).
enum FunctionStatus {
  building,
  deploying,
  running,
  error,
}

/// Replica scaling of a function.
enum ScalingType {
  auto_,
  fixed,
}

///
unittest {
  assert(parseEnum!ScalingType("auto", ScalingType.fixed) == ScalingType.auto_);
  assert(parseEnum!FunctionRuntime("python312", FunctionRuntime.nodejs20) == FunctionRuntime.python312);
  assert(enumText(QuotaEnforcement.warn_) == "warn");
}
