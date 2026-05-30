/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.ui_flexibility.presentation.http.controllers.flex_applications;
import uim.platform.ui_flexibility;

mixin(ShowModule!());

@safe:

/// Routes: /api/v2/applications
class FlexApplicationsController : ManageController {
  private ManageFlexApplicationsUseCase usecase;

  this(ManageFlexApplicationsUseCase usecase) {
    this.usecase = usecase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);
    router.get("/api/v2/applications",         &handleList);
    router.get("/api/v2/applications/*",       &handleGet);
    router.post("/api/v2/applications",        &handleCreate);
    router.put("/api/v2/applications/*",       &handleUpdate);
    router.delete_("/api/v2/applications/*",   &handleDelete);
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
        ScanJobDTO dto;
        dto.tenantId = tenantId;
      CreateFlexApplicationRequest r;
      r.tenantId       = tenantId;
      r.applicationId  = FlexApplicationId(precheck.id);
      r.namespace_     = data.getString("namespace");
      r.appId          = data.getString("appId");
      r.description_   = data.getString("description");
      r.isActive_      = j.get("isActive", Json(true)).get!bool;
      r.validFrom_     = data.getString("validFrom");
      r.validTo_       = data.getString("validTo");
      r.owner_         = data.getString("owner");
      r.version_       = data.getString("version");
      auto result = usecase.createApplication(r);
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
      FlexApplication[] apps;
      auto activeParam = req.query.get("active", "");
      if (activeParam == "true")
        apps = usecase.listActiveApplications(tenantId);
      else
        apps = usecase.listApplications(tenantId);
      auto arr = Json.emptyArray;
      foreach (a; apps) arr ~= a.toJson();
      res.writeJsonBody(Json.emptyObject.set("applications", arr).set("count", apps.length), 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  override protected Json getHandler(HTTPServerRequest req) {
        auto precheck = super.getHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
      auto id = FlexApplicationId(precheck.id);
      auto a = usecase.getApplication(tenantId, id);
      if (a.isNull) { writeError(res, 404, "FlexApplication not found"); return; }
      res.writeJsonBody(a.toJson(), 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  override protected Json updateHandler(HTTPServerRequest req) {
        auto precheck = super.updateHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
      auto id = FlexApplicationId(precheck.id);
      auto data = precheck.data;
      UpdateFlexApplicationRequest r;
      r.tenantId       = tenantId;
      r.applicationId  = id;
      r.description_   = data.getString("description");
      r.isActive_      = j.get("isActive", Json(true)).get!bool;
      r.validFrom_     = data.getString("validFrom");
      r.validTo_       = data.getString("validTo");
      r.owner_         = data.getString("owner");
      r.version_       = data.getString("version");
      auto result = usecase.updateApplication(r);
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
      auto id = FlexApplicationId(precheck.id);
      auto result = usecase.deleteApplication(tenantId, id);
      if (result.success) res.writeBody("", cast(int) HTTPStatus.noContent, "application/json");
      else writeError(res, 404, result.message);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }
}
