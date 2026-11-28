/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Driving ports of workspaces, connections to AI runtimes and resource groups.
module uim.platform.ai_launchpad.ports.usecases.runtimes;

import uim.platform.ai_launchpad;

mixin(ShowModule!());

@safe:

interface IManageWorkspaces : IManageResource!(Workspace, WorkspaceId, WorkspaceInput) {
}

interface IManageConnections : IManageResource!(Connection, ConnectionId, ConnectionInput) {
  /// Check endpoint and credentials with the runtime: status active or error.
  Connection validateConnection(TenantId t, ConnectionId id, UserId actor);
}

interface IManageResourceGroups : IManageResource!(ResourceGroup, ResourceGroupId, ResourceGroupInput) {
}
