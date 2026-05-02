/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.hana.domain.entities.alert;

// import uim.platform.hana.domain.types;
import uim.platform.hana;

mixin(ShowModule!());

@safe:
struct AlertThreshold {
  string metric;
  double warningValue;
  double criticalValue;
  string unit;

  Json toJson() const {
    return Json.emptyObject
      .set("metric", metric)
      .set("warningValue", warningValue)
      .set("criticalValue", criticalValue)
      .set("unit", unit);
  }
}

struct Alert {
  mixin TenantEntity!(AlertId);
  
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
  UserId acknowledgedBy;
  long triggeredAt;
  long acknowledgedAt;
  long resolvedAt;
  
  Json toJson() const {
    return entityToJson
      .set("instanceId", instanceId)
      .set("name", name)
      .set("description", description)
      .set("severity", severity.to!string)
      .set("status", status.to!string)
      .set("category", category.to!string)
      .set("source", source)
      .set("metricName", metricName)
      .set("metricValue", metricValue)
      .set("threshold", threshold.toJson())
      .set("acknowledgedBy", acknowledgedBy)
      .set("triggeredAt", triggeredAt)
      .set("acknowledgedAt", acknowledgedAt)
      .set("resolvedAt", resolvedAt);
  }
}
