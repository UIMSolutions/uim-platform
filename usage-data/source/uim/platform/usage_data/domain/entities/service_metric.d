/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.usage_data.domain.entities.service_metric;

import uim.platform.usage_data;

mixin(ShowModule!());
@safe:

/// A ServiceMetric defines a measurable unit for a BTP service plan.
/// It is the catalog of what can be measured and potentially billed.
struct ServiceMetric {
  mixin TenantEntity!ServiceMetricId;

  string serviceId;
  string serviceName;
  string planId;
  string planName;
  string metricName;
  string description;
  MetricUnit unit;
  bool isBillable;
  string category;
  CommercialModel commercialModel;

  Json toJson() {
    return entityToJson()
      .set("serviceId", serviceId)
      .set("serviceName", serviceName)
      .set("planId", planId)
      .set("planName", planName)
      .set("metricName", metricName)
      .set("description", description)
      .set("unit", unit.to!string)
      .set("isBillable", isBillable)
      .set("category", category)
      .set("commercialModel", commercialModel.to!string);
  }

  static ServiceMetric create(string serviceId, string serviceName,
      string planId, string planName, string metricName,
      MetricUnit unit, bool isBillable) {
    ServiceMetric m;
    m.id = ServiceMetricId(randomUUID().toString());
    m.serviceId = serviceId;
    m.serviceName = serviceName;
    m.planId = planId;
    m.planName = planName;
    m.metricName = metricName;
    m.unit = unit;
    m.isBillable = isBillable;
    m.commercialModel = CommercialModel.cpea;
    return m;
  }
}
