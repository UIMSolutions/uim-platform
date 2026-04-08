/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.connectivity.presentation.http.controllers.channel;

// import vibe.http.server;
// import vibe.http.router;
// import vibe.data.json;
// import std.conv : to;

import uim.platform.connectivity.application.usecases.manage.channels;
import uim.platform.connectivity.application.dto;
import uim.platform.connectivity.domain.entities.service_channel;

class ChannelController : SAPController {
  private ManageChannelsUseCase uc;

  this(ManageChannelsUseCase uc) {
    this.uc = uc;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.post("/api/v1/channels", &handleCreate);
    router.get("/api/v1/channels", &handleList);
    router.get("/api/v1/channels/*", &handleGetById);
    router.post("/api/v1/channels/*/open", &handleOpen);
    router.post("/api/v1/channels/*/close", &handleClose);
    router.delete_("/api/v1/channels/*", &handleDelete);
  }

  private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto j = req.json;
      auto r = CreateChannelRequest();
      r.connectorId = j.getString("connectorId");
      r.tenantId = req.getTenantId;
      r.name = j.getString("name");
      r.channelType = j.getString("type");
      r.virtualHost = j.getString("virtualHost");
      r.virtualPort = jsonUshort(j, "virtualPort");
      r.backendHost = j.getString("backendHost");
      r.backendPort = jsonUshort(j, "backendPort");

      auto result = uc.createChannel(r);
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
      auto channels = uc.listByTenant(tenantId);

      auto arr = Json.emptyArray;
      foreach (ref ch; channels)
        arr ~= serializeChannel(ch);

      auto resp = Json.emptyObject;
      resp["items"] = arr;
      resp["totalCount"] = Json(cast(long) channels.length);
      res.writeJsonBody(resp, 200);
    }
    catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleGetById(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto id = extractIdFromPath(req.requestURI);
      auto ch = uc.getChannel(id);
      if (ch.id.length == 0) {
        writeError(res, 404, "Channel not found");
        return;
      }
      res.writeJsonBody(serializeChannel(ch), 200);
    }
    catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleOpen(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto parts = splitPath(req.requestURI);
      if (parts.length < 5) {
        writeError(res, 400, "Invalid path");
        return;
      }
      auto channelId = parts[$ - 2];

      auto result = uc.openChannel(channelId);
      if (result.success) {
        auto resp = Json.emptyObject;
        resp["status"] = Json("opened");
        res.writeJsonBody(resp, 200);
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

  private void handleClose(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto parts = splitPath(req.requestURI);
      if (parts.length < 5) {
        writeError(res, 400, "Invalid path");
        return;
      }
      auto channelId = parts[$ - 2];

      auto result = uc.closeChannel(channelId);
      if (result.success) {
        auto resp = Json.emptyObject;
        resp["status"] = Json("closed");
        res.writeJsonBody(resp, 200);
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

  private void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto id = extractIdFromPath(req.requestURI);
      auto result = uc.deleteChannel(id);
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

  private static Json serializeChannel(ref const ServiceChannel ch) {
    auto j = Json.emptyObject;
    j["id"] = Json(ch.id);
    j["connectorId"] = Json(ch.connectorId);
    j["tenantId"] = Json(ch.tenantId);
    j["name"] = Json(ch.name);
    j["type"] = Json(ch.channelType.to!string);
    j["status"] = Json(ch.status.to!string);
    j["virtualHost"] = Json(ch.virtualHost);
    j["virtualPort"] = Json(cast(long) ch.virtualPort);
    j["backendHost"] = Json(ch.backendHost);
    j["backendPort"] = Json(cast(long) ch.backendPort);
    j["openedAt"] = Json(ch.openedAt);
    j["closedAt"] = Json(ch.closedAt);
    j["createdAt"] = Json(ch.createdAt);
    j["updatedAt"] = Json(ch.updatedAt);
    return j;
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
