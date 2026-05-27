module uim.platform.integration_suite.presentation.http.controllers.message_mappings;
import uim.platform.integration_suite;

mixin(ShowModule!());

@safe:

class MessageMappingController : ManageController {
private:
  ManageMessageMappingsUseCase _usecase;

public:
  this(ManageMessageMappingsUseCase usecase) { _usecase = usecase; }

  override void registerRoutes(URLRouter router) {
    router.post   ("/api/v1/integration/mappings",   &handleCreate);
    router.get    ("/api/v1/integration/mappings",   &handleList);
    router.get    ("/api/v1/integration/mappings/*", &handleGet);
    router.put    ("/api/v1/integration/mappings/*", &handleUpdate);
    router.delete_("/api/v1/integration/mappings/*", &handleDelete);
  }

  override protected void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto data = precheck.data;
      CreateMappingRequest r;
      r.tenantId          = req.getTenantId;
      r.id                = precheck.id;
      r.packageId         = data.getString("packageId");
      r.name              = data.getString("name");
      r.description       = data.getString("description");
      r.version_          = data.getString("version");
      r.sourceStandard    = data.getString("sourceStandard");
      r.targetStandard    = data.getString("targetStandard");
      r.sourceSchema      = data.getString("sourceSchema");
      r.targetSchema      = data.getString("targetSchema");
      r.mappingExpression = data.getString("mappingExpression");
      r.metadata          = data.jsonStrMap("metadata");
      auto result = _usecase.create(r);
      if (result.success) res.writeJsonBody(result.data, 201);
      else writeError(res, 400, result.message);
    } catch (Exception e) { writeError(res, 500, "Internal server error"); }
  }

  override protected void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto result = _usecase.getAll(req.getTenantId);
      if (result.success) res.writeJsonBody(result.data, 200);
      else writeError(res, 500, result.message);
    } catch (Exception e) { writeError(res, 500, "Internal server error"); }
  }

  override protected void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto result = _usecase.getById(req.getTenantId, extractIdFromPath(req));
      if (result.success) res.writeJsonBody(result.data, 200);
      else writeError(res, 404, result.message);
    } catch (Exception e) { writeError(res, 500, "Internal server error"); }
  }

  override protected void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto data = precheck.data;
      UpdateMappingRequest r;
      r.tenantId          = req.getTenantId;
      r.id                = extractIdFromPath(req);
      r.name              = data.getString("name");
      r.description       = data.getString("description");
      r.version_          = data.getString("version");
      r.status            = data.getString("status");
      r.mappingExpression = data.getString("mappingExpression");
      r.metadata          = data.jsonStrMap("metadata");
      auto result = _usecase.update(r);
      if (result.success) res.writeJsonBody(result.data, 200);
      else writeError(res, 404, result.message);
    } catch (Exception e) { writeError(res, 500, "Internal server error"); }
  }

  override protected void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto result = _usecase.remove(req.getTenantId, extractIdFromPath(req));
      if (result.success) res.writeJsonBody(Json.emptyObject.set("message", "Deleted"), 200);
      else writeError(res, 404, result.message);
    } catch (Exception e) { writeError(res, 500, "Internal server error"); }
  }
}
