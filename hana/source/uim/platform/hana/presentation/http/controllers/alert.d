/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.hana.presentation.http.controllers.alert;
// import uim.platform.hana.application.usecases.manage.alerts;
// import uim.platform.hana.application.dto;

import uim.platform.hana;

mixin(ShowModule!());

@safe:

class AlertController : PlatformController {
  private ManageAlertsUseCase usecase;

  this(ManageAlertsUseCase usecase) {
    this.usecase = usecase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);
    router.get("/api/v1/hana/alerts", &handleList);
    router.get("/api/v1/hana/alerts/*", &handleGet);
    router.post("/api/v1/hana/alerts", &handleCreate);
    router.put("/api/v1/hana/alerts/*", &handleUpdate);
    router.post("/api/v1/hana/alerts/*/acknowledge", &handleAcknowledge);
    router.delete_("/api/v1/hana/alerts/*", &handleDelete);
  }

  protected void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
      auto tenantId = req.getTenantId;
      auto j = req.json;
      CreateAlertRequest r;
      r.tenantId = tenantId;
      r.instanceId = j.getString("instanceId");
      r.id = j.getString("id");
      r.name = j.getString("name");
      r.description = j.getString("description");
      r.severity = j.getString("severity");
      r.category = j.getString("category");
      r.metricName = j.getString("metricName");
      r.warningValue = getDouble(j, "warningValue");
      r.criticalValue = getDouble(j, "criticalValue");
      r.unit = j.getString("unit");

      auto result = usecase.create(r);
      if (result.success) {
        auto resp = Json.emptyObject
          .set("id", result.id)
          .set("message", "Alert created");

        res.writeJsonBody(resp, 201);
      } else {
        writeError(res, 400, result.errorMessage);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  protected void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.getTenantId;
      auto alerts = usecase.list(tenantId);

      auto jarr = Json.emptyArray;
      foreach (a; alerts) {
        jarr ~= Json.emptyObject
        .set("id", a.id)
        .set("instanceId", a.instanceId)
        .set("name", a.name)
        .set("severity", a.severity.to!string)
        .set("status", a.status.to!string)
        .set("category", a.category.to!string)
        .set("triggeredAt", a.triggeredAt);
      }

      auto resp = Json.emptyObject
        .set("count", alerts.length)
        .set("resources", jarr);

      res.writeJsonBody(resp, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  protected void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
      auto tenantId = req.getTenantId;
      auto id = extractIdFromPath(req.requestURI.to!string);
      auto a = usecase.getById(tenantId, id);
      if (a.isNull) {
        writeError(res, 404, "Alert not found");
        return;
      }

      auto resp = Json.emptyObject
        .set("id", a.id)
        .set("instanceId", a.instanceId)
        .set("name", a.name)
        .set("description", a.description)
        .set("severity", a.severity.to!string)
        .set("status", a.status.to!string)
        .set("category", a.category.to!string)
        .set("metricName", a.metricName)
        .set("triggeredAt", a.triggeredAt)
        .set("acknowledgedAt", a.acknowledgedAt)
        .set("acknowledgedBy", a.acknowledgedBy)
        .set("resolvedAt", a.resolvedAt)
        .set("createdAt", a.createdAt);

      res.writeJsonBody(resp, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  protected void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      

      auto j = req.json;
      UpdateAlertRequest r;
      r.tenantId = tenantId;
      r.id = extractIdFromPath(req.requestURI.to!string);
      r.name = j.getString("name");
      r.description = j.getString("description");
      r.severity = j.getString("severity");
      r.warningValue = getDouble(j, "warningValue");
      r.criticalValue = getDouble(j, "criticalValue");

      auto result = usecase.update(r);
      if (result.success) {
        auto resp = Json.emptyObject
          .set("id", result.id)
          .set("message", "Alert updated");

        res.writeJsonBody(resp, 200);
      } else {
        writeError(res, 404, result.errorMessage);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  protected void handleAcknowledge(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      
      import std.string : lastIndexOf;

      auto path = req.requestURI.to!string;
      auto ackIdx = lastIndexOf(path, "/acknowledge");
      if (ackIdx < 0) {
        writeError(res, 400, "Invalid path");
        return;
      }
      auto sub = path[0 .. ackIdx];
      auto id = extractIdFromPath(sub);

      auto j = req.json;
      AcknowledgeAlertRequest r;
      r.tenantId = tenantId;
      r.id = id;
      r.acknowledgedBy = j.getString("acknowledgedBy");

      auto result = usecase.acknowledge(r);
      if (result.success) {
        auto resp = Json.emptyObject
          .set("id", result.id)
          .set("message", "Alert acknowledged");

        res.writeJsonBody(resp, 200);
      } else {
        writeError(res, 404, result.errorMessage);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  protected void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
      auto tenantId = req.getTenantId;
      auto id = AlertId(extractIdFromPath(req.requestURI.to!string));
      auto result = usecase.deleteAlert(id);
      if (result.success) {
        res.writeJsonBody(Json.emptyObject, 204);
      } else {
        writeError(res, 404, result.errorMessage);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }
}
