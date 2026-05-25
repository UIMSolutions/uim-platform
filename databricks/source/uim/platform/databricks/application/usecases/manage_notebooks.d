module uim.platform.databricks.application.usecases.manage_notebooks;
import uim.platform.databricks;

mixin(ShowModule!());

@safe:

class ManageNotebooksUseCase {
private:
  NotebookRepository _repo;

public:
  this(NotebookRepository repo) { _repo = repo; }

  UseCaseResult!Notebook create(CreateNotebookRequest r) {
    auto n = Notebook();
    n.id          = r.id;
    n.tenantId    = r.tenantId;
    n.workspaceId = r.workspaceId;
    n.path        = r.path;
    n.name        = r.name;
    n.language    = r.language;
    n.content     = r.content;
    n.format      = r.format.length > 0 ? r.format : "SOURCE";
    n.ownerId     = r.ownerId;
    n.status      = NotebookStatus.active;
    import std.datetime : Clock;
    n.createdAt  = Clock.currTime().toUnixTime() * 1000;
    n.modifiedAt = n.createdAt;
    _repo.save(n);
    return UseCaseResult!Notebook(true, "Notebook created", n);
  }

  UseCaseResult!(Notebook[]) list(TenantId tenantId) {
    return UseCaseResult!(Notebook[])(true, "", _repo.findByTenant(tenantId));
  }

  UseCaseResult!Notebook get(TenantId tenantId, NotebookId id) {
    auto n = _repo.find(tenantId, id);
    if (n == Notebook.init)
      return UseCaseResult!Notebook(false, "Notebook not found", Notebook.init);
    return UseCaseResult!Notebook(true, "", n);
  }

  UseCaseResult!Notebook update(UpdateNotebookRequest r) {
    auto n = _repo.find(r.tenantId, r.id);
    if (n == Notebook.init)
      return UseCaseResult!Notebook(false, "Notebook not found", Notebook.init);
    if (r.name.length    > 0) n.name    = r.name;
    if (r.content.length > 0) n.content = r.content;
    if (r.format.length  > 0) n.format  = r.format;
    import std.datetime : Clock;
    n.modifiedAt = Clock.currTime().toUnixTime() * 1000;
    _repo.save(n);
    return UseCaseResult!Notebook(true, "Notebook updated", n);
  }

  UseCaseResult!bool remove(TenantId tenantId, NotebookId id) {
    auto n = _repo.find(tenantId, id);
    if (n == Notebook.init)
      return UseCaseResult!bool(false, "Notebook not found", false);
    n.status = NotebookStatus.deleted;
    _repo.save(n);
    return UseCaseResult!bool(true, "Notebook deleted", true);
  }
}
