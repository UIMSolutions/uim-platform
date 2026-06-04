module uim.platform.workzone.presentation.http.controllers.channel;

import uim.platform.workzone;

mixin(ShowModule!());

@safe:
class ChannelController : ManageHttpController {
  private ManageChannelsUseCase useCase;

  this(ManageChannelsUseCase useCase) {
    this.useCase = useCase;
  }

  override void registerRoutes(URLRouter router) {
    router.get("/api/v1/channels", &handleList);
    router.get("/api/v1/channels/*", &handleGet);
    router.post("/api/v1/channels", &handleCreate);
    router.put("/api/v1/channels/*", &handleUpdate);
    router.delete_("/api/v1/channels/*", &handleDelete);
  }

  override protected Json createHandler(HTTPServerRequest req) {
    auto precheck = super.createHandler(req);
    if (precheck.hasError)
      return precheck;

    auto data = precheck.data;
    CreateChannelRequest r;
    r.tenantId = precheck.tenantId;
    r.workspaceId = WorkspaceId(data.getString("workspaceId"));
    r.name = data.getString("name");
    r.description = data.getString("description");
    r.channelType = toChannelType(data.getString("channelType", "custom"));

    auto result = useCase.createChannel(r);
    if (!result.success)
      return errorResponse(result.message, 400);

    return successResponse("Channel created successfully", "Created", 201,
      Json.emptyObject.set("id", result.id));
  }

  override protected Json listHandler(HTTPServerRequest req) {
    auto precheck = super.getHandler(req);
    if (precheck.hasError)
      return precheck;

    auto workspaceIdRaw = req.query.get("workspaceId", "");
    if (workspaceIdRaw.length == 0)
      return errorResponse("workspaceId query parameter is required", 400);

    auto resources = useCase.listByWorkspace(precheck.tenantId, WorkspaceId(workspaceIdRaw));
    auto payload = resources.map!(c => c.toJson()).array.toJson;

    return Json.emptyObject
      .set("count", resources.length)
      .set("resources", payload)
      .set("message", "Channels retrieved successfully")
      .set("status", "success")
      .set("statusCode", 200);
  }

  override protected Json getHandler(HTTPServerRequest req) {
    auto precheck = super.getHandler(req);
    if (precheck.hasError)
      return precheck;

    auto entity = useCase.getChannel(precheck.tenantId, ChannelId(precheck.id));
    if (entity.isNull)
      return errorResponse("Channel not found", 404);

    return successResponse("Channel retrieved successfully", "Retrieved", 200, entity.toJson());
  }

  override protected Json updateHandler(HTTPServerRequest req) {
    auto precheck = super.updateHandler(req);
    if (precheck.hasError)
      return precheck;

    UpdateChannelRequest r;
    r.id = ChannelId(precheck.id);
    r.tenantId = precheck.tenantId;
    r.name = precheck.data.getString("name");
    r.description = precheck.data.getString("description");
    r.active = precheck.data.getLong("active", 1) != 0;

    auto result = useCase.updateChannel(r);
    if (!result.success)
      return errorResponse(result.message, 404);

    return successResponse("Channel updated successfully", "Updated", 200,
      Json.emptyObject.set("id", result.id));
  }

  override protected Json deleteHandler(HTTPServerRequest req) {
    auto precheck = super.deleteHandler(req);
    if (precheck.hasError)
      return precheck;

    auto result = useCase.deleteChannel(precheck.tenantId, ChannelId(precheck.id));
    if (!result.success)
      return errorResponse(result.message, 404);

    return successResponse("Channel deleted successfully", "Deleted", 200, Json.emptyObject);
  }
}
