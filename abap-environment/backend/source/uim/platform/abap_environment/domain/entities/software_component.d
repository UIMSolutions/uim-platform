/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.abap_environment.domain.entities.software_component;

import uim.platform.abap_environment;

mixin(ShowModule!());

@safe:

/// A git-managed software component (gCTS repository) cloned into a system.
struct SoftwareComponent {
  mixin TenantEntity!SoftwareComponentId;

  SystemInstanceId systemInstanceId;
  string systemName;
  string name; /// e.g. "/DMO/FLIGHT" or "ZTRAVEL"
  string description;
  ComponentType componentType = ComponentType.development;
  ComponentStatus status = ComponentStatus.notCloned;
  string statusMessage;

  // Repository
  string repositoryUrl;
  string branch = "main";
  BranchStrategy branchStrategy = BranchStrategy.main;
  string currentCommitId;
  ComponentCommit[] commitHistory;

  string namespace; /// e.g. "/DMO/"
  string softwareComponentVersion;
  UserId clonedBy;
  long clonedAt;
  long lastPulledAt;
}
