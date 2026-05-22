/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.abap_environment.presentation.http.controllers.communication_arrangement;


// 
// 
// import uim.platform.abap_environment.application.usecases.manage.communication_arrangements;
// import uim.platform.abap_environment.application.dto;
// import uim.platform.abap_environment.domain.entities.communication_arrangement;
// import uim.platform.abap_environment.domain.types;

import uim.platform.abap_environment;

mixin(ShowModule!());
@safe:

class CommunicationArrangementController : PlatformController {
  private ManageCommunicationArrangementsUseCase usecase;

  this(ManageCommunicationArrangementsUseCase usecase) {
    this.usecase = usecase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.post("/api/v1/communication-arrangements", &handleCreate);
    router.get("/api/v1/communication-arrangements", &handleList);
    router.get("/api/v1/communication-arrangements/*", &handleGet);
    router.put("/api/v1/communication-arrangements/*", &handleUpdate);
    router.delete_("/api/v1/communication-arrangements/*", &handleDelete);
  }

  protected void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.getTenantId;

      auto j = req.json;
      CreateCommunicationArrangementRequest r;
      r.tenantId = tenantId;
      r.systemInstanceId = SystemInstanceId(j.getString("systemInstanceId"));
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

      auto result = usecase.createArrangement(r);
      if (result.isSuccess()) {
        auto resp = Json.emptyObject
          .set("id", result.id)
          .set("message", "Communication arrangement created successfully");

        res.writeJsonBody(resp, 201);
      } else {
        writeError(res, 400, result.message);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  protected void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.getTenantId;
      auto systemId = SystemInstanceId(req.headers.get("X-System-Id", ""));
      auto arrangements = usecase.listArrangements(tenantId, systemId);
      auto arr = arrangements.map!(a => a.toJson).array.toJson;

      auto resp = Json.emptyObject
        .set("items", arr)
        .set("totalCount", arrangements.length)
        .set("message", "Communication arrangements fetched successfully");

      res.writeJsonBody(resp, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  protected void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.getTenantId;
      auto id = CommunicationArrangementId(extractIdFromPath(req.requestURI));

      auto arrangement = usecase.getArrangement(tenantId, id);
      if (arrangement.isNull) {
        writeError(res, 404, "Communication arrangement not found");
        return;
      }

      auto response = Json.emptyObject
        .set("item", arrangement.toJson)
        .set("message", "Communication arrangement retrieved successfully");

      res.writeJsonBody(response, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  protected void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.getTenantId;
      auto id = CommunicationArrangementId(extractIdFromPath(req.requestURI));

      auto j = req.json;
      UpdateCommunicationArrangementRequest r;
      r.tenantId = tenantId;
      r.communicationArrangementId = id;
      r.description = j.getString("description");
      r.status = j.getString("status");
      r.authMethod = j.getString("authMethod");
      r.communicationUser = j.getString("communicationUser");
      r.communicationPassword = j.getString("communicationPassword");
      r.clientId = j.getString("clientId");
      r.clientSecret = j.getString("clientSecret");
      r.tokenEndpoint = j.getString("tokenEndpoint");

      auto result = usecase.updateArrangement(r);
      if (result.isSuccess()) {
        auto response = Json.emptyObject
          .set("status", "updated")
          .set("message", "Communication arrangement updated successfully");

        res.writeJsonBody(response, 200);
      } else {
        writeError(res, 400, result.message);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  protected void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.getTenantId;
      auto id = CommunicationArrangementId(extractIdFromPath(req.requestURI));

      auto result = usecase.deleteArrangement(tenantId, id);
      if (result.isSuccess()) {
        auto resp = Json.emptyObject
          .set("status", "deleted")
          .set("message", "Communication arrangement deleted successfully");

        res.writeJsonBody(resp, 200);
      } else {
        writeError(res, 404, result.message);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }
}
