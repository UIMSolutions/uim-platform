/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.usage_data.infrastructure.web.handlers.usage_record;

import uim.platform.usage_data;

// mixin(ShowModule!());
@safe:

class UsageRecordHandler {
  private UsageRecordUseCases useCases;

  this(UsageRecordUseCases useCases) {
    this.useCases = useCases;
  }

  void getAll(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    auto items = useCases.listRecords(TenantId.init);
    Json jArr = Json.emptyArray;
    foreach (item; items) jArr ~= toJsonValue(item);
    res.writeJsonBody(jArr);
  }

  void getOne(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    auto id = precheck.id;
    if (id.length == 0) {
      res.writeJsonBody(errorJson("Missing usage record id"), 400);
      return;
    }
    auto item = useCases.getRecord(TenantId.init, UsageRecordId(id));
    if (item.isEmpty) {
      res.writeJsonBody(errorJson("Usage record not found", 404), 404);
      return;
    }
    res.writeJsonBody(toJsonValue(item));
  }

  void submit(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto json = req.json;
      auto cmd = CreateUsageRecordRequest(
        json["globalAccountId"].get!string,
        json["subaccountId"].get!string,
        json.isObject && json["directoryId"].type != Json.Type.undefined
          ? json["directoryId"].get!string : "",
        json["region"].get!string,
        json.isObject && json["datacenter"].type != Json.Type.undefined
          ? json["datacenter"].get!string : "",
        json["serviceId"].get!string,
        json["serviceName"].get!string,
        json["planId"].get!string,
        json["planName"].get!string,
        json["metricName"].get!string,
        json["metricValue"].get!double,
        json["environment"].get!string,
        json["chargebackPeriod"].get!string,
      );
      res.writeJsonBody(toJsonValue(useCases.submitRecord(cmd)), 201);
    } catch (Exception e) {
      res.writeJsonBody(errorJson("Invalid request: " ~ e.msg), 400);
    }
  }

  void remove(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    auto id = precheck.id;
    useCases.deleteRecord(TenantId.init, UsageRecordId(id));
    res.writeJsonBody(Json.emptyObject, 204);
  }
}
