/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.kyma.domain.enumerations.environment;

import uim.platform.kyma;

mixin(ShowModule!());

@safe:

/// Lifecycle of a Kyma runtime (cluster).
enum EnvironmentStatus {
  provisioning,
  running,
  updating,
  stopping,
  stopped,
  error,
}

/// Hyperscaler / plan of a Kyma runtime.
enum KymaPlan {
  aws,
  azure,
  gcp,
  sapConvergedCloud,
  trial,
  free_,
}

/// True while the reconciler still has to move the environment on.
bool isTransitional(EnvironmentStatus s) pure nothrow {
  return s == EnvironmentStatus.provisioning || s == EnvironmentStatus.updating
    || s == EnvironmentStatus.stopping;
}

///
unittest {
  assert(parseEnum!KymaPlan("free", KymaPlan.aws) == KymaPlan.free_);
  assert(parseEnum!KymaPlan("sap-converged-cloud", KymaPlan.aws) == KymaPlan.sapConvergedCloud);
  assert(enumText(KymaPlan.free_) == "free");
  assert(EnvironmentStatus.provisioning.isTransitional && !EnvironmentStatus.running.isTransitional);
}
