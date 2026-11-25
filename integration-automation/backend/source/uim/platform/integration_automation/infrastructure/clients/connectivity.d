/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Adapters of the IConnectivityProbe port.
///   simulate  (default) every system with a host is reachable
///   tcp       a TCP connect to host:port within the timeout
module uim.platform.integration_automation.infrastructure.clients.connectivity;

import uim.platform.integration_automation;

mixin(ShowModule!());

@safe:

class SimulatedConnectivityProbe : IConnectivityProbe {
  string mode() {
    return "simulate";
  }

  ProbeResult probe(string host, int port, string protocol) {
    ProbeResult r;
    r.reachable = host.strip.length > 0 && port > 0;
    r.message = r.reachable ? format("Simulated test: %s://%s:%d reachable", protocol, host, port) : "No host configured";
    return r;
  }
}

class TcpConnectivityProbe : IConnectivityProbe {
  protected Duration timeout;

  this(uint timeoutSeconds) {
    timeout = dur!"seconds"(timeoutSeconds > 0 ? timeoutSeconds : 10);
  }

  string mode() {
    return "tcp";
  }

  ProbeResult probe(string host, int port, string protocol) @trusted {
    import vibe.core.net : connectTCP;

    ProbeResult r;
    auto started = nowStdTime();
    try {
      auto connection = connectTCP(host, cast(ushort) port, null, 0, timeout);
      connection.close();
      r.reachable = true;
      r.durationMs = millisBetween(started, nowStdTime());
      r.message = format("TCP connect to %s:%d succeeded in %d ms", host, port, r.durationMs);
    } catch (Exception e) {
      r.durationMs = millisBetween(started, nowStdTime());
      r.message = format("TCP connect to %s:%d failed: %s", host, port, e.msg);
    }
    return r;
  }
}

///
unittest {
  auto p = new SimulatedConnectivityProbe;
  assert(p.probe("h", 443, "https").reachable && !p.probe("", 443, "https").reachable);
}
