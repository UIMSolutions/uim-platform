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

mixin(ShowModule!());

@safe:
class DestinationController : ManageController {
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

  override protected void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.getTenantId;
      auto j = req.json;
      CreateDestinationRequest r;
      r.tenantId = tenantId;
      r.subaccountId = req.headers.get("X-Subaccount-Id", "");
      r.serviceInstanceId = j.getString("serviceInstanceId");
      r.name = j.getString("name");
      r.description = j.getString("description");
      r.destinationType = j.getString("type");
      r.url = j.getString("url");
      r.authenticationType = j.getString("authentication");
      r.proxyType = j.getString("proxyType");
      r.level = j.getString("level");   
      r.urlPath = j.getString("urlPath");
      r.httpMethod = j.getString("httpMethod");

      r.user = j.getString("user");
      r.password = j.getString("password");
      r.clientId = j.getString("clientId");
      r.clientSecret = j.getString("clientSecret");
      r.tokenServiceUrl = j.getString("tokenServiceURL");
      r.tokenServiceUser = j.getString("tokenServiceUser");
      r.tokenServicePassword = j.getString("tokenServicePassword");
      r.audience = j.getString("audience");
      r.systemUser = j.getString("systemUser");
      r.samlAudience = j.getString("samlAudience");
      r.nameIdFormat = j.getString("nameIdFormat");
      r.authnContextClassRef = j.getString("authnContextClassRef");

      r.keystoreId = j.getString("keystoreId");
      r.keystorePassword = j.getString("keystorePassword");
      r.truststoreId = j.getString("truststoreId");

      r.locationId = j.getString("locationId");
      r.sccVirtualHost = j.getString("sccVirtualHost");
      r.sccVirtualPort = j.getInteger("sccVirtualPort");

      r.properties = jsonStrMap(j, "properties");
      r.fragmentIds = getStrings(j, "fragmentIds");
      r.createdBy = UserId(req.headers.get("X-User-Id", ""));

      auto result = usecase.createDestination(r);
      if (result.hasError)
            return errorResponse(result.message, 400);
        auto resp = Json.emptyObject
          .set("id", result.id)
          .set("message", "Destination created successfully");

        res.writeJsonBody(resp, 201);
      } else {
        writeError(res, 400, result.message);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  override protected void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.getTenantId;
      auto subaccountId = SubaccountId(req.headers.get("X-Subaccount-Id", ""));
      auto instanceId = ServiceInstanceId(req.params.get("serviceInstanceId", ""));

      Destination[] destinations = instanceId.isEmpty
        ? usecase.listDestinations(tenantId, subaccountId) 
        : usecase.listDestinations(tenantId, instanceId);

      auto arr = destinations.map!(d => d.toJson).array.toJson;

      auto resp = Json.emptyObject
        .set("items", arr)
        .set("totalCount", destinations.length)
        .set("message", "Destinations retrieved successfully");

      res.writeJsonBody(resp, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  override protected void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.getTenantId;
      auto id = DestinationId(extractIdFromPath(req.requestURI));

      auto d = usecase.getDestination(tenantId, id);
      if (d.isNull) {
        writeError(res, 404, "Destination not found");
        return;
      }
      res.writeJsonBody(d.toJson, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  override protected void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.getTenantId;
      auto id = DestinationId(extractIdFromPath(req.requestURI));
      auto j = req.json;

      UpdateDestinationRequest r;
      r.tenantId = tenantId;
      r.destinationId = id;
      r.description = j.getString("description");
      r.url = j.getString("url");
      r.authenticationType = j.getString("authentication");
      r.proxyType = j.getString("proxyType");
      r.user = j.getString("user");
      r.password = j.getString("password");
      r.clientId = j.getString("clientId");
      r.clientSecret = j.getString("clientSecret");
      r.tokenServiceUrl = j.getString("tokenServiceURL");
      r.tokenServiceUser = j.getString("tokenServiceUser");
      r.tokenServicePassword = j.getString("tokenServicePassword");
      r.audience = j.getString("audience");
      r.keystoreId = j.getString("keystoreId");
      r.keystorePassword = j.getString("keystorePassword");
      r.truststoreId = j.getString("truststoreId");
      r.locationId = j.getString("locationId");
      r.sccVirtualHost = j.getString("sccVirtualHost");
      r.sccVirtualPort = j.getInteger("sccVirtualPort");
      r.status = j.getString("status");
      r.properties = jsonStrMap(j, "properties");
      r.fragmentIds = getStrings(j, "fragmentIds");

      auto result = usecase.updateDestination(r);
      if (result.hasError)
            return errorResponse(result.message, 400);
        auto resp = Json.emptyObject
          .set("id", result.id)
          .set("message", "Destination updated successfully");

        res.writeJsonBody(resp, 200);
      } else {
        writeError(res, result.message == "Destination not found" ? 404 : 400, result.message);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  override protected void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.getTenantId;
      auto id = DestinationId(extractIdFromPath(req.requestURI));
      
      auto result = usecase.deleteDestination(tenantId, id);
      if (result.hasError)
            return errorResponse(result.message, 400);
        auto resp = Json.emptyObject
          .set("deleted", true);

        res.writeJsonBody(resp, 200);
      } else {
        writeError(res, 404, result.message);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

}
