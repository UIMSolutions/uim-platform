/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.workzone.domain.services.workspace_access;

import uim.platform.workzone.domain.types;
import uim.platform.workzone.domain.entities.workspace;

/// Domain service — evaluates workspace membership and access rules.
struct WorkspaceAccessService
{
  /// Check whether a user is a member of the given workspace.
  static bool isMember(const ref Workspace ws, UserId userId)
  {
    foreach (ref m; ws.members)
      if (m.userId == userId)
        return true;
    return false;
  }

  /// Check whether a user has at least the given role in a workspace.
  static bool hasRole(const ref Workspace ws, UserId userId, MemberRole requiredRole)
  {
    foreach (ref m; ws.members)
    {
      if (m.userId == userId && m.role >= requiredRole)
        return true;
    }
    return false;
  }

  /// Check whether a user may administer the workspace.
  static bool isAdmin(const ref Workspace ws, UserId userId)
  {
    return hasRole(ws, userId, MemberRole.admin);
  }

  /// Check if the workspace is in a usable state.
  static bool isAccessible(const ref Workspace ws)
  {
    return ws.status == WorkspaceStatus.active;
  }
}
