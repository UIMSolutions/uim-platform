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
class ApplicationController : PlatformController {
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
      auto tenantId = req.getTenantId;
      auto j = req.json;
      RegisterApplicationRequest r;
      with (r) {
        environmentId = j.getString("environmentId");
        tenantId = req.getTenantId;
        name = j.getString("name");
        description = j.getString("description");
        registrationType = j.getString("registrationType");
        connectorUrl = j.getString("connectorUrl");
        boundNamespaces = getStrings(j, "boundNamespaces");
        labels = jsonStrMap(j, "labels");
        createdBy = UserId(req.headers.get("X-User-Id", ""));
        // Parse APIs
        apis = j.toApis;
        events = parseEvents(j);
      }

      auto result = usecase.register(r);
      if (result.success) {
        auto resp = Json.emptyObject
          .set("id", result.id);

        res.writeJsonBody(resp, 201);
      } else
        writeError(res, 400, result.message);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  protected void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.getTenantId;
      auto envId = req.params.get("environmentId");

      Application[] items = envId.isEmpty 
        ? usecase.listApplications(tenantId) 
        : usecase.listApplications(tenantId, envId);

      auto arr = items.map!(app => app.toJson).array.toJson;

      auto resp = Json.emptyObject
        .set("items", arr)
        .set("totalCount", items.length);

      res.writeJsonBody(resp, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  protected void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.getTenantId;
      auto id = ApplicationId(extractIdFromPath(req.requestURI));

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

  protected void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto id = ApplicationId(extractIdFromPath(req.requestURI));
      auto j = req.json;
      UpdateApplicationRequest r;
      r.description = j.getString("description");
      r.connectorUrl = j.getString("connectorUrl");
      r.boundNamespaces = getStrings(j, "boundNamespaces");
      r.labels = jsonStrMap(j, "labels");
      r.apis = j.toApis;
      r.events = parseEvents(j);

      auto tenantId = req.getTenantId;
      auto result = usecase.updateApplication(tenantId, id, r);
      if (result.success)
        res.writeJsonBody(Json.emptyObject, 200);
      else
        writeError(res, 400, result.message);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  protected void handleConnect(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.getTenantId;
      auto id = ApplicationId(extractIdFromPath(req.requestURI));
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
      auto tenantId = req.getTenantId;
      auto id = ApplicationId(extractIdFromPath(req.requestURI));
      auto result = usecase.disconnectApplication(tenantId, id);
      if (result.success)
        res.writeJsonBody(Json.emptyObject, 200);
      else
        writeError(res, 400, result.message);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  protected void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.getTenantId;
      auto id = ApplicationId(extractIdFromPath(req.requestURI));
      auto result = usecase.deleteApplication(tenantId, id);
      if (result.success)
        res.writeBody("", 204);
      else
        writeError(res, 404, result.message);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
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
