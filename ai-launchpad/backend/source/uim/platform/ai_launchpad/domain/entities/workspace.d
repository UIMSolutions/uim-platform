/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// A workspace groups the connections to AI runtimes and the prompt
/// collections of a team. Inactive workspaces take no new connections.
module uim.platform.ai_launchpad.domain.entities.workspace;

import uim.platform.ai_launchpad;

mixin(ShowModule!());

@safe:

struct Workspace {
  mixin TenantEntity!WorkspaceId;

  string name;
  string description;
  WorkspaceStatus status = WorkspaceStatus.active;

  bool isActive() const {
    return status == WorkspaceStatus.active;
  }

  void requireActive(string operation) const {
    if (!isActive)
      throw AilpException.ruleViolation("Workspace '" ~ id.value ~ "' is inactive: " ~ operation ~ " is not possible");
  }

  void validate() const {
    requireId(id.value, "Workspace ID");
    requireText(name, "Workspace name");
    requireMaxLength(name, 200, "Workspace name");
    requireMaxLength(description, 2000, "Description");
  }
}

///
unittest {
  Workspace w;
  w.id = WorkspaceId("ml-team");
  w.name = "ML Team";
  w.validate();
  assert(w.isActive);
  w.status = WorkspaceStatus.inactive;
  assert(failsWith(AilpErrorKind.ruleViolation, () { w.requireActive("Creating a connection"); }));
}
