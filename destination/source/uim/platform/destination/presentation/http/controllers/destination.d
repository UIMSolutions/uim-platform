/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.destination.presentation.http.controllers.destination;

// import uim.platform.destination.application.usecases.manage.destinations;
// import uim.platform.destination.application.dto;
// import uim.platform.destination.domain.entities.destination;
// import uim.platform.destination.domain.types;
import uim.platform.destination;

// mixin(ShowModule!());

@safe:
class DestinationController : ManageHttpController {
  private ManageDestinationsUseCase usecase;

  this(ManageDestinationsUseCase usecase) {
    this.usecase = usecase;
  }

  override void registerRoutes(URLRouter router) {
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
    auto subaccountId = SubaccountId(req.headers.get("X-Subaccount-Id", ""));
    auto instanceId = ServiceInstanceId(req.params.get("serviceInstanceId", ""));

    Destination[] destinations = instanceId.isEmpty
      ? usecase.listDestinations(tenantId, subaccountId) : usecase.listDestinations(tenantId, instanceId);
    auto arr = destinations.map!(d => d.toJson).array.toJson;

    auto resp = Json.emptyObject
      .set("items", arr)
      .set("totalCount", destinations.length);

    return successResponse("Destination list retrieved successfully", "Retrieved", 200, resp);
  }

  override protected Json createHandler(HTTPServerRequest req) {
    auto precheck = super.createHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;

    auto data = precheck.data;
    CreateDestinationRequest r;
    r.tenantId = tenantId;
    r.subaccountId = req.headers.get("X-Subaccount-Id", "");
    r.serviceInstanceId = data.getString("serviceInstanceId");
    r.name = data.getString("name");
    r.description = data.getString("description");
    r.destinationType = data.getString("type");
    r.url = data.getString("url");
    r.authenticationType = data.getString("authentication");
    r.proxyType = data.getString("proxyType");
    r.level = data.getString("level");
    r.urlPath = data.getString("urlPath");
    r.httpMethod = data.getString("httpMethod");

    r.user = data.getString("user");
    r.password = data.getString("password");
    r.clientId = data.getString("clientId");
    r.clientSecret = data.getString("clientSecret");
    r.tokenServiceUrl = data.getString("tokenServiceURL");
    r.tokenServiceUser = data.getString("tokenServiceUser");
    r.tokenServicePassword = data.getString("tokenServicePassword");
    r.audience = data.getString("audience");
    r.systemUser = data.getString("systemUser");
    r.samlAudience = data.getString("samlAudience");
    r.nameIdFormat = data.getString("nameIdFormat");
    r.authnContextClassRef = data.getString("authnContextClassRef");

    r.keystoreId = data.getString("keystoreId");
    r.keystorePassword = data.getString("keystorePassword");
    r.truststoreId = data.getString("truststoreId");

    r.locationId = data.getString("locationId");
    r.sccVirtualHost = data.getString("sccVirtualHost");
    r.sccVirtualPort = data.getInteger("sccVirtualPort");

    r.properties = data.jsonStrMap("properties");
    r.fragmentIds = data.getStrings("fragmentIds");
    r.createdBy = UserId(req.headers.get("X-User-Id", ""));

    auto result = usecase.createDestination(r);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto resp = Json.emptyObject
      .set("id", result.id);

    return successResponse("Destination created successfully", "Created", 201, resp);
  }

  override protected Json getHandler(HTTPServerRequest req) {
    auto precheck = super.getHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = DestinationId(precheck.id);
    if (id.isNull)
      return errorResponse("Invalid destination ID", 400);

    auto d = usecase.getDestination(tenantId, id);
    if (d.isNull) {
      return errorResponse("Destination not found", 404);
    }

    auto responseData = d.toJson();
    return successResponse("Destination retrieved successfully", "Retrieved", 200, responseData);
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
    UpdateDestinationRequest r;
    r.tenantId = tenantId;
    r.destinationId = id;
    r.description = data.getString("description");
    r.url = data.getString("url");
    r.authenticationType = data.getString("authentication");
    r.proxyType = data.getString("proxyType");
    r.user = data.getString("user");
    r.password = data.getString("password");
    r.clientId = data.getString("clientId");
    r.clientSecret = data.getString("clientSecret");
    r.tokenServiceUrl = data.getString("tokenServiceURL");
    r.tokenServiceUser = data.getString("tokenServiceUser");
    r.tokenServicePassword = data.getString("tokenServicePassword");
    r.audience = data.getString("audience");
    r.keystoreId = data.getString("keystoreId");
    r.keystorePassword = data.getString("keystorePassword");
    r.truststoreId = data.getString("truststoreId");
    r.locationId = data.getString("locationId");
    r.sccVirtualHost = data.getString("sccVirtualHost");
    r.sccVirtualPort = data.getInteger("sccVirtualPort");
    r.status = data.getString("status");
    r.properties = data.jsonStrMap("properties");
    r.fragmentIds = data.getStrings("fragmentIds");

    auto result = usecase.updateDestination(r);
    if (result.hasError)
      return errorResponse(result.message, 400);

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
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto responseData = Json.emptyObject.set("id", result.id);
    return successResponse("Destination deleted successfully", "Deleted", 200, responseData);
  }
}
