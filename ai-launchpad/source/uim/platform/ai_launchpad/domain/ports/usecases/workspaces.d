/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.ai_launchpad.domain.ports.usecases.workspaces;

import uim.platform.ai_launchpad;

mixin(ShowModule!());

@safe:
interface IManageWorkspacesUseCase { 

  UsecaseResult createWorkspace(CreateWorkspaceRequest r);

  Workspace getWorkspace(TenantId tenantId, WorkspaceId id);

  Workspace[] listWorkspaces(TenantId tenantId);

  UsecaseResult patchWorkspace(PatchWorkspaceRequest r);

  UsecaseResult deleteWorkspace(TenantId tenantId, WorkspaceId id);

}
