/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.connectivity.presentation.http.controllers.connector;

// import uim.platform.connectivity.application.usecases.manage.connectors;
// import uim.platform.connectivity.application.dto;
// import uim.platform.connectivity.domain.entities.cloud_connector;
import uim.platform.connectivity;

// mixin(ShowModule!());

@safe:
class ConnectorController : ManageHttpController {
  private ManageConnectorsUseCase usecase;

  this(ManageConnectorsUseCase usecase) {
    this.usecase = usecase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.post("/api/v1/connectors", &handleRegister);
    router.get("/api/v1/connectors", &handleList);
    router.get("/api/v1/connectors/*", &handleGet);
    router.post("/api/v1/connectors/*/heartbeat", &handleHeartbeat);
    router.delete_("/api/v1/connectors/*", &handleUnregister);
  }

  protected Json registerHandler(HTTPServerRequest req) {
    auto precheck = super.postHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto data = precheck.data;
    RegisterConnectorRequest r;
    r.subaccountId = data.getString("subaccountId");
    r.tenantId = tenantId;
    r.locationId = data.getString("locationId");
    r.description = data.getString("description");
    r.connectorVersion = data.getString("connectorVersion");
    r.host = data.getString("host");
    r.port = getUshort(data, "port");
    r.tunnelEndpoint = data.getString("tunnelEndpoint");

    auto result = usecase.registerConnector(r);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto resp = Json.emptyObject.set("id", result.id);

    return successResponse("Connector registered successfully", "Created", 201, resp);
  }

  mixin(HandleTemplate!("handleRegister", "registerHandler"));

  override protected Json listHandler(HTTPServerRequest req) {
    auto precheck = super.listHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;

    auto connectors = usecase.listByTenant(tenantId);
    auto list = connectors.map!(item => item.toJson()).array.toJson;

    auto responseData = Json.emptyObject
      .set("count", list.length)
      .set("resources", list);
    return successResponse("Connectors retrieved successfully", "Retrieved", 200, responseData);
  }

  override protected Json getHandler(HTTPServerRequest req) {
    auto precheck = super.getHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = ConnectorId(precheck.id);
    if (id.isNull)
      return errorResponse("Invalid connector ID", 400);

    auto connector = usecase.getConnector(tenantId, id);
    if (connector.isNull)
      return errorResponse("Connector not found", 404);

    auto responseData = connector.toJson();
    return successResponse("Connector retrieved successfully", "Retrieved", 200, responseData);
  }

  protected Json heartbeatHandler(HTTPServerRequest req) {
    auto precheck = super.postHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto data = precheck.data;
    auto uri = req.requestURI;
    auto parts = splitPath(uri);
    if (parts.length < 5)
      return errorResponse("Invalid path", 400);
    auto connectorId = ConnectorId(parts[$ - 2]); // second-to-last segment before "heartbeat"

    HeartbeatRequest r;
    r.connectorVersion = data.getString("connectorVersion");

    auto result = usecase.heartbeat(tenantId, connectorId, r);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto resp = Json.emptyObject
      .set("status", "acknowledged")
      .set("message", "Heartbeat received");

    return successResponse("Heartbeat received successfully", "Acknowledged", 200, resp);
  }

  mixin(HandleTemplate!("handleHeartbeat", "heartbeatHandler"));

  protected Json unregisterHandler(HTTPServerRequest req) {
    auto precheck = super.deleteHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = ConnectorId(precheck.id);
    if (id.isNull)
      return errorResponse("Invalid connector ID", 400);

    auto result = usecase.unregister(tenantId, id);
    if (result.hasError)
      return errorResponse(result.message, 404);

    auto resp = Json.emptyObject.set("id", result.id);
    return successResponse("Connector unregistered successfully", "Deleted", 200, resp);
  }

  protected void handleUnregister(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto response = unregisterHandler(req);
      res.writeJsonBody(response, response.code);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private static string[] splitPath(string uri) {
    // import std.string : indexOf, split;

    auto qpos = uri.indexOf('?');
    string path = qpos >= 0 ? uri[0 .. qpos] : uri;
    string[] parts;
    foreach (seg; path.split("/"))
      if (seg.length > 0)
        parts ~= seg;
    return parts;
  }
}
