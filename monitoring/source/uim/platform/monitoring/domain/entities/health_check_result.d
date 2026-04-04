/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.monitoring.domain.entities.health_check_result;

import uim.platform.monitoring.domain.types;

/// Result of executing a health check.
struct HealthCheckResult {
  HealthCheckResultId id;
  TenantId tenantId;
  HealthCheckId checkId;
  MonitoredResourceId resourceId;
  CheckStatus status = CheckStatus.unknown;
  double value_;
  string message;
  int responseTimeMs;
  int httpStatusCode;
  long executedAt;
}
