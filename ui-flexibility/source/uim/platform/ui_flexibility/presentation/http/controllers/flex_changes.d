/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.ui_flexibility.presentation.http.controllers.flex_changes;
import uim.platform.ui_flexibility;

// mixin(ShowModule!());

@safe:

/// Handles SAPUI5 flexibility change records (key user adaptations).
/// Routes: /keyuser/v2/changes
class FlexChangesController : ManageHttpController {
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

  override protected Json createHandler(HTTPServerRequest req) {
        auto precheck = super.createHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

        auto data = precheck.data;
              CreateFlexChangeRequest r;
      r.tenantId   = tenantId;
      r.changeId   = FlexChangeId(precheck.id);
      r.appId      = data.getString("appId");
      r.namespace_ = data.getString("namespace");
      r.layer_     = toChangeLayer(data.getString("layer"));
      r.changeType_ = data.getString("changeType");
      r.selector_   = data.getString("selector");
      r.content_    = data.getString("content");
      r.reference_  = data.getString("reference");
      r.support_    = data.getString("support");
      r.dependentSelector_ = data.getString("dependentSelector");
      r.createdBy_  = data.getString("createdBy");
      auto result = usecase.createChange(r);
      if (result.success)
        res.writeJsonBody(Json.emptyObject.set("id", result.id).set("status", "created"), 201);
      else
        writeError(res, 400, result.message);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  override protected Json listHandler(HTTPServerRequest req) {
        auto precheck = super.listHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
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

  override protected Json getHandler(HTTPServerRequest req) {
        auto precheck = super.getHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
      auto id = FlexChangeId(precheck.id);
      auto c = usecase.getChange(tenantId, id);
      if (c.isNull) { writeError(res, 404, "FlexChange not found"); return; }
      res.writeJsonBody(c.toJson(), 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  override protected Json updateHandler(HTTPServerRequest req) {
        auto precheck = super.updateHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
      auto id = FlexChangeId(precheck.id);
      auto data = precheck.data;
      UpdateFlexChangeRequest r;
      r.tenantId   = tenantId;
      r.changeId   = id;
      r.selector_  = data.getString("selector");
      r.content_   = data.getString("content");
      r.reference_ = data.getString("reference");
      r.updatedBy_ = data.getString("updatedBy");
      r.isActive_  = j.get("isActive", Json(true)).get!bool;
      auto result = usecase.updateChange(r);
      if (result.success)
        res.writeJsonBody(Json.emptyObject.set("id", result.id), 200);
      else
        writeError(res, 400, result.message);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  override protected Json deleteHandler(HTTPServerRequest req) {
        auto precheck = super.deleteHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
      auto id = FlexChangeId(precheck.id);
      auto result = usecase.deleteChange(tenantId, id);
      if (result.success) res.writeBody("", cast(int) HTTPStatus.noContent, "application/json");
      else writeError(res, 404, result.message);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }
}
