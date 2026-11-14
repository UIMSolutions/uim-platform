/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.application_studio.ports.usecases.projects;

import uim.platform.application_studio;

mixin(ShowModule!());

@safe:

/// Projects of a dev space (scaffolded from templates). Removal cascades to
/// the project's run and build configurations.
interface IManageProjectsUseCase : IManageResource!(Project, ProjectId, CreateProjectRequest, UpdateProjectRequest) {
  UsecaseResult archive(TenantId tenantId, ProjectId id, UserId actor);
  UsecaseResult restore(TenantId tenantId, ProjectId id, UserId actor);
}
