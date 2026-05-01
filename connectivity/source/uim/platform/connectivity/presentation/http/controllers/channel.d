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

// import uim.platform.connectivity.application.usecases.manage.channels;
// import uim.platform.connectivity.application.dto;
// import uim.platform.connectivity.domain.entities.service_channel;
import uim.platform.connectivity;

mixin(ShowModule!());

@safe:
class ChannelController : PlatformController {
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
      r.virtualPort = getUshort(j, "virtualPort");
      r.backendHost = j.getString("backendHost");
      r.backendPort = getUshort(j, "backendPort");

      auto result = uc.createChannel(r);
      if (result.success) {
        auto resp = Json.emptyObject
          .set("id", result.id)
          .set("message", "Channel created");

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
      foreach (ch; channels)
        arr ~= serializeChannel(ch);

      auto resp = Json.emptyObject
        .set("items", arr)
        .set("totalCount", Json(channels.length))
        .set("message", "Channels retrieved successfully");

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
      if (ch.isNull) {
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
        auto resp = Json.emptyObject
          .set("id", result.id)
          .set("status", "opened")
          .set("message", "Channel opened successfully");

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
        auto resp = Json.emptyObject
          .set("id", result.id)
          .set("status", "closed")
          .set("message", "Channel closed successfully");

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
        auto resp = Json.emptyObject
          .set("id", result.id)
          .set("deleted", true)
          .set("message", "Channel deleted successfully");
          
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

  private static Json serializeChannel(const ServiceChannel ch) {
    return Json.emptyObject
      .set("id", ch.id)
      .set("connectorId", ch.connectorId)
      .set("tenantId", ch.tenantId)
      .set("name", ch.name)
      .set("type", ch.channelType.to!string)
      .set("status", ch.status.to!string)
      .set("virtualHost", ch.virtualHost)
      .set("virtualPort", ch.virtualPort)
      .set("backendHost", ch.backendHost)
      .set("backendPort", ch.backendPort)
      .set("openedAt", ch.openedAt)
      .set("closedAt", ch.closedAt)
      .set("createdAt", ch.createdAt)
      .set("updatedAt", ch.updatedAt);
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
