/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.connectivity.presentation.http.controllers.channel;




// import uim.platform.connectivity.application.usecases.manage.channels;
// import uim.platform.connectivity.application.dto;
// import uim.platform.connectivity.domain.entities.service_channel;
import uim.platform.connectivity;

mixin(ShowModule!());

@safe:
class ChannelController : ManageController {
  private ManageChannelsUseCase usecase;

  this(ManageChannelsUseCase usecase) {
    this.usecase = usecase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.post("/api/v1/channels", &handleCreate);
    router.get("/api/v1/channels", &handleList);
    router.get("/api/v1/channels/*", &handleGet);
    router.post("/api/v1/channels/*/open", &handleOpen);
    router.post("/api/v1/channels/*/close", &handleClose);
    router.delete_("/api/v1/channels/*", &handleDelete);
  }

  override protected void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
      auto tenantId = req.getTenantId;
      auto j = req.json;
      auto r = CreateChannelRequest();
      r.connectorId = j.getString("connectorId");
      r.tenantId = tenantId;
      r.name = j.getString("name");
      r.channelType = j.getString("type");
      r.virtualHost = j.getString("virtualHost");
      r.virtualPort = getUshort(j, "virtualPort");
      r.backendHost = j.getString("backendHost");
      r.backendPort = getUshort(j, "backendPort");

      auto result = usecase.createChannel(r);
      if (result.hasError)
            return errorResponse(result.message, 400);
        auto resp = Json.emptyObject
          .set("id", result.id)
          .set("message", "Channel created");

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

      auto channels = usecase.listByTenant(tenantId);
      auto arr = channels.map!(ch => ch.toJson).array.toJson;

      auto resp = Json.emptyObject
        .set("items", arr)
        .set("totalCount", Json(channels.length))
        .set("message", "Channels retrieved successfully");

      res.writeJsonBody(resp, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  override protected void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.getTenantId;
      auto id = ChannelId(extractIdFromPath(req.requestURI));
      auto ch = usecase.getChannel(tenantId, id);
      if (ch.isNull) {
        writeError(res, 404, "Channel not found");
        return;
      }
      res.writeJsonBody(ch.toJson, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  protected void handleOpen(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto parts = splitPath(req.requestURI);
      if (parts.length < 5) {
        writeError(res, 400, "Invalid path");
        return;
      }
      auto channelId = ChannelId(parts[$ - 2]);
      auto tenantId = req.getTenantId;

      auto result = usecase.openChannel(tenantId, channelId);
      if (result.hasError)
            return errorResponse(result.message, 400);
        auto resp = Json.emptyObject
          .set("id", result.id)
          .set("status", "opened")
          .set("message", "Channel opened successfully");

        res.writeJsonBody(resp, 200);
      } else {
        writeError(res, 400, result.message);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  protected void handleClose(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto parts = splitPath(req.requestURI);
      if (parts.length < 5) {
        writeError(res, 400, "Invalid path");
        return;
      }
      auto tenantId = req.getTenantId;
      auto channelId = ChannelId(parts[$ - 2]);

      auto result = usecase.closeChannel(tenantId, channelId);
      if (result.hasError)
            return errorResponse(result.message, 400);
        auto resp = Json.emptyObject
          .set("id", result.id)
          .set("status", "closed")
          .set("message", "Channel closed successfully");

        res.writeJsonBody(resp, 200);
      } else {
        writeError(res, 400, result.message);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  override protected void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.getTenantId;
      auto id = ChannelId(extractIdFromPath(req.requestURI));
      auto result = usecase.deleteChannel(tenantId, id);
      if (result.hasError)
            return errorResponse(result.message, 400);
        auto resp = Json.emptyObject
          .set("id", result.id)
          .set("deleted", true)
          .set("message", "Channel deleted successfully");

        res.writeJsonBody(resp, 200);
      } else {
        writeError(res, 404, result.message);
      }
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
