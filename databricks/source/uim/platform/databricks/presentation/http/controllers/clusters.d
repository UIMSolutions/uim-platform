module uim.platform.databricks.presentation.http.controllers.clusters;
import uim.platform.databricks;

mixin(ShowModule!());

@safe:

class ClusterController : ManageHttpController {
private:
  ManageClustersUseCase _usecase;

public:
  this(ManageClustersUseCase usecase) { _usecase = usecase; }

  override void registerRoutes(URLRouter router) {
    router.post   ("/api/v1/databricks/clusters",   &handleCreate);
    router.get    ("/api/v1/databricks/clusters",   &handleList);
    router.get    ("/api/v1/databricks/clusters/*", &handleGet);
    router.put    ("/api/v1/databricks/clusters/*", &handleUpdate);
    router.delete_("/api/v1/databricks/clusters/*", &handleDelete);
  }

  override protected Json createHandler(HTTPServerRequest req) {
        auto precheck = super.createHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

        auto data = precheck.data;
      CreateClusterRequest r;
      r.tenantId              = tenantId;
      r.id                    = precheck.id;
      r.workspaceId           = data.getString("workspaceId");
      r.name                  = data.getString("name");
      r.nodeType              = data.getString("nodeType");
      r.driverNodeType        = data.getString("driverNodeType");
      r.sparkVersion          = data.getString("sparkVersion");
      r.runtimeVersion        = data.getString("runtimeVersion");
      r.creatorId             = data.getString("creatorId");
      r.numWorkers            = j.getInt("numWorkers");
      r.autoscaleEnabled      = data.getBoolean("autoscaleEnabled");
      r.autoscaleMinWorkers   = j.getInt("autoscaleMinWorkers");
      r.autoscaleMaxWorkers   = j.getInt("autoscaleMaxWorkers");
      r.autoTerminationMinutes= j.getInt("autoTerminationMinutes");
      auto typeStr = data.getString("clusterType");
      if (typeStr.length > 0) {
        import std.conv : to, ConvException;
        try { r.clusterType = typeStr.to!ClusterType; } catch (ConvException) {}
      }
      auto result = _usecase.create(r);
      if (result.hasError)
            return errorResponse(result.message, 400);

        auto responseData = Json.emptyObject.set("id", result.id);
        return successResponse("Cluster created successfully", "Created", 201, responseData);
  }

  override protected Json listHandler(HTTPServerRequest req) {
        auto precheck = super.listHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
      auto result = _usecase.list(req.getTenantId);

        auto responseData = Json.emptyObject.set("count", result.data.length).set("resources", serializeToJson(result.data));
        return successResponse("Clusters retrieved successfully", "Retrieved", 200, responseData);
  }

  override protected Json getHandler(HTTPServerRequest req) {
        auto precheck = super.getHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
      
      auto id     = req.requestPath.to!string.split("/")[$-1];
      auto result = _usecase.get(tenantId, id);
      if (result.hasError)
            return errorResponse(result.message, 404);

        auto responseData = Json.emptyObject.set("id", result.id);
        return successResponse("Cluster retrieved successfully", "Retrieved", 200, responseData);
  }

  override protected Json updateHandler(HTTPServerRequest req) {
        auto precheck = super.updateHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
      
      auto data = precheck.data;
      UpdateClusterRequest r;
      r.tenantId             = tenantId;
      r.id                   = req.requestPath.to!string.split("/")[$-1];
      r.name                 = data.getString("name");
      r.numWorkers           = j.getInt("numWorkers");
      r.autoscaleEnabled     = data.getBoolean("autoscaleEnabled");
      r.autoscaleMinWorkers  = j.getInt("autoscaleMinWorkers");
      r.autoscaleMaxWorkers  = j.getInt("autoscaleMaxWorkers");
      r.autoTerminationMinutes = j.getInt("autoTerminationMinutes");
      auto result = _usecase.update(r);
      if (result.hasError)
            return errorResponse(result.message, 404);

        auto responseData = Json.emptyObject.set("id", result.id);
        return successResponse("Cluster updated successfully", "Updated", 200, responseData);
    }

  override protected Json deleteHandler(HTTPServerRequest req) {
        auto precheck = super.deleteHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
      
      auto id     = req.requestPath.to!string.split("/")[$-1];
      auto result = _usecase.remove(req.getTenantId, id);
      if (result.hasError)
            return errorResponse(result.message, 404);

        auto responseData = Json.emptyObject.set("id", result.id);
        return successResponse("Cluster deleted successfully", "Deleted", 200, responseData);
    }
}
