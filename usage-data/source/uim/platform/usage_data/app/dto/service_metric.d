/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.usage_data.app.dto.service_metric;

import uim.platform.usage_data;
mixin(ShowModule!());
@safe:

struct CreateServiceMetricRequest {
  string serviceId;
  string serviceName;
  string planId;
  string planName;
  string metricName;
  string description;
  string unit;
  bool isBillable;
  string category;
  string commercialModel;
}

struct ServiceMetricResponse {
  ServiceMetricId metricId;
  TenantId tenantId;
  string serviceId;
  string serviceName;
  string planId;
  string planName;
  string metricName;
  string description;
  string unit;
  bool isBillable;
  string category;
  string commercialModel;

  bool isEmpty() const { return metricId.value.length == 0; }

  static ServiceMetricResponse fromEntity(ServiceMetric m) {
    if (m.isNull) return ServiceMetricResponse.init;
    return ServiceMetricResponse(m.id, m.tenantId, m.serviceId, m.serviceName,
      m.planId, m.planName, m.metricName, m.description, m.unit.to!string,
      m.isBillable, m.category, m.commercialModel.to!string);
  }
}
