/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.workzone.persistence.repositories.workzone;

import uim.platform.workzone;

mixin(ShowModule!());

@safe:

/// Generic repository of a Work Zone aggregate on top of a tenant store
/// (in memory or JSON snapshots, see the container).
class WorkzoneRepository(TEntity, TId) : TenantRepository!(TEntity, TId), IWorkzoneRepository!(TEntity, TId) {
  this() {
    super();
  }

  this(ITenantStore!(TEntity, TId) store) {
    super(store);
  }

  TEntity findByName(TenantId tenantId, string name) {
    foreach (e; findByTenant(tenantId))
      if (nameOf(e) == name)
        return e;
    return TEntity.init;
  }

  TEntity[] findByWorkspace(TenantId tenantId, WorkspaceId workspaceId) {
    return findMatching(tenantId, (const TEntity e) => workspaceOf(e) == workspaceId);
  }

  TEntity[] findMatching(TenantId tenantId, scope bool delegate(const TEntity) @safe specification) {
    TEntity[] result;
    foreach (e; findByTenant(tenantId))
      if (specification(e))
        result ~= e;
    return result;
  }
}

alias WorkspaceRepository = WorkzoneRepository!(Workspace, WorkspaceId);
alias WorkpageRepository = WorkzoneRepository!(Workpage, WorkpageId);
alias ContentRepository = WorkzoneRepository!(ContentItem, ContentId);
alias TagRepository = WorkzoneRepository!(Tag, TagId);

///
unittest {
  mixin(ShowTest!("WorkzoneRepository"));

  assert(tenantRepositoryTest(new WorkspaceRepository()));
  assert(tenantRepositoryTest(new ContentRepository()));

  auto t = TenantId("t1");
  auto repo = new WorkpageRepository();
  auto page = Workpage(t);
  page.title = "Home";
  page.workspaceId = WorkspaceId("w1");
  repo.save(page);
  assert(!repo.findByName(t, "Home").isNull && repo.findByName(t, "Nope").isNull);
  assert(repo.findByWorkspace(t, WorkspaceId("w1")).length == 1);
  assert(repo.findByWorkspace(t, WorkspaceId("w2")).length == 0);
  assert(repo.findMatching(t, (const Workpage p) => p.title.startsWith("Ho")).length == 1);
}
