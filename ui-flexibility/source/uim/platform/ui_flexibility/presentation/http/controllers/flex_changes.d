/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.ui_flexibility.presentation.http.controllers.flex_changes;
import uim.platform.ui_flexibility;

mixin(ShowModule!());

@safe:

/// Handles SAPUI5 flexibility change records (key user adaptations).
/// Routes: /keyuser/v2/changes
class FlexChangesController : PlatformController {
  private ManageFlexChangesUseCase usecase;

  this(ManageFlexChangesUseCase usecase) {
    this.usecase = usecase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);
    router.get("/keyuser/v2/changes",    &handleList);
    router.get("/keyuser/v2/changes/*",  &handleGet);
    router.post("/keyuser/v2/changes",   &handleCreate);
    router.put("/keyuser/v2/changes/*",  &handleUpdate);
    router.delete_("/keyuser/v2/changes/*", &handleDelete);
  }

  private static void writeError(scope HTTPServerResponse res, int status, string msg) {
    res.writeJsonBody(Json.emptyObject.set("error", msg).set("status", status), status);
  }

  private static ChangeLayer parseLayer(string s) {
    switch (s) {
      case "vendor":   return ChangeLayer.vendor_;
      case "user":     return ChangeLayer.user_;
      default:         return ChangeLayer.customer_;
    }
  }

  private static ChangeType parseChangeType(string s) {
    switch (s) {
      case "move":             return ChangeType.move_;
      case "rename":           return ChangeType.rename_;
      case "addField":         return ChangeType.addField_;
      case "hideControl":      return ChangeType.hideControl_;
      case "unhideControl":    return ChangeType.unhideControl_;
      case "addXML":           return ChangeType.addXML_;
      case "setTitle":         return ChangeType.setTitle_;
      case "stashControl":     return ChangeType.stashControl_;
      case "unstashControl":   return ChangeType.unstashControl_;
      case "bindProperty":     return ChangeType.bindProperty_;
      case "unbindProperty":   return ChangeType.unbindProperty_;
      default:                 return ChangeType.customAdd_;
    }
  }

  protected void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.getTenantId;
      auto j = req.json;
      CreateFlexChangeRequest r;
      r.tenantId   = tenantId;
      r.changeId   = FlexChangeId(j.getString("id"));
      r.appId      = j.getString("appId");
      r.namespace_ = j.getString("namespace");
      r.layer_     = parseLayer(j.getString("layer"));
      r.changeType_ = parseChangeType(j.getString("changeType"));
      r.selector_   = j.getString("selector");
      r.content_    = j.getString("content");
      r.reference_  = j.getString("reference");
      r.support_    = j.getString("support");
      r.dependentSelector_ = j.getString("dependentSelector");
      r.createdBy_  = j.getString("createdBy");
      auto result = usecase.createChange(r);
      if (result.success)
        res.writeJsonBody(Json.emptyObject.set("id", result.id).set("status", "created"), 201);
      else
        writeError(res, 400, result.errorMessage);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  protected void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.getTenantId;
      FlexChange[] changes;
      auto appParam = req.query.get("appId", "");
      if (appParam.length > 0)
        changes = usecase.listChangesByApp(tenantId, appParam);
      else
        changes = usecase.listChanges(tenantId);
      auto arr = Json.emptyArray;
      foreach (c; changes) arr ~= c.toJson();
      res.writeJsonBody(Json.emptyObject.set("changes", arr).set("count", changes.length), 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  protected void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.getTenantId;
      auto id = FlexChangeId(extractIdFromPath(req.requestURI.to!string));
      auto c = usecase.getChange(tenantId, id);
      if (c.isNull) { writeError(res, 404, "FlexChange not found"); return; }
      res.writeJsonBody(c.toJson(), 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  protected void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.getTenantId;
      auto id = FlexChangeId(extractIdFromPath(req.requestURI.to!string));
      auto j = req.json;
      UpdateFlexChangeRequest r;
      r.tenantId   = tenantId;
      r.changeId   = id;
      r.selector_  = j.getString("selector");
      r.content_   = j.getString("content");
      r.reference_ = j.getString("reference");
      r.updatedBy_ = j.getString("updatedBy");
      r.isActive_  = j.get("isActive", Json(true)).get!bool;
      auto result = usecase.updateChange(r);
      if (result.success)
        res.writeJsonBody(Json.emptyObject.set("id", result.id), 200);
      else
        writeError(res, 400, result.errorMessage);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  protected void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.getTenantId;
      auto id = FlexChangeId(extractIdFromPath(req.requestURI.to!string));
      auto result = usecase.deleteChange(tenantId, id);
      if (result.success) res.writeBody("", cast(int) HTTPStatus.noContent, "application/json");
      else writeError(res, 404, result.errorMessage);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }
}
