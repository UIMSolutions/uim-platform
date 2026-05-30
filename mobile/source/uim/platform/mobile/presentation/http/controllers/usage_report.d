/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.mobile.presentation.http.controllers.usage_report;
// import uim.platform.mobile.application.usecases.manage.usage_reports;
// import uim.platform.mobile.application.dto;
// import uim.platform.mobile;

import uim.platform.mobile;

mixin(Showmodule!());

@safe:

class UsageReportController : ManageController {
  private ManageUsageReportsUseCase usecase;

  this(ManageUsageReportsUseCase usecase) {
    this.usecase = usecase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.post("/api/v1/usage", &handleReport);
    router.get("/api/v1/usage", &handleList);
    router.get("/api/v1/usage/*", &handleGet);
  }

  protected void handleReport(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
      auto tenantId = precheck.tenantId;
      auto data = precheck.data;
      CreateUsageReportRequest r;
      r.tenantId = tenantId;
      r.appId = data.getString("appId");
      r.deviceId = data.getString("deviceId");
      r.userId = data.getString("userId");
      r.metricType = data.getString("metricType");
      r.metricKey = data.getString("metricKey");
      r.metricValue = data.getString("metricValue");
      r.sessionId = data.getString("sessionId");
      r.platform = data.getString("platform");
      r.appVersion = data.getString("appVersion");
      r.timestamp = jsonLong(j, "timestamp");
      auto result = usecase.report(r);
      if (result.hasError)
            return errorResponse(result.message, 400);
        auto resp = Json.emptyObject
          .set("id", result.id)
          .set("message", "Usage report created successfully");
        res.writeJsonBody(resp, 201);
      } else {
        writeError(res, 400, result.message);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  override protected Json listHandler(HTTPServerRequest req) {
        auto precheck = super.listHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
      auto results = usecase.list(tenantId);
      auto items = Json.emptyArray;
      foreach (item; results) {
        items ~= Json.emptyObject
          .set("id", item.id)
          .set("appId", item.appId)
          .set("metricType", item.metricType)
          .set("metricKey", item.metricKey)
          .set("metricValue", item.metricValue);
      }
      auto resp = Json.emptyObject
        .set("items", items);
        
      res.writeJsonBody(resp, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  override protected Json getHandler(HTTPServerRequest req) {
        auto precheck = super.getHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
      auto id = precheck.id;
      auto result = usecase.get(id);
      if (result.hasError)
            return errorResponse(result.message, 400);
        auto resp = Json.emptyObject
          .set("id", result.data.id)
          .set("tenantId", result.data.tenantId)
          .set("appId", result.data.appId)
          .set("deviceId", result.data.deviceId)
          .set("userId", result.data.userId)
          .set("metricType", result.data.metricType)
          .set("metricKey", result.data.metricKey)
          .set("metricValue", result.data.metricValue)
          .set("sessionId", result.data.sessionId)
          .set("platform", result.data.platform)
          .set("appVersion", result.data.appVersion)
          .set("timestamp", result.data.timestamp);

        res.writeJsonBody(resp, 200);
      } else {
        writeError(res, 404, result.message);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }
}
