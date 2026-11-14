/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.application_studio.application.services.project_status;

import uim.platform.application_studio;

mixin(ShowModule!());

@safe:

/// Keeps a project's status in line with its build configurations:
/// deploying > building > active (archived projects are left alone; a failed
/// latest run of any configuration marks the project as error).
class ProjectStatusSync {
  protected StudioRepositories repos;

  this(StudioRepositories repos) {
    this.repos = repos;
  }

  void sync(TenantId tenantId, ProjectId projectId) {
    auto p = repos.projects.findById(tenantId, projectId);
    if (p.isNull || p.status == ProjectStatus.archived)
      return;
    auto builds = repos.buildConfigurations.findByProject(tenantId, projectId);
    ProjectStatus target = ProjectStatus.active;
    string message;
    if (builds.any!(b => b.status == BuildStatus.deploying))
      target = ProjectStatus.deploying;
    else if (builds.any!(b => b.status == BuildStatus.building))
      target = ProjectStatus.building;
    else {
      auto failed = builds.filter!(b => b.status == BuildStatus.failed).array;
      if (failed.length > 0) {
        target = ProjectStatus.error;
        message = failed.map!(b => b.name ~ ": " ~ b.statusMessage).join("; ");
      }
    }
    if (p.status == target && p.statusMessage == message)
      return;
    p.status = target;
    p.statusMessage = message;
    p.update();
    repos.projects.update(p);
  }
}
