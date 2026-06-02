/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.kyma.presentation.http.controllers.application;




// import uim.platform.kyma.application.usecases.manage.applications;
// import uim.platform.kyma.application.dto;
// import uim.platform.kyma.domain.entities.application;
// import uim.platform.kyma.domain.types;
import uim.platform.kyma;

mixin(ShowModule!());

@safe:
class ApplicationController : ManageController {
  private ManageApplicationsUseCase usecase;

  this(ManageApplicationsUseCase usecase) {
    this.usecase = usecase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.post("/api/v1/applications", &handleRegister);
    router.get("/api/v1/applications", &handleList);
    router.get("/api/v1/applications/*", &handleGet);
    router.put("/api/v1/applications/*", &handleUpdate);
    router.post("/api/v1/applications/connect/*", &handleConnect);
    router.post("/api/v1/applications/disconnect/*", &handleDisconnect);
    router.delete_("/api/v1/applications/*", &handleDelete);
  }

  protected void handleRegister(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
      auto tenantId = precheck.tenantId;
      auto data = precheck.data;
      RegisterApplicationRequest r;
      with (r) {
        environmentId = data.getString("environmentId");
        tenantId = req.getTenantId;
        name = data.getString("name");
        description = data.getString("description");
        registrationType = data.getString("registrationType");
        connectorUrl = data.getString("connectorUrl");
        boundNamespaces = data.getStrings("boundNamespaces");
        labels = data.jsonStrMap("labels");
        createdBy = UserId(req.headers.get("X-User-Id", ""));
        // Parse APIs
        apis = j.toApis;
        events = parseEvents(j);
      }

      auto result = usecase.register(r);
      if (result.hasError)
            return errorResponse(result.message, 400);
        auto resp = Json.emptyObject
          .set("id", result.id);

        res.writeJsonBody(resp, 201);
      } else
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
      auto envId = req.params.get("environmentId");

      Application[] items = envId.isEmpty 
        ? usecase.listApplications(tenantId) 
        : usecase.listApplications(tenantId, envId);

      auto arr = items.map!(app => app.toJson).array.toJson;

      auto list = items.map!(item => item.toJson()).array.toJson;

        auto responseData = Json.emptyObject
            .set("count", list.length)
            .set("resources", list);
        return successResponse("", 0, responseData);
  }

  override protected Json getHandler(HTTPServerRequest req) {
        auto precheck = super.getHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
      auto id = ApplicationId(precheck.id);

      if (!usecase.hasApplication(tenantId, id)) {
        writeError(res, 404, "Application not found");
        return;
      }

      auto app = usecase.getApplication(tenantId, id);
      res.writeJsonBody(app.toJson, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  override protected Json updateHandler(HTTPServerRequest req) {
        auto precheck = super.updateHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
      auto id = ApplicationId(precheck.id);
      auto data = precheck.data;
      UpdateApplicationRequest r;
      r.description = data.getString("description");
      r.connectorUrl = data.getString("connectorUrl");
      r.boundNamespaces = data.getStrings("boundNamespaces");
      r.labels = data.jsonStrMap("labels");
      r.apis = j.toApis;
      r.events = parseEvents(j);

      auto tenantId = precheck.tenantId;
      auto result = usecase.updateApplication(tenantId, id, r);
      if (result.hasError)
            return errorResponse(result.message, 400);

        auto responseData = Json.emptyObject.set("id", result.id);
        return successResponse("Application updated successfully", "Updated", 200, responseData);
  }

  protected void handleConnect(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = precheck.tenantId;
      auto id = ApplicationId(precheck.id);
      auto result = usecase.connectApplication(tenantId, id);
      if (result.success)
        res.writeJsonBody(Json.emptyObject, 200);
      else
        writeError(res, 400, result.message);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  protected void handleDisconnect(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = precheck.tenantId;
      auto id = ApplicationId(precheck.id);
      auto result = usecase.disconnectApplication(tenantId, id);
      if (result.success)
        res.writeJsonBody(Json.emptyObject, 200);
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
      auto id = ApplicationId(precheck.id);
      auto result = usecase.deleteApplication(tenantId, id);
      if (result.hasError)
            return errorResponse(result.message, 400);

        auto responseData = Json.emptyObject.set("id", result.id);
        return successResponse("Application deleted successfully", "Deleted", 200, responseData);
  }

  private AppEventEntryDto[] parseEvents(Json j) {
    AppEventEntryDto[] entries;
    if ("events" !in j)
      return entries;

    auto v = j["events"];
    if (!v.isArray)
      return entries;

    foreach (item; v.toArray) {
      AppEventEntryDto entry;
      entry.name = item.getString("name");
      entry.description = item.getString("description");
      entry.version_ = item.getString("version");
      entries ~= entry;
    }
    return entries;
  }

}
