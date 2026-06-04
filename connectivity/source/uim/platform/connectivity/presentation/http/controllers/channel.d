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
class ChannelController : ManageHttpController {
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

  override protected Json createHandler(HTTPServerRequest req) {
    auto precheck = super.createHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;

    auto data = precheck.data;
    auto r = CreateChannelRequest();
    r.connectorId = data.getString("connectorId");
    r.tenantId = tenantId;
    r.name = data.getString("name");
    r.channelType = data.getString("type");
    r.virtualHost = data.getString("virtualHost");
    r.virtualPort = getUshort(data, "virtualPort");
    r.backendHost = data.getString("backendHost");
    r.backendPort = getUshort(data, "backendPort");

    auto result = usecase.createChannel(r);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto responseData = Json.emptyObject.set("id", result.id);
    return successResponse("Channel created successfully", 201, responseData);
  }

  override protected Json listHandler(HTTPServerRequest req) {
    auto precheck = super.listHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;

    auto channels = usecase.listByTenant(tenantId);
    auto list = channels.map!(item => item.toJson()).array.toJson;

    auto responseData = Json.emptyObject
      .set("count", list.length)
      .set("resources", list);
    return successResponse("Channel list retrieved successfully", "Retrieved", 200, responseData);
  }

  override protected Json getHandler(HTTPServerRequest req) {
    auto precheck = super.getHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = ChannelId(precheck.id);
    auto channel = usecase.getChannel(tenantId, id);
    if (channel.isNull)
      return errorResponse("Channel not found", 404);

    auto responseData = channel.toJson();
    return successResponse("Channel retrieved successfully", "Retrieved", 200, responseData);
  }

  protected Json openHandler(HTTPServerRequest req) {
    auto precheck = super.postHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = ChannelId(precheck.id);
    if (id.isNull)
      return errorResponse("Invalid channel ID", 400);

    auto result = usecase.openChannel(tenantId, id);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto responseData = Json.emptyObject.set("id", result.id);
    return successResponse("Channel opened successfully", 200, responseData);
  }

  protected void handleOpen(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto response = openHandler(req);
      res.writeJsonBody(response, response.code);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  protected Json closeHandler(HTTPServerRequest req) {
    auto precheck = super.postHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = ChannelId(precheck.id);
    if (id.isNull)
      return errorResponse("Invalid channel ID", 400);

    auto result = usecase.closeChannel(tenantId, id);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto responseData = Json.emptyObject.set("id", result.id);
    return successResponse("Channel closed successfully", 200, responseData);
  }

  protected void handleClose(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto response = closeHandler(req);
      res.writeJsonBody(response, response.code);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  override protected Json deleteHandler(HTTPServerRequest req) {
    auto precheck = super.deleteHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = ChannelId(precheck.id);
    if (id.isNull)
      return errorResponse("Invalid channel ID", 400);
      
    auto result = usecase.deleteChannel(tenantId, id);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto responseData = Json.emptyObject.set("id", result.id);
    return successResponse("Channel deleted successfully", "Deleted", 200, responseData);
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
