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

mixin(ShowModule!());

@safe:
class DestinationController : ManageController {
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

  override protected Json listHandler(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    auto tenantId = req.getTenantId;

    auto dests = usecase.listDestinations(tenantId);
    auto arr = dests.map!(d => d.toJson).array.toJson;

    return Json.emptyObject
      .set("items", arr)
      .set("totalCount", Json(dests.length))
      .set("message", "Destinations retrieved successfully")
      .set("statusCode", 200);
  }

  override protected Json createHandler(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    auto tenantId = req.getTenantId;
    auto j = req.json;
    auto r = CreateDestinationRequest();
    r.tenantId = tenantId;
    r.name = j.getString("name");
    r.description = j.getString("description");
    r.url = j.getString("url");
    r.destinationType = j.getString("type");
    r.authType = j.getString("authentication");
    r.proxyType = j.getString("proxyType");
    r.user = j.getString("user");
    r.password = j.getString("password");
    r.clientId = j.getString("clientId");
    r.clientSecret = j.getString("clientSecret");
    r.tokenServiceUrl = j.getString("tokenServiceURL");
    r.tokenServiceUser = j.getString("tokenServiceUser");
    r.tokenServicePassword = j.getString("tokenServicePassword");
    r.certificateId = j.getString("certificateId");
    r.cloudConnectorLocationId = j.getString("cloudConnectorLocationId");

    foreach(prop; j.getArray("properties")) {
      auto key = prop.getString("key");
      auto value = prop.getString("value");
      r.properties ~= DestinationProperty(key, value);
    }

    foreach (header; j.getArray("additionalHeaders")) {
      auto key = header.getString("key");
      auto value = header.getString("value");
      r.additionalHeaders ~= DestinationProperty(key, value);
    }

    auto result = usecase.createDestination(r);
    if (result.isFailure()) {
      return Json.emptyObject
        .set("message", result.error)
        .set("statusCode", 400);
    }

    return Json.emptyObject
      .set("id", result.id)
      .set("message", "Destination created")
      .set("statusCode", 201);
  }

  override protected Json getHandler(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    auto tenantId = req.getTenantId;
    auto id = DestinationId(extractIdFromPath(req.requestURI));

    auto dest = usecase.getDestination(tenantId, id);
    if (dest.isNull) {
      return Json.emptyObject
        .set("message", "Destination not found")
        .set("statusCode", 404);
    }
    return dest.toJson
      .set("message", "Destination retrieved successfully")
      .set("statusCode", 200);
  }

  override protected Json updateHandler(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    auto tenantId = req.getTenantId;
    auto id = DestinationId(extractIdFromPath(req.requestURI));
    auto j = req.json;

    auto r = UpdateDestinationRequest();
    r.tenantId = tenantId;
    r.description = j.getString("description");
    r.url = j.getString("url");
    r.authType = j.getString("authentication");
    r.proxyType = j.getString("proxyType");
    r.user = j.getString("user");
    r.password = j.getString("password");
    r.clientId = j.getString("clientId");
    r.clientSecret = j.getString("clientSecret");
    r.tokenServiceUrl = j.getString("tokenServiceURL");
    r.tokenServiceUser = j.getString("tokenServiceUser");
    r.tokenServicePassword = j.getString("tokenServicePassword");
    r.certificateId = j.getString("certificateId");
    r.cloudConnectorLocationId = j.getString("cloudConnectorLocationId");

    foreach(prop; j.getArray("properties")) {
      auto key = prop.getString("key");
      auto value = prop.getString("value");
      r.properties ~= DestinationProperty(key, value);
    }

    foreach(header; j.getArray("additionalHeaders")) {
      auto key = header.getString("key");
      auto value = header.getString("value");
      r.additionalHeaders ~= DestinationProperty(key, value);
    }

    auto result = usecase.updateDestination(r);
    if (result.isFailure()) {
      return Json.emptyObject
        .set("message", result.error)
        .set("statusCode", result.error == "Destination not found" ? 404 : 400);
    }

    return Json.emptyObject
      .set("id", result.id)
      .set("message", "Destination updated")
      .set("statusCode", 200);
  }

  override protected Json deleteHandler(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    auto tenantId = req.getTenantId;
    auto id = DestinationId(extractIdFromPath(req.requestURI));

    auto result = usecase.deleteDestination(tenantId, id);
    if (result.isFailure()) {
        return Json.emptyObject
          .set("message", result.error)
          .set("statusCode", result.error == "Destination not found" ? 404 : 400);
    }

    return Json.emptyObject
      .set("id", result.id)
      .set("message", "Destination deleted")
      .set("statusCode", 200);
  }
}
