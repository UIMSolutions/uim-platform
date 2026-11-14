/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.connectivity.application.usecases.health_check;

import uim.platform.connectivity;

mixin(ShowModule!());

@safe:

/// Interactor: one monitoring pass over a tenant.
///
///   1. connected Cloud Connectors without heartbeat → disconnected, channels closed
///   2. certificate status follows the validity period (expiring / expired)
///   3. every destination is re-checked (logged when its status changes)
///   4. the event log is pruned to MonitoringPolicy.maxLogEntries
class HealthCheckUseCase : IHealthCheckUseCase {
  protected ConnectivityRepositories repos;
  protected EventRecorder events;
  protected DestinationChecker checker;
  protected ConnectorCascade cascade;
  protected MonitoringPolicy policy;

  this(ConnectivityRepositories repos, EventRecorder events, DestinationChecker checker,
      ConnectorCascade cascade, MonitoringPolicy policy) {
    this.repos = repos;
    this.events = events;
    this.checker = checker;
    this.cascade = cascade;
    this.policy = policy;
  }

  HealthCheckReport run(TenantId tenantId) {
    HealthCheckReport r;
    r.tenantId = tenantId;
    auto now = nowStdTime();
    r.checkedAt = now;

    // 1. heartbeats
    foreach (c; repos.connectors.findByTenant(tenantId)) {
      r.examined++;
      if (!heartbeatOverdue(c, now, policy))
        continue;
      transitionTo(c, ConnectorStatus.disconnected);
      c.statusMessage = "No heartbeat for more than " ~ policy.heartbeatTimeoutSeconds.to!string ~ " s";
      c.update();
      repos.connectors.update(c);
      auto closed = cascade.closeChannels(c, "Cloud Connector lost (heartbeat missed)");
      events.log(tenantId, ConnectivityEventType.heartbeatMissed, SourceType.cloudConnector, c.id.value, c.name,
        c.statusMessage, c.host, c.port);
      r.changes ~= "Cloud Connector '" ~ c.name ~ "' disconnected (heartbeat missed, " ~ closed.to!string
        ~ " channel(s) closed)";
    }

    // 2. certificates
    Certificate[] certs;
    foreach (c; repos.certificates.findByTenant(tenantId)) {
      r.examined++;
      auto s = validityAt(c, now, policy.certificateWarningDays);
      if (s == c.status)
        continue;
      c.status = s;
      if (s == CertificateStatus.expiring) {
        c.statusMessage = "Expires in " ~ daysLeft(c, now).to!string ~ " day(s)";
        events.log(tenantId, ConnectivityEventType.certificateExpiring, SourceType.certificate, c.id.value, c.name, c.statusMessage);
      } else if (s == CertificateStatus.expired) {
        c.statusMessage = "Expired";
        events.log(tenantId, ConnectivityEventType.certificateExpired, SourceType.certificate, c.id.value, c.name,
          "Certificate expired (" ~ c.subjectDN ~ ")");
      } else
        c.statusMessage = "";
      c.update();
      certs ~= c;
      r.changes ~= "Certificate '" ~ c.name ~ "' is now " ~ enumText(s);
    }
    if (certs.length > 0)
      repos.certificates.update(certs);

    // 3. destinations
    Destination[] dests;
    foreach (d; repos.destinations.findByTenant(tenantId)) {
      r.examined++;
      auto before = d.status;
      if (!checker.run(d, now, false))
        continue;
      dests ~= d;
      if (d.status != before)
        r.changes ~= "Destination '" ~ d.name ~ "': " ~ enumText(before) ~ " → " ~ enumText(d.status) ~ " (" ~ d.statusMessage ~ ")";
    }
    if (dests.length > 0)
      repos.destinations.update(dests);

    // 4. log retention
    if (policy.maxLogEntries > 0) {
      auto entries = repos.logs.findByTenant(tenantId);
      if (entries.length > policy.maxLogEntries) {
        auto sorted = entries.sort!((a, b) => a.occurredAt < b.occurredAt).array;
        auto excess = sorted[0 .. $ - policy.maxLogEntries];
        repos.logs.remove(excess);
        r.changes ~= excess.length.to!string ~ " log entries pruned";
      }
    }

    r.changed = cast(int) r.changes.length;
    events.publish("connectivity.health-check.completed", encode(r, true));
    return r;
  }
}
