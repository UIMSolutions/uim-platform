module uim.platform.databricks.presentation.http.controllers.ml_experiments;
import uim.platform.databricks;

// mixin(ShowModule!());

@safe:

class MlExperimentController : ManageHttpController {
private:
  ManageMlExperimentsUseCase _usecase;

public:
  this(ManageMlExperimentsUseCase usecase) {
    _usecase = usecase;
  }

  override void registerRoutes(URLRouter router) {
    router.post("/api/v1/databricks/experiments", &handleCreate);
    router.get("/api/v1/databricks/experiments", &handleList);
    router.get("/api/v1/databricks/experiments/*", &handleGet);
    router.put("/api/v1/databricks/experiments/*", &handleUpdate);
    router.delete_("/api/v1/databricks/experiments/*", &handleDelete);
  }

  override protected Json createHandler(HTTPServerRequest req) {
    auto precheck = super.createHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;

    auto data = precheck.data;
    CreateMlExperimentRequest r;
    r.tenantId = tenantId;
    r.experimentId = MlExperimentId(precheck.id);
    r.workspaceId = data.getString("workspaceId");
    r.name = data.getString("name");
    r.artifactLocation = data.getString("artifactLocation");
    r.ownerId = data.getString("ownerId");
    r.tags = data.getString("tags");
    auto result = _usecase.create(r);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto responseData = Json.emptyObject.set("id", result.id);
    return successResponse("ML experiment created successfully", 201, responseData);
  }

  override protected Json listHandler(HTTPServerRequest req) {
    auto precheck = super.listHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto result = _usecase.list(tenantId);
    auto list = result.map!(item => item.toJson()).array.toJson;

    auto responseData = Json.emptyObject
      .set("count", list.length)
      .set("resources", list);
    return successResponse("ML experiment list retrieved successfully", 200, responseData);
  }

  override protected Json getHandler(HTTPServerRequest req) {
    auto precheck = super.getHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;

    auto id = MlExperimentId(req.requestPath.to!string.split("/")[$ - 1]);
    if (id.isNull)
      return errorResponse("Invalid ML experiment ID", 400);

    auto result = _usecase.get(tenantId, id);
    if (result.isNull)
      return errorResponse("ML experiment not found", 404);

    auto responseData = result.toJson();
    return successResponse("ML experiment retrieved successfully", responseData);
  }

  override protected Json updateHandler(HTTPServerRequest req) {
    auto precheck = super.updateHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = MlExperimentId(req.requestPath.to!string.split("/")[$ - 1]);
    if (id.isNull)
      return errorResponse("Invalid ML experiment ID", 400);


    auto data = precheck.data;
    UpdateMlExperimentRequest r;
    r.tenantId = tenantId;
    r.experimentId = id;
    r.name = data.getString("name");
    r.tags = data.getString("tags");
    auto result = _usecase.update(r);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto responseData = Json.emptyObject.set("id", result.id);
    return successResponse("ML experiment updated successfully", 200, responseData);
  }

  override protected Json deleteHandler(HTTPServerRequest req) {
    auto precheck = super.deleteHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = MlExperimentId(req.requestPath.to!string.split("/")[$ - 1]);
    if (id.isNull)
      return errorResponse("Invalid ML experiment ID", 400);

    auto result = _usecase.remove(tenantId, id);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto responseData = Json.emptyObject.set("id", result.id);
    return successResponse("ML experiment deleted successfully", 200, responseData);
  }
}
