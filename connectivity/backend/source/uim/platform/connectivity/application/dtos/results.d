/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.connectivity.application.dtos.results;

import uim.platform.connectivity;

mixin(ShowModule!());

@safe:

/// Aggregated figures of a tenant (Fiori KPI header, CLI "stats", GUI overview).
struct ConnectivityStatistics {
  TenantId tenantId;
  int destinations;
  int destinationsReachable;
  int destinationsUnreachable;
  int destinationsMisconfigured;
  int connectors;
  int connectorsConnected;
  int connectorsDisconnected; /// disconnected, maintenance or error
  int channels;
  int channelsOpen;
  int accessRules;
  int certificates;
  int certificatesExpiring;
  int certificatesExpired; /// expired or revoked
  int logEntries;
  int warnings;
  int errors; /// error + critical
  long lastEventAt;
  long nextCertificateExpiryAt;
}

/// Outcome of one health check pass.
struct HealthCheckReport {
  TenantId tenantId;
  int examined;
  int changed;
  string[] changes;
  long checkedAt;
}

/// Outcome of an access check (dry run of the Cloud Connector access control).
struct AccessCheckResult {
  bool allowed;
  string connectorId;
  string connectorName;
  string protocol;
  string virtualHost;
  int virtualPort;
  string path;
  string ruleId;
  string ruleName;
  string internalHost;
  int internalPort;
  bool principalPropagation;
  string reason;
}
