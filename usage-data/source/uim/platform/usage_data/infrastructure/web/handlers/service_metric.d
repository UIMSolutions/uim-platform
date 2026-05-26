/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.usage_data.infrastructure.web.handlers.service_metric;

import uim.platform.usage_data;

mixin(ShowModule!());
@safe:

class ServiceMetricHandler {
  private ServiceMetricUseCases useCases;

  this(ServiceMetricUseCases useCases) {
    this.useCases = useCases;
  }

  void getAll(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    auto items = useCases.listMetrics(TenantId.init);
    Json jArr = Json.emptyArray;
    foreach (item; items) jArr ~= toJsonValue(item);
    res.writeJsonBody(jArr);
  }

  void getOne(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    auto id = precheck.id;
    if (id.length == 0) {
      res.writeJsonBody(errorJson("Missing metric id"), 400);
      return;
    }
    auto item = useCases.getMetric(TenantId.init, ServiceMetricId(id));
    if (item.isEmpty) {
      res.writeJsonBody(errorJson("Service metric not found", 404), 404);
      return;
    }
    res.writeJsonBody(toJsonValue(item));
  }

  void create(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto json = req.json;
      auto cmd = CreateServiceMetricRequest(
        json["serviceId"].get!string,
        json["serviceName"].get!string,
        json["planId"].get!string,
        json["planName"].get!string,
        json["metricName"].get!string,
        json.type == Json.Type.object && json["description"].type != Json.Type.undefined
          ? json["description"].get!string : "",
        json["unit"].get!string,
        json["isBillable"].get!bool,
        json.type == Json.Type.object && json["category"].type != Json.Type.undefined
          ? json["category"].get!string : "",
        json["commercialModel"].get!string,
      );
      res.writeJsonBody(toJsonValue(useCases.createMetric(cmd)), 201);
    } catch (Exception e) {
      res.writeJsonBody(errorJson("Invalid request: " ~ e.msg), 400);
    }
  }

  void remove(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    auto id = precheck.id;
    useCases.deleteMetric(TenantId.init, ServiceMetricId(id));
    res.writeJsonBody(Json.emptyObject, 204);
  }
}
