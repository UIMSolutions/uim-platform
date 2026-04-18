/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.abap_enviroment.http.controllers.communication_arrangement;

// import vibe.http.server;
// import vibe.http.router;
// import vibe.data.json;
// // import std.conv : to;
// 
// import uim.platform.abap_enviroment.application.usecases.manage.communication_arrangements;
// import uim.platform.abap_enviroment.application.dto;
// import uim.platform.abap_enviroment.domain.entities.communication_arrangement;
// import uim.platform.abap_enviroment.domain.types;

import uim.platform.abap_enviroment;

mixin(ShowModule!());
@safe:

class CommunicationArrangementController : PlatformController {
  private ManageCommunicationArrangementsUseCase uc;

  this(ManageCommunicationArrangementsUseCase uc) {
    this.uc = uc;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.post("/api/v1/communication-arrangements", &handleCreate);
    router.get("/api/v1/communication-arrangements", &handleList);
    router.get("/api/v1/communication-arrangements/*", &handleGetById);
    router.put("/api/v1/communication-arrangements/*", &handleUpdate);
    router.delete_("/api/v1/communication-arrangements/*", &handleDelete);
  }

  private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto j = req.json;
      CreateCommunicationArrangementRequest r;
      r.tenantId = req.getTenantId;
      r.systemInstanceId = j.getString("systemInstanceId");
      r.scenarioId = j.getString("scenarioId");
      r.name = j.getString("name");
      r.description = j.getString("description");
      r.direction = j.getString("direction");
      r.authMethod = j.getString("authMethod");
      r.communicationUser = j.getString("communicationUser");
      r.communicationPassword = j.getString("communicationPassword");
      r.clientId = j.getString("clientId");
      r.clientSecret = j.getString("clientSecret");
      r.tokenEndpoint = j.getString("tokenEndpoint");
      r.certificateId = j.getString("certificateId");

      auto result = uc.createArrangement(r);
      if (result.isSuccess()) {
        auto resp = Json.emptyObject
          .set("id", result.id);
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
      auto systemId = req.headers.get("X-System-Id", "");
      auto arrangements = uc.listArrangements(systemId);
      auto arr = Json.emptyArray;
      foreach (a; arrangements)
        arr ~= serializeArrangement(a);
      auto resp = Json.emptyObject
        .set("items", arr)
        .set("totalCount", arrangements.length);
        
      res.writeJsonBody(resp, 200);
    }
    catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleGetById(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto id = extractIdFromPath(req.requestURI);
      auto arrangement = uc.getArrangement(id);
      if (arrangement is null) {
        writeError(res, 404, "Communication arrangement not found");
        return;
      }
      res.writeJsonBody(serializeArrangement(*arrangement), 200);
    }
    catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto id = extractIdFromPath(req.requestURI);
      auto j = req.json;
      UpdateCommunicationArrangementRequest r;
      r.description = j.getString("description");
      r.status = j.getString("status");
      r.authMethod = j.getString("authMethod");
      r.communicationUser = j.getString("communicationUser");
      r.communicationPassword = j.getString("communicationPassword");
      r.clientId = j.getString("clientId");
      r.clientSecret = j.getString("clientSecret");
      r.tokenEndpoint = j.getString("tokenEndpoint");

      auto result = uc.updateArrangement(id, r);
      if (result.isSuccess()) {
        auto response = Json.emptyObject.
        .set("status", "updated");

        res.writeJsonBody(response, 200);
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

  private void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto id = extractIdFromPath(req.requestURI);
      auto result = uc.deleteArrangement(id);
      if (result.isSuccess()) {
        auto resp = Json.emptyObject
        .set("status", "deleted");
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

  private static Json serializeArrangement(const CommunicationArrangement a) {
    return Json.emptyObject
    .set("id", a.id)
    .set("tenantId", a.tenantId)
    .set("systemInstanceId", a.systemInstanceId)
    .set("scenarioId", a.scenarioId)
    .set("name", a.name)
    .set("description", a.description)
    .set("direction", a.direction.to!string)
    .set("status", a.status.to!string)
    .set("authMethod", a.authMethod.to!string)
    .set("communicationUser", a.communicationUser)
    .set("createdAt", a.createdAt)
    .set("updatedAt", a.updatedAt);
  }
}
