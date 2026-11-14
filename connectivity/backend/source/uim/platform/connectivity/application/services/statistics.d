/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.connectivity.application.services.statistics;

import uim.platform.connectivity;

mixin(ShowModule!());

@safe:

/// Application service: aggregated figures of a tenant.
class ConnectivityStatisticsService : IConnectivityStatisticsService {
  protected ConnectivityRepositories repos;

  this(ConnectivityRepositories repos) {
    this.repos = repos;
  }

  ConnectivityStatistics statistics(TenantId tenantId) {
    ConnectivityStatistics s;
    s.tenantId = tenantId;

    foreach (d; repos.destinations.findByTenant(tenantId)) {
      s.destinations++;
      final switch (d.status) {
      case DestinationStatus.unchecked:
        break;
      case DestinationStatus.reachable:
        s.destinationsReachable++;
        break;
      case DestinationStatus.unreachable:
        s.destinationsUnreachable++;
        break;
      case DestinationStatus.misconfigured:
        s.destinationsMisconfigured++;
        break;
      }
    }
    foreach (c; repos.connectors.findByTenant(tenantId)) {
      s.connectors++;
      if (c.status == ConnectorStatus.connected)
        s.connectorsConnected++;
      else
        s.connectorsDisconnected++;
    }
    foreach (ch; repos.channels.findByTenant(tenantId)) {
      s.channels++;
      if (ch.status == ChannelStatus.open)
        s.channelsOpen++;
    }
    s.accessRules = cast(int) repos.accessRules.findByTenant(tenantId).length;
    foreach (c; repos.certificates.findByTenant(tenantId)) {
      s.certificates++;
      if (c.status == CertificateStatus.expiring)
        s.certificatesExpiring++;
      else if (!c.status.isUsable)
        s.certificatesExpired++;
      if (c.status.isUsable && c.expiresAt > 0 && (s.nextCertificateExpiryAt == 0 || c.expiresAt < s.nextCertificateExpiryAt))
        s.nextCertificateExpiryAt = c.expiresAt;
    }
    foreach (e; repos.logs.findByTenant(tenantId)) {
      s.logEntries++;
      if (e.severity == LogSeverity.warning)
        s.warnings++;
      else if (e.severity == LogSeverity.error || e.severity == LogSeverity.critical)
        s.errors++;
      if (e.occurredAt > s.lastEventAt)
        s.lastEventAt = e.occurredAt;
    }
    return s;
  }
}
