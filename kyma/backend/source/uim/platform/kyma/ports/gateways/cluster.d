/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.kyma.ports.gateways.cluster;

import uim.platform.kyma;

mixin(ShowModule!());

@safe:

/// Driven port: the Kubernetes API of a Kyma runtime. Interactors hand the
/// rendered custom resources to the gateway; a real adapter would
/// `kubectl apply` them, the default adapter only records them.
interface IClusterGateway {
  /// Apply a manifest to the cluster of `environmentId`.
  void apply(KymaEnvironmentId environmentId, Json manifest);
  /// Delete the resource of `kind`/`name` (in `namespace_`, "" for cluster scoped).
  void remove(KymaEnvironmentId environmentId, string kind, string namespace_, string name);
}
