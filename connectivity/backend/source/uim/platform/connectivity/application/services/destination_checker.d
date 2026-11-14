/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.connectivity.application.services.destination_checker;

import uim.platform.connectivity;

mixin(ShowModule!());

@safe:

/// Outcome of a destination check (before it is stored on the destination).
struct DestinationCheck {
  DestinationStatus status;
  string message;
  int latencyMs;
  ConnectivityEventType event;
  string remoteHost;
  int remotePort;
}

/// Checks a destination end to end, the way the connectivity proxy would route it:
///
///   1. authentication settings complete            → else misconfigured
///   2. certificate present and usable              → else misconfigured
///   3. on premise: Cloud Connector of the location
///      connected, access rule allows the URL        → else unreachable
///   4. probe of the target (direct or via tunnel)  → reachable / unreachable
class DestinationChecker {
  protected ConnectivityRepositories repos;
  protected IConnectivityProbe probe;
  protected EventRecorder events;
  protected MonitoringPolicy policy;

  this(ConnectivityRepositories repos, IConnectivityProbe probe, EventRecorder events, MonitoringPolicy policy) {
    this.repos = repos;
    this.probe = probe;
    this.events = events;
    this.policy = policy;
  }

  /// The endpoint of a destination; RFC destinations without URL use jco.client.ashost/sysnr.
  static Endpoint endpointOf(const Destination d) {
    auto e = parseEndpoint(d.url);
    if (!e.isNull || d.destinationType != DestinationType.rfc)
      return e;
    auto host = valueOf(d.properties, "jco.client.ashost");
    if (host.length == 0)
      return Endpoint.init;
    auto sysnr = valueOf(d.properties, "jco.client.sysnr");
    int nr;
    if (sysnr.length == 2 && sysnr[0] >= '0' && sysnr[0] <= '9' && sysnr[1] >= '0' && sysnr[1] <= '9')
      nr = (sysnr[0] - '0') * 10 + (sysnr[1] - '0');
    return Endpoint("rfc", host.toLower, 3300 + nr, "/");
  }

  DestinationCheck evaluate(const Destination d, long now) {
    DestinationCheck c;
    c.status = DestinationStatus.misconfigured;
    c.event = ConnectivityEventType.authenticationFailure;

    auto errors = authenticationErrors(d);
    if (errors.length > 0) {
      c.message = errors.join("; ");
      return c;
    }
    auto endpoint = endpointOf(d);
    if (endpoint.isNull) {
      c.message = d.destinationType == DestinationType.rfc
        ? "RFC destination needs a URL or the property jco.client.ashost" : "Invalid URL '" ~ d.url ~ "'";
      return c;
    }
    c.remoteHost = endpoint.host;
    c.remotePort = endpoint.port;

    if (!d.certificateId.isEmpty) {
      auto cert = repos.certificates.findById(d.tenantId, d.certificateId);
      if (cert.isNull) {
        c.message = "Certificate '" ~ d.certificateId.value ~ "' not found";
        return c;
      }
      if (!usableAt(cert, now, policy.certificateWarningDays)) {
        c.message = "Certificate '" ~ cert.name ~ "' is not usable (" ~ enumText(validityAt(cert, now,
            policy.certificateWarningDays)) ~ ")";
        return c;
      }
    }

    c.status = DestinationStatus.unreachable;
    ProbeResult result;
    if (d.proxyType == ProxyType.onPremise) {
      auto connector = repos.connectors.findByLocation(d.tenantId, SubaccountId.init, d.cloudConnectorLocationId);
      auto location = d.cloudConnectorLocationId.length > 0 ? "'" ~ d.cloudConnectorLocationId ~ "'" : "(default)";
      if (connector.isNull) {
        c.event = ConnectivityEventType.destinationNotFound;
        c.message = "No Cloud Connector is registered for location " ~ location;
        return c;
      }
      if (connector.status != ConnectorStatus.connected) {
        c.event = ConnectivityEventType.connectionRefused;
        c.message = "Cloud Connector '" ~ connector.name ~ "' is " ~ enumText(connector.status);
        return c;
      }
      auto decision = evaluateAccess(repos.accessRules.findByConnector(d.tenantId, connector.id),
        accessProtocolOf(endpoint.scheme), endpoint.host, endpoint.port, endpoint.path);
      if (!decision.allowed) {
        c.event = ConnectivityEventType.accessDenied;
        c.message = decision.reason;
        return c;
      }
      result = probe.probeTunnel(d, connector, decision.internalHost, decision.internalPort);
    } else
      result = probe.probe(d, endpoint);

    c.latencyMs = result.latencyMs;
    if (result.reachable) {
      c.status = DestinationStatus.reachable;
      c.event = ConnectivityEventType.destinationResolved;
      c.message = result.message.length > 0 ? result.message : "Reachable";
    } else {
      c.event = ConnectivityEventType.connectionRefused;
      c.message = result.message.length > 0 ? result.message : "Not reachable";
    }
    return c;
  }

  /// Check `d` and store the outcome on it (not persisted). Logs the event if
  /// `logAlways` or if the status changed. Returns true if the status changed.
  bool run(ref Destination d, long now, bool logAlways, UserId actor = UserId.init) {
    auto c = evaluate(d, now);
    auto changed = c.status != d.status || c.message != d.statusMessage;
    auto statusChanged = c.status != d.status;
    d.status = c.status;
    d.statusMessage = c.message;
    d.latencyMs = c.latencyMs;
    d.lastCheckedAt = now;
    if (logAlways || statusChanged)
      events.log(d.tenantId, c.event, SourceType.destination, d.id.value, d.name,
        enumText(c.status) ~ ": " ~ c.message, c.remoteHost, c.remotePort, actor);
    return changed;
  }
}
