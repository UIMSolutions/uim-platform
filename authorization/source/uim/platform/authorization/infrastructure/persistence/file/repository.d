module uim.platform.authorization.infrastructure.persistence.file.repository;

import std.file : exists, mkdirRecurse, write;
import std.path : buildPath;
import std.algorithm : filter;
import vibe.data.json : Json;
import uim.platform.authorization;

mixin(ShowModule!());

@safe:

class FileAuthorizationRepository : MemoryAuthorizationRepository {
  private string basePath;

  this(string basePath) {
    this.basePath = basePath;
    if (!basePath.exists) {
      mkdirRecurse(basePath);
    }
  }

  override void saveApplication(ManagedApplication app) { super.saveApplication(app); persistTenant(app.tenantId); }
  override void deleteApplication(string tenantId, string id) { super.deleteApplication(tenantId, id); persistTenant(tenantId); }
  override void saveApplicationApi(ApplicationApi api) { super.saveApplicationApi(api); persistTenant(api.tenantId); }
  override void deleteApplicationApi(string tenantId, string id) { super.deleteApplicationApi(tenantId, id); persistTenant(tenantId); }
  override void savePolicy(AuthorizationPolicy policy) { super.savePolicy(policy); persistTenant(policy.tenantId); }
  override void deletePolicy(string tenantId, string id) { super.deletePolicy(tenantId, id); persistTenant(tenantId); }
  override void saveAssignment(PolicyAssignment assignment) { super.saveAssignment(assignment); persistTenant(assignment.tenantId); }
  override void deleteAssignment(string tenantId, string id) { super.deleteAssignment(tenantId, id); persistTenant(tenantId); }

private:
  string tenantFile(string tenantId) const { return buildPath(basePath, tenantId ~ ".json"); }

  void persistTenant(string tenantId) {
    auto j = Json.emptyObject;

    auto appArr = Json.emptyArray;
    foreach (a; applications.filter!(e => e.tenantId == tenantId)) appArr ~= a.toJson();
    j["applications"] = appArr;

    auto apiArr = Json.emptyArray;
    foreach (a; apis.filter!(e => e.tenantId == tenantId)) apiArr ~= a.toJson();
    j["apis"] = apiArr;

    auto polArr = Json.emptyArray;
    foreach (p; policies.filter!(e => e.tenantId == tenantId)) polArr ~= p.toJson();
    j["policies"] = polArr;

    auto asgArr = Json.emptyArray;
    foreach (a; assignments.filter!(e => e.tenantId == tenantId)) asgArr ~= a.toJson();
    j["assignments"] = asgArr;

    write(tenantFile(tenantId), j.toPrettyString());
  }
}
