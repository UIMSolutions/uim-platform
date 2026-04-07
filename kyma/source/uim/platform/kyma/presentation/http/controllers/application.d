/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.kyma.presentation.http.application;

// import vibe.http.server;
// import vibe.http.router;
// import vibe.data.json;
// import std.conv : to;

import uim.platform.kyma.application.usecases.manage.applications;
import uim.platform.kyma.application.dto;
import uim.platform.kyma.domain.entities.application;
import uim.platform.kyma.domain.types;
import uim.platform.kyma.presentation.http.json_utils;

class ApplicationController {
  private ManageApplicationsUseCase uc;

  this(ManageApplicationsUseCase uc) {
    this.uc = uc;
  }

  override void registerRoutes(URLRouter router) {
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
      r.environmentId = j.getString("environmentId");
      r.tenantId = req.headers.get("X-Tenant-Id", "");
      r.name = j.getString("name");
      r.description = j.getString("description");
      r.registrationType = j.getString("registrationType");
      r.connectorUrl = j.getString("connectorUrl");
      r.boundNamespaces = jsonStrArray(j, "boundNamespaces");
      r.labels = jsonStrMap(j, "labels");
      r.createdBy = req.headers.get("X-User-Id", "");

      // Parse APIs
      r.apis = parseApis(j);
      r.events = parseEvents(j);

      auto result = uc.register(r);
      if (result.success) {
        auto resp = Json.emptyObject;
        resp["id"] = Json(result.id);
        res.writeJsonBody(resp, 201);
      }
      else
        writeError(res, 400, result.error);
    }
    catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto envId = req.params.get("environmentId");
      auto tenantId = req.headers.get("X-Tenant-Id", "");

      Application[] items;
      if (envId.length > 0)
        items = uc.listByEnvironment(envId);
      else
        items = uc.listByTenant(tenantId);

      auto arr = Json.emptyArray;
      foreach (ref app; items)
        arr ~= serializeApp(app);

      auto resp = Json.emptyObject;
      resp["items"] = arr;
      resp["totalCount"] = Json(cast(long) items.length);
      res.writeJsonBody(resp, 200);
    }
    catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleGetById(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto id = extractIdFromPath(req.requestURI);
      auto app = uc.getApplication(id);
      if (app.id.length == 0) {
        writeError(res, 404, "Application not found");
        return;
      }
      res.writeJsonBody(serializeApp(app), 200);
    }
    catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto id = extractIdFromPath(req.requestURI);
      auto j = req.json;
      UpdateApplicationRequest r;
      r.description = j.getString("description");
      r.connectorUrl = j.getString("connectorUrl");
      r.boundNamespaces = jsonStrArray(j, "boundNamespaces");
      r.labels = jsonStrMap(j, "labels");
      r.apis = parseApis(j);
      r.events = parseEvents(j);

      auto result = uc.updateApplication(id, r);
      if (result.success)
        res.writeJsonBody(Json.emptyObject, 200);
      else
        writeError(res, 400, result.error);
    }
    catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleConnect(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto id = extractIdFromPath(req.requestURI);
      auto result = uc.connectApplication(id);
      if (result.success)
        res.writeJsonBody(Json.emptyObject, 200);
      else
        writeError(res, 400, result.error);
    }
    catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleDisconnect(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto id = extractIdFromPath(req.requestURI);
      auto result = uc.disconnectApplication(id);
      if (result.success)
        res.writeJsonBody(Json.emptyObject, 200);
      else
        writeError(res, 400, result.error);
    }
    catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto id = extractIdFromPath(req.requestURI);
      auto result = uc.deleteApplication(id);
      if (result.success)
        res.writeBody("", 204);
      else
        writeError(res, 404, result.error);
    }
    catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private AppApiEntryDto[] parseApis(Json j) {
    AppApiEntryDto[] entries;
    auto v = "apis" in j;
    if (v is null || (*v).type != Json.Type.array)
      return entries;
    foreach (item; *v) {
      AppApiEntryDto entry;
      entry.name = item.getString("name");
      entry.description = item.getString("description");
      entry.targetUrl = item.getString("targetUrl");
      entry.specUrl = item.getString("specUrl");
      entry.authType = item.getString("authType");
      entries ~= entry;
    }
    return entries;
  }

  private AppEventEntryDto[] parseEvents(Json j) {
    AppEventEntryDto[] entries;
    auto v = "events" in j;
    if (v is null || (*v).type != Json.Type.array)
      return entries;
    foreach (item; *v) {
      AppEventEntryDto entry;
      entry.name = item.getString("name");
      entry.description = item.getString("description");
      entry.version_ = item.getString("version");
      entries ~= entry;
    }
    return entries;
  }

  private Json serializeApp(ref Application app) {
    auto j = Json.emptyObject;
    j["id"] = Json(app.id);
    j["environmentId"] = Json(app.environmentId);
    j["tenantId"] = Json(app.tenantId);
    j["name"] = Json(app.name);
    j["description"] = Json(app.description);
    j["status"] = Json(app.status.to!string);
    j["registrationType"] = Json(app.registrationType.to!string);
    j["connectorUrl"] = Json(app.connectorUrl);
    j["boundNamespaces"] = serializeStrArray(app.boundNamespaces);
    j["labels"] = serializeStrMap(app.labels);
    j["createdBy"] = Json(app.createdBy);
    j["createdAt"] = Json(app.createdAt);
    j["modifiedAt"] = Json(app.modifiedAt);

    auto apisArr = Json.emptyArray;
    foreach (ref a; app.apis) {
      auto aj = Json.emptyObject;
      aj["name"] = Json(a.name);
      aj["description"] = Json(a.description);
      aj["targetUrl"] = Json(a.targetUrl);
      aj["specUrl"] = Json(a.specUrl);
      aj["authType"] = Json(a.authType);
      apisArr ~= aj;
    }
    j["apis"] = apisArr;

    auto eventsArr = Json.emptyArray;
    foreach (ref e; app.events) {
      auto ej = Json.emptyObject;
      ej["name"] = Json(e.name);
      ej["description"] = Json(e.description);
      ej["version"] = Json(e.version_);
      eventsArr ~= ej;
    }
    j["events"] = eventsArr;

    return j;
  }
}
