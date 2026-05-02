/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.connectivity.presentation.http.controllers.destination;

// import vibe.http.server;
// import vibe.http.router;
// import vibe.data.json;
// import std.conv : to;

// import uim.platform.connectivity.application.usecases.manage.destinations;
// import uim.platform.connectivity.application.dto;
// import uim.platform.connectivity.domain.entities.destination;
import uim.platform.connectivity;

mixin(ShowModule!());

@safe:
class DestinationController : PlatformController {
  private ManageDestinationsUseCase uc;

  this(ManageDestinationsUseCase uc) {
    this.uc = uc;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.post("/api/v1/destinations", &handleCreate);
    router.get("/api/v1/destinations", &handleList);
    router.get("/api/v1/destinations/*", &handleGetById);
    router.put("/api/v1/destinations/*", &handleUpdate);
    router.delete_("/api/v1/destinations/*", &handleDelete);
  }

  private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto j = req.json;
      auto r = CreateDestinationRequest();
      r.tenantId = req.getTenantId;
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
      r.properties = parseProperties(j);
      r.additionalHeaders = parseHeaders(j);

      auto result = uc.createDestination(r);
      if (result.success) {
        auto resp = Json.emptyObject
          .set("id", result.id)
          .set("message", "Destination created");

        res.writeJsonBody(resp, 201);
      } else {
        writeError(res, 400, result.error);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      TenantId tenantId = req.getTenantId;
      auto dests = uc.listDestinations(tenantId);

      auto arr = dests.map!(d => serializeDest(d)).array;

      auto resp = Json.emptyObject
        .set("items", arr)
        .set("totalCount", Json(dests.length))
        .set("message", "Destinations retrieved successfully");

      res.writeJsonBody(resp, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleGetById(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto id = extractIdFromPath(req.requestURI);
      auto dest = uc.getDestination(id);
      if (dest.isNull) {
        writeError(res, 404, "Destination not found");
        return;
      }
      res.writeJsonBody(dest.toJson, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto id = extractIdFromPath(req.requestURI);
      auto j = req.json;
      auto r = UpdateDestinationRequest();
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
      r.properties = parseProperties(j);
      r.additionalHeaders = parseHeaders(j);

      auto result = uc.updateDestination(id, r);
      if (result.success) {
        auto resp = Json.emptyObject
          .set("id", result.id)
          .set("message", "Destination updated");

        res.writeJsonBody(resp, 200);
      } else {
        writeError(res, result.error == "Destination not found" ? 404 : 400, result.error);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto id = extractIdFromPath(req.requestURI);
      auto result = uc.deleteDestination(id);
      if (result.success) {
        auto resp = Json.emptyObject
          .set("deleted", true)
          .set("message", "Destination deleted");

        res.writeJsonBody(resp, 200);
      } else {
        writeError(res, 404, result.error);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private static Json serializeDest(const Destination d) {
    auto j = Json.emptyObject
      .set("id", d.id)
      .set("tenantId", d.tenantId)
      .set("name", d.name)
      .set("description", d.description)
      .set("url", d.url)
      .set("type", d.destinationType.to!string)
      .set("authentication", d.authType.to!string)
      .set("proxyType", d.proxyType.to!string)
      .set("cloudConnectorLocationId", d.cloudConnectorLocationId);

    if (d.properties.length > 0) {
      auto props = Json.emptyArray;
      foreach (p; d.properties) {
        props ~= Json.emptyObject
          .set("key", p.key)
          .set("value", p.value);
      }
      j["properties"] = props;
    }

    if (d.additionalHeaders.length > 0) {
      auto hdrs = Json.emptyArray;
      foreach (h; d.additionalHeaders) {
        hdrs ~= Json.emptyObject
          .set("key", h.key)
          .set("value", h.value);
      }
      j["additionalHeaders"] = hdrs;
    }

    return j
      .set("createdBy", d.createdBy)
      .set("createdAt", d.createdAt)
      .set("updatedAt", d.updatedAt);
  }

  private static DestinationProperty[] parseProperties(Json j) {
    DestinationProperty[] result;
    auto v = "properties" in j;
    if (v.isNull || (v).type != Json.Type.array)
      return result;
    foreach (item; *v) {
      if (item.isObject)
        result ~= DestinationProperty(item.getString("key"), item.getString("value"));
    }
    return result;
  }

  private static DestinationProperty[] parseHeaders(Json j) {
    DestinationProperty[] result;
    auto v = "additionalHeaders" in j;
    if (v.isNull || (v).type != Json.Type.array)
      return result;
    foreach (item; *v) {
      if (item.isObject)
        result ~= DestinationProperty(item.getString("key"), item.getString("value"));
    }
    return result;
  }
}
