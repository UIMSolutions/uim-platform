/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.monitoring.domain.types;
import uim.platform.monitoring;

mixin(ShowModule!());

@safe:
/// Unique identifier type aliases for type safety.
struct MetricId {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin DomainId;
}
///
unittest {
  auto id1 = MetricId("metric-123");
  auto id2 = MetricId("metric-123");
  auto id3 = MetricId("metric-456");

  assert(id1 == id2);
  assert(id1 != id3);
} 
struct MetricDefinitionId {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin DomainId;
}
struct HealthCheckId {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin DomainId;
}
struct HealthCheckResultId {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin DomainId;
}
struct AlertRuleId {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin DomainId;
}
struct AlertId {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin DomainId;
}
struct NotificationChannelId {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin DomainId;
}
struct MonitoredResourceId {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin DomainId;
}
struct SubaccountId {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin DomainId;
}
