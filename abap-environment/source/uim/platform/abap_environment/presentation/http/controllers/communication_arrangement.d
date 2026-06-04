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


import uim.platform.abap_environment;

// mixin(ShowModule!());
@safe:

class CommunicationArrangementController : ManageHttpController {
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

  override protected Json listHandler(HTTPServerRequest req) {
    auto precheck = super.listHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;

    auto systemId = SystemInstanceId(req.headers.get("X-System-Id", ""));
    auto arrangements = usecase.listArrangements(tenantId, systemId);
    auto arr = arrangements.map!(a => a.toJson).array.toJson;

    auto resp = Json.emptyObject
      .set("items", arr)
      .set("totalCount", arrangements.length);

    return successResponse("Communication arrangement list retrieved successfully", "Retrieved", 200, resp);
  }

  override protected Json createHandler(HTTPServerRequest req) {
    auto precheck = super.createHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto data = precheck.data;

    CreateCommunicationArrangementRequest r;
    r.tenantId = precheck.tenantId;
    r.systemInstanceId = SystemInstanceId(data.getString("systemInstanceId"));
    r.scenarioId = data.getString("scenarioId");
    r.name = data.getString("name");
    r.description = data.getString("description");
    r.direction = data.getString("direction");
    r.authMethod = data.getString("authMethod");
    r.communicationUser = data.getString("communicationUser");
    r.communicationPassword = data.getString("communicationPassword");
    r.clientId = data.getString("clientId");
    r.clientSecret = data.getString("clientSecret");
    r.tokenEndpoint = data.getString("tokenEndpoint");
    r.certificateId = data.getString("certificateId");

    auto result = usecase.createArrangement(r);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto responseData = Json.emptyObject.set("id", result.id);
    return successResponse("Communication arrangement created successfully", "Created", 201, responseData);
  }

  override protected Json getHandler(HTTPServerRequest req) {
    auto precheck = super.getHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;

    auto id = CommunicationArrangementId(precheck.id);
    if (id.isNull)
      return errorResponse("Invalid communication arrangement ID", 400);

    auto arrangement = usecase.getArrangement(tenantId, id);
    if (arrangement.isNull)
      return errorResponse("Communication arrangement not found", 404);

    auto responseData = job.toJson();
    return successResponse("Communication arrangement retrieved successfully", "Retrieved", 200, responseData);
  }

  override protected Json updateHandler(HTTPServerRequest req) {
    auto precheck = super.updateHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = CommunicationArrangementId(precheck.id);
    if (id.isNull)
      return errorResponse("Invalid communication arrangement ID", 400);

    auto data = precheck.data;
    UpdateCommunicationArrangementRequest r;
    r.tenantId = precheck.tenantId;
    r.communicationArrangementId = id;
    r.description = data.getString("description");
    r.status = data.getString("status");
    r.authMethod = data.getString("authMethod");
    r.communicationUser = data.getString("communicationUser");
    r.communicationPassword = data.getString("communicationPassword");
    r.clientId = data.getString("clientId");
    r.clientSecret = data.getString("clientSecret");
    r.tokenEndpoint = data.getString("tokenEndpoint");

    auto result = usecase.updateArrangement(r);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto responseData = Json.emptyObject.set("id", result.id);
    return successResponse("Communication arrangement updated successfully", "Updated", 200, responseData);
  }

  override protected Json deleteHandler(HTTPServerRequest req) {
    auto precheck = super.deleteHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;

    auto id = CommunicationArrangementId(precheck.id);
    if (id.isNull)
      return errorResponse("Invalid communication arrangement ID", 400);

    auto result = usecase.deleteArrangement(tenantId, id);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto responseData = Json.emptyObject.set("id", result.id);
    return successResponse("Communication arrangement deleted successfully", "Deleted", 200, responseData);
  }
}
