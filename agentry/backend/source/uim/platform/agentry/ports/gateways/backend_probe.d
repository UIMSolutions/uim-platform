/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.agentry.ports.gateways.backend_probe;

import uim.platform.agentry;

mixin(ShowModule!());

@safe:

/// Result of a connectivity check against an SAP backend.
struct BackendProbeResult {
  bool reachable;
  int statusCode;
  long latencyMs;
  string message;
}

/// Driven port: check whether a backend system is reachable.
interface IBackendProbe {
  BackendProbeResult probe(const BackendConnection connection);
}
