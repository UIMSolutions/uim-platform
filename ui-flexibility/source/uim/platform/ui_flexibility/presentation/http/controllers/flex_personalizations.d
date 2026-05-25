/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.ui_flexibility.presentation.http.controllers.flex_personalizations;
import uim.platform.ui_flexibility;

mixin(ShowModule!());

@safe:

/// Routes: /user/v2/personalizations
class FlexPersonalizationsController : ManageController {
  private ManageFlexPersonalizationsUseCase usecase;

  this(ManageFlexPersonalizationsUseCase usecase) {
    this.usecase = usecase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);
    router.get("/user/v2/personalizations",         &handleList);
    router.get("/user/v2/personalizations/*",       &handleGet);
    router.post("/user/v2/personalizations",        &handleCreate);
    router.put("/user/v2/personalizations/*",       &handleUpdate);
    router.delete_("/user/v2/personalizations/*",   &handleDelete);
  }

  private static void writeError(scope HTTPServerResponse res, int status, string msg) {
    res.writeJsonBody(Json.emptyObject.set("error", msg).set("status", status), status);
  }

  private static PersonalizationScope parseScope(string s) {
    switch (s) {
      case "page":  return PersonalizationScope.page_;
      case "app":   return PersonalizationScope.app_;
      default:      return PersonalizationScope.control_;
    }
  }

  private static ChangeType parseChangeType(string s) {
    switch (s) {
      case "move":       return ChangeType.move_;
      case "hideControl": return ChangeType.hideControl_;
      case "addField":   return ChangeType.addField_;
      default:           return ChangeType.customAdd_;
    }
  }

  protected void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.getTenantId;
      auto j = req.json;
      CreateFlexPersonalizationRequest r;
      r.tenantId           = tenantId;
      r.personalizationId  = FlexPersonalizationId(j.getString("id"));
      r.appId              = j.getString("appId");
      r.userId_            = j.getString("userId");
      r.controlId_         = j.getString("controlId");
      r.scope_             = parseScope(j.getString("scope"));
      r.changeType_        = parseChangeType(j.getString("changeType"));
      r.content_           = j.getString("content");
      auto result = usecase.createPersonalization(r);
      if (result.success)
        res.writeJsonBody(Json.emptyObject.set("id", result.id).set("status", "created"), 201);
      else
        writeError(res, 400, result.message);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  protected void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.getTenantId;
      FlexPersonalization[] ps;
      auto appParam  = req.query.get("appId", "");
      auto userParam = req.query.get("userId", "");
      if (appParam.length > 0 && userParam.length > 0)
        ps = usecase.listByUser(tenantId, appParam, userParam);
      else
        ps = usecase.listPersonalizations(tenantId);
      auto arr = Json.emptyArray;
      foreach (p; ps) arr ~= p.toJson();
      res.writeJsonBody(Json.emptyObject.set("personalizations", arr).set("count", ps.length), 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  protected void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.getTenantId;
      auto id = FlexPersonalizationId(extractIdFromPath(req.requestURI.to!string));
      auto p = usecase.getPersonalization(tenantId, id);
      if (p.isNull) { writeError(res, 404, "FlexPersonalization not found"); return; }
      res.writeJsonBody(p.toJson(), 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  override protected void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.getTenantId;
      auto id = FlexPersonalizationId(extractIdFromPath(req.requestURI.to!string));
      auto j = req.json;
      UpdateFlexPersonalizationRequest r;
      r.tenantId           = tenantId;
      r.personalizationId  = id;
      r.content_           = j.getString("content");
      r.isSynced_          = j.get("isSynced", Json(false)).get!bool;
      auto result = usecase.updatePersonalization(r);
      if (result.success)
        res.writeJsonBody(Json.emptyObject.set("id", result.id), 200);
      else
        writeError(res, 400, result.message);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  override protected void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.getTenantId;
      auto id = FlexPersonalizationId(extractIdFromPath(req.requestURI.to!string));
      auto result = usecase.deletePersonalization(tenantId, id);
      if (result.success) res.writeBody("", cast(int) HTTPStatus.noContent, "application/json");
      else writeError(res, 404, result.message);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }
}
