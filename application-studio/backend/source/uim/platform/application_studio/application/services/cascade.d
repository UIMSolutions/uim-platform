/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.application_studio.application.services.cascade;

import uim.platform.application_studio;

mixin(ShowModule!());

@safe:

/// Removes what lives in a dev space or project when it is deleted.
class CascadeDeleter {
  protected StudioRepositories repos;

  this(StudioRepositories repos) {
    this.repos = repos;
  }

  /// Delete the run and build configurations of a project. Returns the number removed.
  size_t clearProject(TenantId tenantId, ProjectId projectId) {
    size_t removed;
    void clear(R)(R repo) {
      auto items = repo.findByProject(tenantId, projectId);
      removed += items.length;
      if (items.length > 0)
        repo.remove(items);
    }

    clear(repos.runConfigurations);
    clear(repos.buildConfigurations);
    return removed;
  }

  /// Delete projects (with their configurations) and service bindings of a dev space.
  size_t clearDevSpace(TenantId tenantId, DevSpaceId devSpaceId) {
    size_t removed;
    void clear(R)(R repo) {
      auto items = repo.findByDevSpace(tenantId, devSpaceId);
      removed += items.length;
      if (items.length > 0)
        repo.remove(items);
    }

    clear(repos.runConfigurations);
    clear(repos.buildConfigurations);
    clear(repos.projects);
    clear(repos.serviceBindings);
    return removed;
  }
}
