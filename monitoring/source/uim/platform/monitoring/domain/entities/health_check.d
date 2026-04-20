/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.monitoring.domain.entities.health_check;

// import uim.platform.monitoring.domain.types;
import uim.platform.monitoring;

mixin(ShowModule!());

@safe:
/// Configuration for a health or availability check.
struct HealthCheck {
  mixin TenantEntity!(HealthCheckId);

  MonitoredResourceId resourceId;
  string name;
  string description;
  CheckType checkType = CheckType.availability;
  bool isEnabled = true;
  int intervalSeconds = 60;

  /// For availability checks: HTTP endpoint to probe.
  string url;
  string expectedStatus;

  /// For JMX checks: MBean object name and attribute.
  string mbeanName;
  string mbeanAttribute;

  /// For custom HTTP checks: the custom URL and expected response.
  string customUrl;
  string expectedResponseContains;

  /// Thresholds for warning and critical states.
  double warningThreshold = 0;
  double criticalThreshold = 0;
  ThresholdOperator thresholdOperator = ThresholdOperator.greaterThan;

  Json toJson() const {
    auto j = entityToJson
      .set("resourceId", resourceId.value)
      .set("name", name)
      .set("description", description)
      .set("checkType", checkType.to!string)
      .set("isEnabled", isEnabled)
      .set("intervalSeconds", intervalSeconds)
      .set("url", url)
      .set("expectedStatus", expectedStatus)
      .set("mbeanName", mbeanName)
      .set("mbeanAttribute", mbeanAttribute)
      .set("customUrl", customUrl)
      .set("expectedResponseContains", expectedResponseContains)
      .set("warningThreshold", warningThreshold)
      .set("criticalThreshold", criticalThreshold)
      .set("thresholdOperator", thresholdOperator.to!string);

    return j;
  }
}
