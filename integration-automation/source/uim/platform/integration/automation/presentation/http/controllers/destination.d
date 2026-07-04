/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.integration.automation.presentation.http.controllers.destination;

// import uim.platform.integration.automation.application.usecases.manage.destinations;
// import uim.platform.integration.automation.application.dto;
// import uim.platform.integration.automation.domain.types;
// import uim.platform.integration.automation.domain.entities.destination;
// import uim.platform.integration.automation.presentation.http.scenario_controller : parseSystemType;
import uim.platform.integration.automation;

mixin(ShowModule!());

@safe:
class DestinationController : ManageHttpController {
  private ManageDestinationsUseCase useCase;

  this(ManageDestinationsUseCase useCase) {
    this.useCase = useCase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.post("/api/v1/destinations", &handleCreate);
    router.get("/api/v1/destinations", &handleList);
    router.get("/api/v1/destinations/*", &handleGet);
    router.put("/api/v1/destinations/*", &handleUpdate);
    router.delete_("/api/v1/destinations/*", &handleDelete);
  }

  override protected Json createHandler(HTTPServerRequest req) {
    auto precheck = super.createHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;

    auto data = precheck.data;
    auto r = CreateDestinationRequest();
    r.tenantId = tenantId;
    r.name = data.getString("name");
    r.description = data.getString("description");
    r.systemId = data.getString("systemId");
    r.destinationType = toDestinationType(data.getString("destinationType"));
    r.url = data.getString("url");
    r.authenticationType = toAuthenticationType(data.getString("authenticationType"));
    r.proxyType = toProxyType(data.getString("proxyType"));
    r.cloudConnectorLocationId = data.getString("cloudConnectorLocationId");
    r.user = data.getString("user");
    r.tokenServiceUrl = data.getString("tokenServiceUrl");
    r.tokenServiceUser = data.getString("tokenServiceUser");
    r.audience = data.getString("audience");
    r.scope_ = data.getString("scope");
    r.createdBy = UserId(data.getString("createdBy"));

    auto result = useCase.createDestination(r);
    if (result.hasError)
      return errorResponse(result.message, 400);

    return successResponse("Destination created successfully", "Created", 201, Json.emptyObject.set("id", result
        .id));
  }

  override protected Json listHandler(HTTPServerRequest req) {
    auto precheck = super.listHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto destinations = useCase.listDestinations(tenantId);

    auto arr = destinations.map!(d => d.toJson).array.toJson;

    auto resp = Json.emptyObject
      .set("items", arr)
      .set("totalCount", destinations.length);

    return successResponse("Destinations retrieved successfully", "OK", 200, resp);
  }

  override protected Json getHandler(HTTPServerRequest req) {
    auto precheck = super.getHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = precheck.id;
    auto tenantId = precheck.tenantId;
    auto dest = useCase.getDestination(tenantId, id);
    if (dest.isNull)
      return errorResponse("Destination not found", 404);

    auto responseData = dest.toJson;
    return successResponse("Destination retrieved successfully", 200, responseData);
  }

  override protected Json updateHandler(HTTPServerRequest req) {
    auto precheck = super.updateHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = DestinationId(precheck.id);
    if (id.isNull)
      return errorResponse("Destination not found", 404);

    auto data = precheck.data;
    auto r = UpdateDestinationRequest();
    r.id = id;
    r.tenantId = tenantId;
    r.name = data.getString("name");
    r.description = data.getString("description");
    r.systemId = data.getString("systemId");
    r.destinationType = toDestinationType(data.getString("destinationType"));
    r.url = data.getString("url");
    r.authenticationType = toAuthenticationType(data.getString("authenticationType"));
    r.proxyType = toProxyType(data.getString("proxyType"));
    r.cloudConnectorLocationId = data.getString("cloudConnectorLocationId");
    r.user = data.getString("user");
    r.tokenServiceUrl = data.getString("tokenServiceUrl");
    r.tokenServiceUser = data.getString("tokenServiceUser");
    r.audience = data.getString("audience");
    r.scope_ = data.getString("scope");
    r.isEnabled = data.getBoolean("isEnabled", true);

    auto result = useCase.updateDestination(r);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto resp = Json.emptyObject.set("id", result.id);
    return successResponse("Destination updated successfully", 200, resp);
  }

  override protected Json deleteHandler(HTTPServerRequest req) {
    auto precheck = super.deleteHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = precheck.id;
    auto tenantId = precheck.tenantId;
    auto result = useCase.deleteDestination(tenantId, id);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto resp = Json.emptyObject.set("id", result.id);
    return successResponse("Destination deleted successfully", 200, resp);
  }
}
