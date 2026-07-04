module uim.platform.snowflake.presentation.http.provisioning_requests;
import uim.platform.snowflake;
import vibe.http.server;
import vibe.http.router;

mixin(ShowModule!());
@safe:
class ProvisioningRequestController : ManageHttpController {
  private ManageProvisioningRequestsUseCase usecase;
  this(ManageProvisioningRequestsUseCase usecase) {
    this.usecase = usecase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);
    router.get("/api/v1/snowflake/requests", &handleList);
    router.get("/api/v1/snowflake/requests/*", &handleGet);
    router.post("/api/v1/snowflake/requests", &handleCreate);
    router.delete_("/api/v1/snowflake/requests/*", &handleDelete);
    router.post("/api/v1/snowflake/requests/*/process", &handleProcess);
    router.post("/api/v1/snowflake/requests/*/complete", &handleComplete);
    router.post("/api/v1/snowflake/requests/*/fail", &handleFail);
  }

  override protected Json listHandler(HTTPServerRequest req) {
    auto precheck = super.listHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto items = usecase.list(tenantId);
    auto arr = Json.emptyArray;
    foreach (item; items)
      arr ~= item.toJson();

    return successResponse("Provisioning requests retrieved successfully", 200, Json.emptyObject.set("items", arr).set(
        "totalCount", items.length));
  }

  void handleGet(HTTPServerRequest req, HTTPServerResponse res) {
    auto item = usecase.getById(req.getTenantId, extractIdFromPath(req.requestPath.to!string));
    if (item.isNull) {
      writeError(res, 404, "Provisioning request not found");
      return;
    }
    res.writeJsonBody(item.toJson(), cast(int)HTTPStatus.ok);
  }

  override protected Json createHandler(HTTPServerRequest req) {
    auto precheck = super.createHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;

    auto data = precheck.data;
    CreateProvisioningRequest r;
    r.tenantId = tenantId;
    r.id = precheck.id;
    r.requestedBy = data.getString("requestedBy");
    r.accountName = data.getString("accountName");
    r.region = data.getString("region");
    r.adminEmail = data.getString("adminEmail");
    r.adminFirstName = data.getString("adminFirstName");
    r.adminLastName = data.getString("adminLastName");
    auto result = usecase.create(r);

    if (result.hasError)
      return errorResponse(result.message, 400);

    auto resp = Json.emptyObject.set("id", result.id);

    return successResponse("Provisioning request created successfully", 201, resp);
  }

  protected Json deleteHandler(HTTPServerRequest req) {
    auto precheck = super.deleteHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = extractIdFromPath(req.requestPath.to!string);

    auto result = usecase.remove(tenantId, id);
    if (result.hasError)
      return errorResponse(result.message, 400);

    return successResponse("Provisioning request deleted successfully", 200, result);
  }

  protected Json processHandler(HTTPServerRequest req) {
    auto precheck = super.processHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = extractIdFromPath(req.requestPath.to!string);

    auto result = usecase.process(tenantId, id);
    if (result.hasError)
      return errorResponse(result.message, 400);

    return successResponse("Provisioning request processing started", 200, result);
  }
  
  void handleProcess(HTTPServerRequest req, HTTPServerResponse res) {
    auto result = usecase.process(req.getTenantId, extractIdFromPath(req.requestPath.to!string));
    if (!result.success) {
      writeError(res, 404, result.message);
      return;
    }
    res.writeJsonBody(Json.emptyObject, cast(int)HTTPStatus.ok);
  }

  void handleComplete(HTTPServerRequest req, HTTPServerResponse res) {
    auto data = precheck.data;
    UpdateProvisioningStatusRequest r;
    r.tenantId = tenantId;
    r.id = extractIdFromPath(req.requestPath.to!string);
    r.resultAccountId = data.getString("resultAccountId");
    auto result = usecase.complete(r);
    if (!result.success) {
      writeError(res, 404, result.message);
      return;
    }
    res.writeJsonBody(Json.emptyObject, cast(int)HTTPStatus.ok);
  }

  void handleFail(HTTPServerRequest req, HTTPServerResponse res) {
    auto data = precheck.data;
    UpdateProvisioningStatusRequest r;
    r.tenantId = tenantId;
    r.id = extractIdFromPath(req.requestPath.to!string);
    r.errorMessage = data.getString("errorMessage");
    auto result = usecase.fail(r);
    if (!result.success) {
      writeError(res, 404, result.message);
      return;
    }
    res.writeJsonBody(Json.emptyObject, cast(int)HTTPStatus.ok);
  }
}
