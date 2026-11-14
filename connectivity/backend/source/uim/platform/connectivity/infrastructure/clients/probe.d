/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.connectivity.infrastructure.clients.probe;

import std.digest.crc : crc32Of;
import uim.platform.connectivity;

mixin(ShowModule!());

@safe:

/// Simulated reachability probe: latency is derived deterministically from the
/// target and every call is recorded. Replace with an HTTP / socket client (and
/// the Cloud Connector tunnel API) to probe real targets.
///
/// Conventions that let tests and demos exercise failure paths: hosts
/// containing "invalid", "unreachable" or "offline" refuse the connection.
class SimulatedConnectivityProbe : IConnectivityProbe {
  struct Operation {
    string verb;
    string target;
    bool reachable;
  }

  protected Operation[] _operations;
  protected size_t _capacity;

  this(size_t capacity = 500) {
    _capacity = capacity;
  }

  ProbeResult probe(const Destination destination, const Endpoint endpoint) {
    return attempt("probe", endpoint.host, endpoint.port, 0);
  }

  ProbeResult probeTunnel(const Destination destination, const CloudConnector connector,
      string internalHost, int internalPort) {
    auto r = attempt("tunnel " ~ connector.name, internalHost, internalPort, 15);
    if (r.reachable)
      r.message ~= " via Cloud Connector '" ~ connector.name ~ "'";
    return r;
  }

  /// The most recent calls (oldest first).
  const(Operation)[] operations() const {
    return _operations;
  }

  protected ProbeResult attempt(string verb, string host, int port, int overheadMs) {
    auto target = host ~ ":" ~ port.to!string;
    auto lower = host.toLower;
    ProbeResult r;
    r.reachable = !(lower.canFind("invalid") || lower.canFind("unreachable") || lower.canFind("offline"));
    auto crc = crc32Of(target);
    r.latencyMs = overheadMs + 5 + (crc[0] + crc[1]) % 120;
    r.message = r.reachable ? target ~ " reachable in " ~ r.latencyMs.to!string ~ " ms"
      : "Connection to " ~ target ~ " refused";
    _operations ~= Operation(verb, target, r.reachable);
    if (_operations.length > _capacity)
      _operations = _operations[$ - _capacity .. $];
    logDebug("connectivity probe: %s %s → %s", verb, target, r.reachable);
    return r;
  }
}

///
unittest {
  auto p = new SimulatedConnectivityProbe();
  Destination d;
  auto ok = p.probe(d, Endpoint("https", "api.example.com", 443, "/"));
  assert(ok.reachable && ok.latencyMs >= 5);
  assert(!p.probe(d, Endpoint("https", "offline.example.com", 443, "/")).reachable);
  CloudConnector c;
  c.name = "dc1";
  assert(p.probeTunnel(d, c, "erp.corp", 44_300).message.canFind("dc1"));
  assert(p.operations.length == 3);
}
