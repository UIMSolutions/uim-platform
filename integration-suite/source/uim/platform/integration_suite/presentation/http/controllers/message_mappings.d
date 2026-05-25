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
      auto j = req.json;
      CreateMappingRequest r;
      r.tenantId          = req.getTenantId;
      r.id                = j.getString("id");
      r.packageId         = j.getString("packageId");
      r.name              = j.getString("name");
      r.description       = j.getString("description");
      r.version_          = j.getString("version");
      r.sourceStandard    = j.getString("sourceStandard");
      r.targetStandard    = j.getString("targetStandard");
      r.sourceSchema      = j.getString("sourceSchema");
      r.targetSchema      = j.getString("targetSchema");
      r.mappingExpression = j.getString("mappingExpression");
      r.metadata          = jsonStrMap(j, "metadata");
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
      auto j = req.json;
      UpdateMappingRequest r;
      r.tenantId          = req.getTenantId;
      r.id                = extractIdFromPath(req);
      r.name              = j.getString("name");
      r.description       = j.getString("description");
      r.version_          = j.getString("version");
      r.status            = j.getString("status");
      r.mappingExpression = j.getString("mappingExpression");
      r.metadata          = jsonStrMap(j, "metadata");
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
