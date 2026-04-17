/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity_authentication.presentation.http.widget;

// import vibe.http.server;
// import vibe.http.router;
// import vibe.data.json;
import uim.platform.workzone.application.usecases.manage.widgets;
import uim.platform.workzone.application.dto;
import uim.platform.workzone.domain.types;
import uim.platform.workzone.domain.entities.widget;
import uim.platform.identity_authentication.presentation.http.json_utils;

class WidgetController : PlatformController {
  private ManageWidgetsUseCase useCase;

  this(ManageWidgetsUseCase useCase) {
    this.useCase = useCase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);
    
    router.post("/api/v1/widgets", &handleCreate);
    router.get("/api/v1/widgets", &handleList);
    router.get("/api/v1/widgets/*", &handleGet);
    router.put("/api/v1/widgets/*", &handleUpdate);
    router.delete_("/api/v1/widgets/*", &handleDelete);
  }

  private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto j = req.json;
      auto r = CreateWidgetRequest();
      r.pageId = j.getString("pageId");
      r.tenantId = req.getTenantId;
      r.title = j.getString("title");
      r.cardId = j.getString("cardId");
      r.appId = j.getString("appId");
      r.row = j.getInteger("row");
      r.col = j.getInteger("col");
      r.sortOrder = j.getInteger("sortOrder");

      auto sStr = j.getString("size");
      if (sStr == "small")
        r.size = WidgetSize.small;
      else if (sStr == "large")
        r.size = WidgetSize.large;
      else if (sStr == "fullWidth")
        r.size = WidgetSize.fullWidth;
      else
        r.size = WidgetSize.medium;

      r.config = parseWidgetConfig(j);

      auto result = useCase.createWidget(r);
      if (result.isSuccess()) {
        auto resp = Json.emptyObject;
        resp["id"] = Json(result.id);
        res.writeJsonBody(resp, 201);
      }
      else
      {
        writeError(res, 400, result.error);
      }
    }
    catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      TenantId tenantId = req.getTenantId;
      auto pageId = req.params.get("pageId", "");
      auto widgets = useCase.listByPage(pagetenantId, id);
      auto arr = Json.emptyArray;
      foreach (w; widgets)
        arr ~= serializeWidget(w);
      auto resp = Json.emptyObject;
      resp["items"] = arr;
      resp["totalCount"] = Json(widgets.length);
      res.writeJsonBody(resp, 200);
    }
    catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto id = extractIdFromPath(req.requestURI);
      TenantId tenantId = req.getTenantId;
      auto w = useCase.getWidget(tenantId, id);
      if (w is null) {
        writeError(res, 404, "Widget not found");
        return;
      }
      res.writeJsonBody(serializeWidget(*w), 200);
    }
    catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto j = req.json;
      auto r = UpdateWidgetRequest();
      r.id = extractIdFromPath(req.requestURI);
      r.tenantId = req.getTenantId;
      r.title = j.getString("title");
      r.row = j.getInteger("row");
      r.col = j.getInteger("col");
      r.sortOrder = j.getInteger("sortOrder");
      r.visible = j.getBoolean("visible", true);
      r.config = parseWidgetConfig(j);

      auto sStr = j.getString("size");
      if (sStr == "small")
        r.size = WidgetSize.small;
      else if (sStr == "large")
        r.size = WidgetSize.large;
      else if (sStr == "fullWidth")
        r.size = WidgetSize.fullWidth;
      else
        r.size = WidgetSize.medium;

      auto result = useCase.updateWidget(r);
      if (result.isSuccess()) {
        auto resp = Json.emptyObject;
        resp["status"] = Json("updated");
        res.writeJsonBody(resp, 200);
      }
      else
      {
        writeError(res, 404, result.error);
      }
    }
    catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto id = extractIdFromPath(req.requestURI);
      TenantId tenantId = req.getTenantId;
      useCase.deleteWidget(tenantId, id);
      res.writeBody("", 204);
    }
    catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }
}

private WidgetConfig parseWidgetConfig(Json j) {
  import uim.platform.workzone.domain.entities.widget : WidgetConfig;

  WidgetConfig cfg;
  auto v = "config" in j;
  if (v !is null && (*v).isObject) {
    auto c = *v;
    cfg.customTitle = c.getString("customTitle");
    cfg.maxItems = jsonInt(c, "maxItems");
    cfg.refreshIntervalSec = jsonInt(c, "refreshIntervalSec");
    cfg.filterExpression = c.getString("filterExpression");
  }
  return cfg;
}

private Json serializeWidget(Widget w) {
  // import std.conv : to;
  auto j = Json.emptyObject
  .set("id", w.id)
  .set("pageId", w.pageId)
  .set("tenantId", w.tenantId)
  .set("title", w.title)
  .set("cardId", w.cardId)
  .set("appId", w.appId)
  .set("size", w.size.to!string)
  .set("row", w.row)
  .set("col", w.col)
  .set("sortOrder", w.sortOrder)
  .set("visible", w.visible)
  .set("createdAt", w.createdAt)
  .set("updatedAt", w.updatedAt);

  auto cfg = Json.emptyObject;
  cfg["customTitle"] = Json(w.config.customTitle);
  cfg["maxItems"] = Json(w.config.maxItems);
  cfg["refreshIntervalSec"] = Json(w.config.refreshIntervalSec);
  cfg["filterExpression"] = Json(w.config.filterExpression);
  j["config"] = cfg;

  return j;
}
