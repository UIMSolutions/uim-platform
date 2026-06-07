/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.connectivity.presentation.http.controllers.destination;
// import uim.platform.connectivity.application.usecases.manage.destinations;
// import uim.platform.connectivity.application.dto;
// import uim.platform.connectivity.domain.entities.destination;
import uim.platform.connectivity;

// mixin(ShowModule!());

@safe:
class DestinationController : ManageHttpController {
  private ManageDestinationsUseCase usecase;

  this(ManageDestinationsUseCase usecase) {
    this.usecase = usecase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.post("/api/v1/destinations", &handleCreate);
    router.get("/api/v1/destinations", &handleList);
    router.get("/api/v1/destinations/*", &handleGet);
    router.put("/api/v1/destinations/*", &handleUpdate);
    router.delete_("/api/v1/destinations/*", &handleDelete);
  }

  override protected Json listHandler(HTTPServerRequest req) {
    auto precheck = super.listHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;

    auto dests = usecase.listDestinations(tenantId);
    auto arr = dests.map!(d => d.toJson).array.toJson;

    auto responseData = Json.emptyObject
      .set("items", arr)
      .set("totalCount", Json(dests.length));
    return successResponse("Destination list retrieved successfully", "Retrieved", 200, responseData);
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
    r.url = data.getString("url");
    r.destinationType = data.getString("type");
    r.authType = data.getString("authentication");
    r.proxyType = data.getString("proxyType");
    r.user = data.getString("user");
    r.password = data.getString("password");
    r.clientId = data.getString("clientId");
    r.clientSecret = data.getString("clientSecret");
    r.tokenServiceUrl = data.getString("tokenServiceURL");
    r.tokenServiceUser = data.getString("tokenServiceUser");
    r.tokenServicePassword = data.getString("tokenServicePassword");
    r.certificateId = data.getString("certificateId");
    r.cloudConnectorLocationId = data.getString("cloudConnectorLocationId");

    foreach(prop; data.getArray("properties")) {
      auto key = prop.getString("key");
      auto value = prop.getString("value");
      r.properties ~= DestinationProperty(key, value);
    }

    foreach (header; data.getArray("additionalHeaders")) {
      auto key = header.getString("key");
      auto value = header.getString("value");
      r.additionalHeaders ~= DestinationProperty(key, value);
    }

    auto result = usecase.createDestination(r);
    if (result.hasError()) {
      return Json.emptyObject
        .set("message", result.message)
        .set("statusCode", 400);
    }

    auto responseData = Json.emptyObject.set("id", result.id);
    return successResponse("Destination created successfully", "Created", 201, responseData);
  }

  override protected Json getHandler(HTTPServerRequest req) {
    auto precheck = super.getHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = DestinationId(precheck.id);
    if (id.isNull)
      return errorResponse("Invalid destination ID", 400);

    auto dest = usecase.getDestination(tenantId, id);
    if (dest.isNull) 
      return errorResponse("Destination not found", 404);
    
    return successResponse("Destination retrieved successfully", "Retrieved", 200, dest.toJson);
  }

  override protected Json updateHandler(HTTPServerRequest req) {
    auto precheck = super.updateHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = DestinationId(precheck.id);
      if (id.isNull)
      return errorResponse("Invalid destination ID", 400);

    auto data = precheck.data;

    auto r = UpdateDestinationRequest();
    r.tenantId = tenantId;
    r.description = data.getString("description");
    r.url = data.getString("url");
    r.authType = data.getString("authentication");
    r.proxyType = data.getString("proxyType");
    r.user = data.getString("user");
    r.password = data.getString("password");
    r.clientId = data.getString("clientId");
    r.clientSecret = data.getString("clientSecret");
    r.tokenServiceUrl = data.getString("tokenServiceURL");
    r.tokenServiceUser = data.getString("tokenServiceUser");
    r.tokenServicePassword = data.getString("tokenServicePassword");
    r.certificateId = data.getString("certificateId");
    r.cloudConnectorLocationId = data.getString("cloudConnectorLocationId");

    foreach(prop; data.getArray("properties")) {
      auto key = prop.getString("key");
      auto value = prop.getString("value");
      r.properties ~= DestinationProperty(key, value);
    }

    foreach(header; data.getArray("additionalHeaders")) {
      auto key = header.getString("key");
      auto value = header.getString("value");
      r.additionalHeaders ~= DestinationProperty(key, value);
    }

    auto result = usecase.updateDestination(r);
    if (result.hasError())
      return errorResponse(result.message, result.message == "Destination not found" ? 404 : 400);


    auto responseData = Json.emptyObject.set("id", result.id);
    return successResponse("Destination updated successfully", "Updated", 200, responseData);
  }

  override protected Json deleteHandler(HTTPServerRequest req) {
    auto precheck = super.deleteHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = DestinationId(precheck.id);
    if (id.isNull)
      return errorResponse("Invalid destination ID", 400);

    auto result = usecase.deleteDestination(tenantId, id);
    if (result.hasError()) 
    return errorResponse(result.message, result.message == "Destination not found" ? 404 : 400);

    auto responseData = Json.emptyObject.set("id", result.id);
    return successResponse("Destination deleted successfully", "Deleted", 200, responseData);
  }
}
