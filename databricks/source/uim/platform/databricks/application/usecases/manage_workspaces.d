module uim.platform.databricks.application.usecases.manage_workspaces;
import uim.platform.databricks;

mixin(ShowModule!());

@safe:

class ManageWorkspacesUseCase {
private:
  WorkspaceRepository _repo;

public:
  this(WorkspaceRepository repo) { _repo = repo; }

  UseCaseResult!Workspace create(CreateWorkspaceRequest r) {
    auto w = Workspace();
    w.id            = r.id;
    w.tenantId      = r.tenantId;
    w.name          = r.name;
    w.region        = r.region;
    w.tier          = r.tier;
    w.cloudProvider = r.cloudProvider;
    w.storageRoot   = r.storageRoot;
    w.credentialId  = r.credentialId;
    w.status        = WorkspaceStatus.provisioning;
    import std.datetime : Clock;
    w.createdAt = Clock.currTime().toUnixTime() * 1000;
    _repo.save(w);
    return UseCaseResult!Workspace(true, "Workspace created", w);
  }

  UseCaseResult!(Workspace[]) list(TenantId tenantId) {
    return UseCaseResult!(Workspace[])(true, "", _repo.findByTenant(tenantId));
  }

  UseCaseResult!Workspace get(TenantId tenantId, WorkspaceId id) {
    auto w = _repo.find(tenantId, id);
    if (w == Workspace.init)
      return UseCaseResult!Workspace(false, "Workspace not found", Workspace.init);
    return UseCaseResult!Workspace(true, "", w);
  }

  UseCaseResult!Workspace update(UpdateWorkspaceRequest r) {
    auto w = _repo.find(r.tenantId, r.id);
    if (w == Workspace.init)
      return UseCaseResult!Workspace(false, "Workspace not found", Workspace.init);
    if (r.name.length   > 0) w.name        = r.name;
    if (r.storageRoot.length > 0) w.storageRoot = r.storageRoot;
    w.tier = r.tier;
    _repo.save(w);
    return UseCaseResult!Workspace(true, "Workspace updated", w);
  }

  UseCaseResult!bool remove(TenantId tenantId, WorkspaceId id) {
    auto w = _repo.find(tenantId, id);
    if (w == Workspace.init)
      return UseCaseResult!bool(false, "Workspace not found", false);
    w.status = WorkspaceStatus.deleted;
    _repo.save(w);
    return UseCaseResult!bool(true, "Workspace deleted", true);
  }
}
