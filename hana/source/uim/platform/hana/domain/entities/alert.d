/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.hana.domain.entities.alert;

import uim.platform.hana.domain.types;

struct AlertThreshold {
  string metric;
  double warningValue;
  double criticalValue;
  string unit;
}

struct Alert {
  AlertId id;
  TenantId tenantId;
  InstanceId instanceId;
  string name;
  string description;
  AlertSeverity severity;
  AlertStatus status;
  AlertCategory category;
  string source;
  string metricName;
  double metricValue;
  AlertThreshold threshold;
  string acknowledgedBy;
  long triggeredAt;
  long acknowledgedAt;
  long resolvedAt;
  long createdAt;
}
