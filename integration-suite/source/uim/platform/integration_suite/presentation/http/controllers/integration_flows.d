module uim.platform.integration_suite.presentation.http.controllers.integration_flows;
import uim.platform.integration_suite;

mixin(ShowModule!());

@safe:

class IntegrationFlowController : ManageHttpController {
private:
  ManageIntegrationFlowsUseCase _usecase;

public:
  this(ManageIntegrationFlowsUseCase usecase) {
    _usecase = usecase;
  }

  override void registerRoutes(URLRouter router) {
    router.post("/api/v1/integration/flows", &handleCreate);
    router.get("/api/v1/integration/flows", &handleList);
    router.get("/api/v1/integration/flows/*", &handleGet);
    router.put("/api/v1/integration/flows/*", &handleUpdate);
    router.delete_("/api/v1/integration/flows/*", &handleDelete);
    router.post("/api/v1/integration/flows/deploy/*", &handleDeploy);
  }

  override protected Json createHandler(HTTPServerRequest req) {
    auto precheck = super.createHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;

    auto data = precheck.data;
    CreateFlowRequest r;
    r.tenantId = tenantId;
    r.id = precheck.id;
    r.packageId = data.getString("packageId");
    r.name = data.getString("name");
    r.description = data.getString("description");
    r.version_ = data.getString("version");
    r.direction = data.getString("direction");
    r.senderAdapterType = data.getString("senderAdapterType");
    r.receiverAdapterType = data.getString("receiverAdapterType");
    r.senderEndpoint = data.getString("senderEndpoint");
    r.receiverEndpoint = data.getString("receiverEndpoint");
    r.steps = data.getStrings("steps");
    r.metadata = data.jsonStrMap("metadata");
    auto result = _usecase.create(r);

    if (result.hasError)
      return errorResponse(result.message, 400);

    auto responseData = Json.emptyObject.set("id", result.id);
    return successResponse("Integration flow created successfully", "Created", 201, responseData);
  }

  override protected Json listHandler(HTTPServerRequest req) {
    auto precheck = super.listHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto result = _usecase.getAll(tenantId);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto arr = Json.emptyArray;
    foreach (flow; result.data)
      arr ~= flow.toJson();

    return successResponse("Integration flows retrieved successfully", "OK", 200, arr);

  }

  override protected Json getHandler(HTTPServerRequest req) {
    auto precheck = super.getHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = IntegrationFlowId(precheck.id);
    auto flow = _usecase.getById(tenantId, id);
    if (flow.isNull)
      return errorResponse("Integration flow not found", 404);

      return successResponse("Integration flow retrieved successfully", "OK", 200, flow.data.toJson());
}

override protected Json updateHandler(HTTPServerRequest req) {
  auto precheck = super.updateHandler(req);
  if (precheck.hasError)
    return precheck;

  auto tenantId = precheck.tenantId;
  auto data = precheck.data;
  UpdateFlowRequest r;
  r.tenantId = tenantId;
  r.flowId = IntegrationFlowId(precheck.id);
  r.name = data.getString("name");
  r.description = data.getString("description");
  r.version_ = data.getString("version");
  r.status = data.getString("status");
  r.metadata = data.jsonStrMap("metadata");
  auto result = _usecase.update(r);
  if (result.hasError)
    return errorResponse(result.message, 400);

  auto responseData = Json.emptyObject.set("id", result.id);
  return successResponse("Integration flow updated successfully", "Updated", 200, responseData);
}

override protected Json deleteHandler(HTTPServerRequest req) {
  auto precheck = super.deleteHandler(req);
  if (precheck.hasError)
    return precheck;

  auto tenantId = precheck.tenantId;
  auto result = _usecase.remove(req.getTenantId, precheck.id);
  if (result.hasError)
    return errorResponse(result.message, 400);

  auto responseData = Json.emptyObject.set("id", result.id);
  return successResponse("Integration flow deleted successfully", "Deleted", 200, responseData);
}

protected Json deployHandler(HTTPServerRequest req) {
  auto precheck = super.postHandler(req);
  if (precheck.hasError)
    return precheck;

  auto tenantId = precheck.tenantId;
  DeployFlowRequest r;
  r.tenantId = tenantId;
  r.id = precheck.id;
  r.deployedBy = req.headers.get("X-User-Id", "system");

  auto result = _usecase.deploy(r);
  if (result.hasError)
    return errorResponse(result.message, 400);

  auto responseData = Json.emptyObject.set("id", result.id);
  return successResponse("Integration flow deployed successfully", "Deployed", 200, responseData);
}

mixin(HandleTemplate!("handleDeploy", "deployHandler"));

}
