module uim.platform.databricks.presentation.http.controllers.ml_models;
import uim.platform.databricks;

mixin(ShowModule!());

@safe:

class MlModelController : ManageHttpController {
private:
  ManageMlModelsUseCase _usecase;

public:
  this(ManageMlModelsUseCase usecase) { _usecase = usecase; }

  override void registerRoutes(URLRouter router) {
    router.post   ("/api/v1/databricks/models",   &handleCreate);
    router.get    ("/api/v1/databricks/models",   &handleList);
    router.get    ("/api/v1/databricks/models/*", &handleGet);
    router.put    ("/api/v1/databricks/models/*", &handleUpdate);
    router.delete_("/api/v1/databricks/models/*", &handleDelete);
  }

  override protected Json createHandler(HTTPServerRequest req) {
        auto precheck = super.createHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

        auto data = precheck.data;
      CreateMlModelRequest r;
      r.tenantId    = req.getTenantId;
      r.id          = precheck.id;
      r.workspaceId = data.getString("workspaceId");
      r.name        = data.getString("name");
      r.description = data.getString("description");
      r.ownerId     = data.getString("ownerId");
      r.source      = data.getString("source");
      r.tags        = data.getString("tags");
      auto result = _usecase.create(r);
      if (result.hasError)
            return errorResponse(result.message, 400);

        auto responseData = Json.emptyObject.set("id", result.id);
        return successResponse("ML model created successfully", 201, responseData);
  }



  override protected Json listHandler(HTTPServerRequest req) {
        auto precheck = super.listHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
      auto result = _usecase.list(req.getTenantId);
      res.writeJsonBody(serializeToJson(result.data));
    } catch (Exception e) { writeError(res, 500, "Internal server error"); }
  }

  override protected Json getHandler(HTTPServerRequest req) {
        auto precheck = super.getHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
      
      auto id     = req.requestPath.to!string.split("/")[$-1];
      auto result = _usecase.get(tenantId, id);
      if (result.success) res.writeJsonBody(serializeToJson(result.data));
      else writeError(res, 404, result.message);
    } catch (Exception e) { writeError(res, 500, "Internal server error"); }
  }

  override protected Json updateHandler(HTTPServerRequest req) {
        auto precheck = super.updateHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
      
      auto data = precheck.data;
      UpdateMlModelRequest r;
      r.tenantId    = req.getTenantId;
      r.id          = req.requestPath.to!string.split("/")[$-1];
      r.description = data.getString("description");
      r.tags        = data.getString("tags");
      auto stageStr = data.getString("latestStage");
      if (stageStr.length > 0) {
        import std.conv : ConvException;
        try { r.latestStage = stageStr.to!ModelStage; } catch (ConvException) {}
      }
      auto result = _usecase.update(r);
      if (result.hasError)
            return errorResponse(result.message, 400);

        auto responseData = Json.emptyObject.set("id", result.id);
        return successResponse("ML model updated successfully", 200, responseData);
  }


  override protected Json deleteHandler(HTTPServerRequest req) {
        auto precheck = super.deleteHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
      
      auto id     = req.requestPath.to!string.split("/")[$-1];
      auto result = _usecase.remove(req.getTenantId, id);
      if (result.hasError)
            return errorResponse(result.message, 400);

        auto responseData = Json.emptyObject.set("id", result.id);
        return successResponse("ML model deleted successfully", 200, responseData);
  }
