/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.kyma.presentation.http.controllers.application;

// import vibe.http.server;
// import vibe.http.router;
// import vibe.data.json;
// import std.conv : to;

// import uim.platform.kyma.application.usecases.manage.applications;
// import uim.platform.kyma.application.dto;
// import uim.platform.kyma.domain.entities.application;
// import uim.platform.kyma.domain.types;
// import uim.platform.kyma.presentation.http.json_utils;
import uim.platform.kyma;

mixin(ShowModule!());

@safe:
class ApplicationController : PlatformController {
  private ManageApplicationsUseCase uc;

  this(ManageApplicationsUseCase uc) {
    this.uc = uc;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.post("/api/v1/applications", &handleRegister);
    router.get("/api/v1/applications", &handleList);
    router.get("/api/v1/applications/*", &handleGetById);
    router.put("/api/v1/applications/*", &handleUpdate);
    router.post("/api/v1/applications/connect/*", &handleConnect);
    router.post("/api/v1/applications/disconnect/*", &handleDisconnect);
    router.delete_("/api/v1/applications/*", &handleDelete);
  }

  private void handleRegister(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto j = req.json;
      RegisterApplicationRequest r;
      with (r) {
        environmentId = j.getString("environmentId");
        tenantId = req.getTenantId;
        name = j.getString("name");
        description = j.getString("description");
        registrationType = j.getString("registrationType");
        connectorUrl = j.getString("connectorUrl");
        boundNamespaces = getStringArray(j, "boundNamespaces");
        labels = jsonStrMap(j, "labels");
        createdBy = req.headers.get("X-User-Id", "");
        // Parse APIs
        apis = j.toApis;
        events = parseEvents(j);
      }

      auto result = uc.register(r);
      if (result.success) {
        auto resp = Json.emptyObject;
        resp["id"] = Json(result.id);
        res.writeJsonBody(resp, 201);
      } else
        writeError(res, 400, result.error);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto envId = req.params.get("environmentId");
      TenantId tenantId = req.getTenantId;

      Application[] items;
      if (envId.length > 0)
        items = uc.listByEnvironment(envId);
      else
        items = uc.listByTenant(tenantId);

      auto arr = Json.emptyArray;
      foreach (app; items)
        arr ~= serializeApp(app);

      auto resp = Json.emptyObject
      .set("items", arr)
      .set("totalCount", items.length);

      res.writeJsonBody(resp, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleGetById(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      ApplicationId id = extractIdFromPath(req.requestURI);
      if (!uc.hasApplication(id)) {
        writeError(res, 404, "Application not found");
        return;
      }

      auto app = uc.getApplication(id);
      res.writeJsonBody(serializeApp(app), 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      ApplicationId id = extractIdFromPath(req.requestURI);
      auto j = req.json;
      UpdateApplicationRequest r;
      r.description = j.getString("description");
      r.connectorUrl = j.getString("connectorUrl");
      r.boundNamespaces = getStringArray(j, "boundNamespaces");
      r.labels = jsonStrMap(j, "labels");
      r.apis = j.toApis;
      r.events = parseEvents(j);

      auto result = uc.updateApplication(id, r);
      if (result.success)
        res.writeJsonBody(Json.emptyObject, 200);
      else
        writeError(res, 400, result.error);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleConnect(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      ApplicationId id = extractIdFromPath(req.requestURI);
      auto result = uc.connectApplication(id);
      if (result.success)
        res.writeJsonBody(Json.emptyObject, 200);
      else
        writeError(res, 400, result.error);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleDisconnect(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto result = uc.disconnectApplication(extractIdFromPath(req.requestURI));
      if (result.success)
        res.writeJsonBody(Json.emptyObject, 200);
      else
        writeError(res, 400, result.error);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto result = uc.deleteApplication(extractIdFromPath(req.requestURI));
      if (result.success)
        res.writeBody("", 204);
      else
        writeError(res, 404, result.error);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private AppEventEntryDto[] parseEvents(Json j) {
    AppEventEntryDto[] entries;
    if("events" !in j)
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

  private Json serializeApp(Application app) {
    auto j = Json.emptyObject
      .set("id", app.id)
      .set("environmentId", app.environmentId)
      .set("tenantId", app.tenantId)
      .set("name", app.name)
      .set("description", app.description)
      .set("status", app.status.to!string)
      .set("registrationType", app.registrationType.to!string)
      .set("connectorUrl", app.connectorUrl)
      .set("boundNamespaces", serializeStrArray(app.boundNamespaces))
      .set("labels", serializeStrMap(app.labels))
      .set("createdBy", app.createdBy)
      .set("createdAt", app.createdAt)
      .set("modifiedAt", app.modifiedAt);

    auto apisArr = Json.emptyArray;
    foreach (a; app.apis) {
      apisArr ~= Json.emptyObject
        .set("name", a.name)
        .set("description", a.description)
        .set("targetUrl", a.targetUrl)
        .set("specUrl", a.specUrl)
        .set("authType", a.authType);
    }
    j["apis"] = apisArr;

    auto eventsArr = Json.emptyArray;
    foreach (e; app.events) {
      eventsArr ~= Json.emptyObject
        .set("name", e.name)
        .set("description", e.description)
        .set("version", e.version_);
    }
    j["events"] = eventsArr;

    return j;
  }
}
