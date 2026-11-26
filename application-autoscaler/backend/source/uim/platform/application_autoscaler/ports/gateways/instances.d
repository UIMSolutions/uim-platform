/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Driven port to the platform that runs the applications: change the
/// number of instances of a bound application (Cloud Foundry
/// "cf scale -i", a Kubernetes scale subresource, …).
module uim.platform.application_autoscaler.ports.gateways.instances;

import uim.platform.application_autoscaler;

mixin(ShowModule!());

@safe:

struct ScaleRequest {
  TenantId tenantId;
  AppBindingId bindingId;
  string appGuid;
  string appName;
  int currentInstances;
  int targetInstances;
  string reason;
}

struct ScaleOutcome {
  bool success;
  int instances; /// instances the platform reports after the call
  string message;
}

interface IInstanceController {
  /// "simulate" | "http"
  string mode();
  /// Apply the target instance count. Never throws; failures are reported.
  ScaleOutcome scale(ScaleRequest r);
}
