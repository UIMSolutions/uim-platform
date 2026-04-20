/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.abap_environment.domain.entities.software_component;

import uim.platform.abap_environment.domain.types;

/// Commit entry in a software component's history.
struct ComponentCommit {
  string commitId;
  string message;
  string author;
  long timestamp;
}

/// ABAP software component (git-managed development object container).
struct SoftwareComponent {
  mixin TenantEntity!(SoftwareComponentId);
  SystemInstanceId systemInstanceId;
  string name;
  string description;
  ComponentType componentType = ComponentType.developmentPackage;
  ComponentStatus status = ComponentStatus.notCloned;

  /// Repository information
  string repositoryUrl;
  string branch;
  BranchStrategy branchStrategy = BranchStrategy.main;
  string currentCommitId;
  ComponentCommit[] commitHistory;

  /// Namespace
  string namespace;
  string softwareComponentVersion;

  /// Metadata
  string clonedBy;
  long clonedAt;
  long lastPulledAt;

  Json toJson() const {
    auto j = entityToJson
      .set("systemInstanceId", systemInstanceId)
      .set("name", name)
      .set("description", description)
      .set("componentType", componentType.to!string)
      .set("status", status.to!string)
      .set("repositoryUrl", repositoryUrl)
      .set("branch", branch)
      .set("branchStrategy", branchStrategy.to!string)
      .set("currentCommitId", currentCommitId)
      .set("namespace", namespace)
      .set("softwareComponentVersion", softwareComponentVersion)
      .set("clonedBy", clonedBy)
      .set("clonedAt", clonedAt)
      .set("lastPulledAt", lastPulledAt);

    if (commitHistory.length > 0) {
      auto history = commitHistory.map!(c => Json.emptyObject
        .set("commitId", c.commitId)
        .set("message", c.message)
        .set("author", c.author)
        .set("timestamp", c.timestamp))();
      j["commitHistory"] = history;
    }

    return j;
  }
}
