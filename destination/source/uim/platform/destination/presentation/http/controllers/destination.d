/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.destination.presentation.http.controllers.destination;

// import vibe.http.server;
// import vibe.http.router;
// import vibe.data.json;
// import std.conv : to;

// import uim.platform.destination.application.usecases.manage.destinations;
// import uim.platform.destination.application.dto;
// import uim.platform.destination.domain.entities.destination;
// import uim.platform.destination.domain.types;
// import uim.platform.destination.presentation.http.json_utils;
import uim.platform.destination;

mixin(ShowModule!());

@safe:
class DestinationController : PlatformController {
  private ManageDestinationsUseCase uc;

  this(ManageDestinationsUseCase uc) {
    this.uc = uc;
  }

  override void registerRoutes(URLRouter router) {
    router.post("/api/v1/destinations", &handleCreate);
    router.get("/api/v1/destinations", &handleList);
    router.get("/api/v1/destinations/*", &handleGetById);
    router.put("/api/v1/destinations/*", &handleUpdate);
    router.delete_("/api/v1/destinations/*", &handleDelete);
  }

  private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto j = req.json;
      CreateDestinationRequest r;
      r.tenantId = req.getTenantId;
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
      r.fragmentIds = jsonStrArray(j, "fragmentIds");
      r.createdBy = req.headers.get("X-User-Id", "");

      auto result = uc.create(r);
      if (result.success) {
        auto resp = Json.emptyObject;
        resp["id"] = Json(result.id);
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
      TenantId tenantId = req.getTenantId;
      auto subaccountId = SubaccountId(req.headers.get("X-Subaccount-Id", ""));
      auto instanceId = req.params.get("serviceInstanceId");

      Destination[] destinations;
      if (instanceId.length > 0)
        destinations = uc.listByServiceInstance(tenantId, ServiceInstanceId(instanceId));
      else
        destinations = uc.listBySubaccount(tenantId, subaccountId);

      auto arr = Json.emptyArray;
      foreach (d; destinations)
        arr ~= serializeDestination(d);

      auto resp = Json.emptyObject;
      resp["items"] = arr;
      resp["totalCount"] = Json(destinations.length);
      res.writeJsonBody(resp, 200);
    }
    catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleGetById(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto id = DestinationId(extractIdFromPath(req.requestURI));
      auto d = uc.getDestination(id);
      if (d.id.isEmpty) {
        writeError(res, 404, "Destination not found");
        return;
      }
      res.writeJsonBody(serializeDestination(d), 200);
    }
    catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto id = DestinationId(extractIdFromPath(req.requestURI));
      auto j = req.json;
      UpdateDestinationRequest r;
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
      r.fragmentIds = jsonStrArray(j, "fragmentIds");

      auto result = uc.updateDestination(id, r);
      if (result.success) {
        auto resp = Json.emptyObject;
        resp["id"] = Json(result.id);
        res.writeJsonBody(resp, 200);
      }
      else
      {
        writeError(res, result.error == "Destination not found" ? 404 : 400, result.error);
      }
    }
    catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto id = DestinationId(extractIdFromPath(req.requestURI));
      auto result = uc.removeDestination(id);
      if (result.success) {
        auto resp = Json.emptyObject;
        resp["deleted"] = Json(true);
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

  private static Json serializeDestination(const ref Destination d) {
    auto j = Json.emptyObject;
    j["id"] = d.id.toJson();
    j["tenantId"] = d.tenantId.toJson();
    j["subaccountId"] = d.subaccountId.toJson();
    j["serviceInstanceId"] = d.serviceInstanceId.toJson();
    j["name"] = Json(d.name);
    j["description"] = Json(d.description);
    j["type"] = Json(d.destinationType.to!string);
    j["url"] = Json(d.url);
    j["authentication"] = Json(d.authenticationType.to!string);
    j["proxyType"] = Json(d.proxyType.to!string);
    j["level"] = Json(d.level.to!string);
    j["status"] = Json(d.status.to!string);
    j["locationId"] = Json(d.locationId);

    auto propsJson = Json.emptyObject;
    foreach (k, v; d.properties)
      propsJson[k] = Json(v);
    j["properties"] = propsJson;

    auto fragArr = Json.emptyArray;
    foreach (fid; d.fragmentIds)
      fragArr ~= fid.toJson();
    j["fragmentIds"] = fragArr;

    j["createdBy"] = Json(d.createdBy);
    j["createdAt"] = Json(d.createdAt);
    j["modifiedAt"] = Json(d.modifiedAt);
    return j;
  }
}
