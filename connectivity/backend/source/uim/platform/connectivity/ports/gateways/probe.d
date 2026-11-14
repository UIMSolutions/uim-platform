/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.connectivity.ports.gateways.probe;

import uim.platform.connectivity;

mixin(ShowModule!());

@safe:

/// Outcome of a reachability probe.
struct ProbeResult {
  bool reachable;
  int latencyMs;
  string message;
}

/// Driven port: reaches out to a target — over the internet, or through the
/// tunnel of a Cloud Connector to the internal host an access rule maps to.
interface IConnectivityProbe {
  /// Probe `endpoint` directly (internet / private link).
  ProbeResult probe(const Destination destination, const Endpoint endpoint);
  /// Probe an on-premise back end through `connector` (internalHost:internalPort).
  ProbeResult probeTunnel(const Destination destination, const CloudConnector connector,
      string internalHost, int internalPort);
}
