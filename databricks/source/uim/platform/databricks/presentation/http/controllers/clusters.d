module uim.platform.databricks.presentation.http.controllers.clusters;
import uim.platform.databricks;

mixin(ShowModule!());

@safe:

class ClusterController : ManageController {
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

  override protected void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto j = req.json;
      CreateClusterRequest r;
      r.tenantId              = req.getTenantId;
      r.id                    = precheck.id;
      r.workspaceId           = j.getString("workspaceId");
      r.name                  = j.getString("name");
      r.nodeType              = j.getString("nodeType");
      r.driverNodeType        = j.getString("driverNodeType");
      r.sparkVersion          = j.getString("sparkVersion");
      r.runtimeVersion        = j.getString("runtimeVersion");
      r.creatorId             = j.getString("creatorId");
      r.numWorkers            = j.getInt("numWorkers");
      r.autoscaleEnabled      = j.getBool("autoscaleEnabled");
      r.autoscaleMinWorkers   = j.getInt("autoscaleMinWorkers");
      r.autoscaleMaxWorkers   = j.getInt("autoscaleMaxWorkers");
      r.autoTerminationMinutes= j.getInt("autoTerminationMinutes");
      auto typeStr = j.getString("clusterType");
      if (typeStr.length > 0) {
        import std.conv : to, ConvException;
        try { r.clusterType = typeStr.to!ClusterType; } catch (ConvException) {}
      }
      auto result = _usecase.create(r);
      if (result.success) res.writeJsonBody(serializeToJson(result.data), 201);
      else writeError(res, 400, result.message);
    } catch (Exception e) { writeError(res, 500, "Internal server error"); }
  }

  override protected void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto result = _usecase.list(req.getTenantId);
      res.writeJsonBody(serializeToJson(result.data));
    } catch (Exception e) { writeError(res, 500, "Internal server error"); }
  }

  override protected void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      import std.conv : to;
      auto id     = req.requestPath.to!string.split("/")[$-1];
      auto result = _usecase.get(req.getTenantId, id);
      if (result.success) res.writeJsonBody(serializeToJson(result.data));
      else writeError(res, 404, result.message);
    } catch (Exception e) { writeError(res, 500, "Internal server error"); }
  }

  override protected void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      import std.conv : to;
      auto j = req.json;
      UpdateClusterRequest r;
      r.tenantId             = req.getTenantId;
      r.id                   = req.requestPath.to!string.split("/")[$-1];
      r.name                 = j.getString("name");
      r.numWorkers           = j.getInt("numWorkers");
      r.autoscaleEnabled     = j.getBool("autoscaleEnabled");
      r.autoscaleMinWorkers  = j.getInt("autoscaleMinWorkers");
      r.autoscaleMaxWorkers  = j.getInt("autoscaleMaxWorkers");
      r.autoTerminationMinutes = j.getInt("autoTerminationMinutes");
      auto result = _usecase.update(r);
      if (result.success) res.writeJsonBody(serializeToJson(result.data));
      else writeError(res, 404, result.message);
    } catch (Exception e) { writeError(res, 500, "Internal server error"); }
  }

  override protected void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      import std.conv : to;
      auto id     = req.requestPath.to!string.split("/")[$-1];
      auto result = _usecase.remove(req.getTenantId, id);
      if (result.success) res.writeBody("", cast(int) HTTPStatus.noContent, "application/json");
      else writeError(res, 404, result.message);
    } catch (Exception e) { writeError(res, 500, "Internal server error"); }
  }
}
