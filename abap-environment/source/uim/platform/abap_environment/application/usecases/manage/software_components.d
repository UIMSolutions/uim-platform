/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.abap_environment.application.usecases.manage.software_components;

// import uim.platform.abap_environment.application.dto;
// import uim.platform.abap_environment.domain.entities.software_component;
// import uim.platform.abap_environment.domain.ports.repositories.software_components;
// import uim.platform.abap_environment.domain.ports.repositories.system_instances;
// import uim.platform.abap_environment.domain.types;

// import std.conv : to;
// import std.uuid : randomUUID;
import uim.platform.abap_environment;

mixin(ShowModule!());

@safe:
/// Application service for software component lifecycle (clone, pull, manage).
class ManageSoftwareComponentsUseCase { // TODO: UIMUseCase {
  private SoftwareComponentRepository repo;
  private SystemInstanceRepository systemRepo;

  this(SoftwareComponentRepository repo, SystemInstanceRepository systemRepo) {
    this.repo = repo;
    this.systemRepo = systemRepo;
  }

  CommandResult createComponent(CreateSoftwareComponentRequest req) {
    if (req.name.length == 0)
      return CommandResult(false, "", "Component name is required");
    if (req.systemInstanceId.isEmpty)
      return CommandResult(false, "", "System instance ID is required");

    if (!systemRepo.existsById(req.systemInstanceId))
      return CommandResult(false, "", "System instance not found");
 
    auto system = systemRepo.findById(req.systemInstanceId);
    if (system.status != SystemStatus.active)
      return CommandResult(false, "", "System instance must be active");

    if (repo.existsByName(req.systemInstanceId, req.name))
      return CommandResult(false, "", "Software component '" ~ req.name ~ "' already exists in this system");

    SoftwareComponent comp;
    comp.id = randomUUID();
    comp.tenantId = req.tenantId;
    comp.systemInstanceId = req.systemInstanceId;
    comp.name = req.name;
    comp.description = req.description;
    comp.componentType = req.componentType.to!ComponentType;
    comp.status = ComponentStatus.notCloned;
    comp.repositoryUrl = req.repositoryUrl;
    comp.branch = req.branch.length > 0 ? req.branch : "main";
    comp.branchStrategy = req.branchStrategy.to!BranchStrategy;
    comp.namespace = req.namespace;

    // import std.datetime.systime : Clock;
    comp.createdAt = Clock.currStdTime();
    comp.updatedAt = comp.createdAt;

    repo.save(comp);
    return CommandResult(true, comp.id.value, "");
  }

  CommandResult cloneComponent(string id, CloneSoftwareComponentRequest req) {
    return cloneComponent(SoftwareComponentId(id), req);
  }

  CommandResult cloneComponent(SoftwareComponentId id, CloneSoftwareComponentRequest req) {
    if (!repo.existsById(id))
      return CommandResult(false, "", "Software component not found");

    auto comp = repo.findById(id);
    if (comp.status != ComponentStatus.notCloned && comp.status != ComponentStatus.error)
      return CommandResult(false, "", "Component is already cloned or cloning in progress");

    comp.status = ComponentStatus.cloning;
    if (req.branch.length > 0)
      comp.branch = req.branch;

    // import std.datetime.systime : Clock;
    comp.clonedAt = Clock.currStdTime();
    comp.updatedAt = comp.clonedAt;

    // Simulate successful clone
    comp.status = ComponentStatus.cloned;
    comp.currentCommitId = req.commitId.length > 0 ? req.commitId : randomUUID().toString()[0 .. 8];

    ComponentCommit commit;
    commit.commitId = comp.currentCommitId;
    commit.message = "Initial clone";
    commit.author = "system";
    commit.timestamp = comp.clonedAt;
    comp.commitHistory ~= commit;

    repo.update(comp);
    return CommandResult(true, comp.id.value, "");
  }

  CommandResult pullComponent(SoftwareComponentId id, PullSoftwareComponentRequest req) {
    if (!repo.existsById(id))
      return CommandResult(false, "", "Software component not found");

    auto comp = repo.findById(id);
    if (comp.status != ComponentStatus.cloned)
      return CommandResult(false, "", "Component must be cloned before pulling");

    comp.status = ComponentStatus.pulling;

    // import std.datetime.systime : Clock;
    auto now = Clock.currStdTime();

    // Simulate pull
    comp.status = ComponentStatus.cloned;
    comp.currentCommitId = req.commitId.length > 0 ? req.commitId : randomUUID().toString()[0 .. 8];
    comp.lastPulledAt = now;
    comp.updatedAt = now;

    ComponentCommit commit;
    commit.commitId = comp.currentCommitId;
    commit.message = "Pull";
    commit.author = "system";
    commit.timestamp = now;
    comp.commitHistory ~= commit;

    repo.update(comp);
    return CommandResult(true, comp.id.value, "");
  }

  SoftwareComponent getComponent(SoftwareComponentId id) {
    return repo.findById(id);
  }

  SoftwareComponent[] listComponents(SystemInstanceId systemId) {
    return repo.findBySystem(systemId);
  }

  CommandResult deleteComponent(SoftwareComponentId id) {
    if (!repo.existsById(id))
      return CommandResult(false, "", "Software component not found");

    repo.removeById(id);
    return CommandResult(true, id.value, "");
  }
}

private ComponentType parseComponentType(string componentType) {
  switch (componentType) {
  case "developmentPackage":
    return ComponentType.developmentPackage;
  case "businessConfiguration":
    return ComponentType.businessConfiguration;
  case "extensibility":
    return ComponentType.extensibility;
  case "customCode":
    return ComponentType.customCode;
  default:
    return ComponentType.developmentPackage;
  }
}

private BranchStrategy parseBranchStrategy(string branchStrategy) {
  switch (branchStrategy) {
  case "main":
    return BranchStrategy.main;
  case "release":
    return BranchStrategy.release;
  case "feature":
    return BranchStrategy.feature;
  case "correction":
    return BranchStrategy.correction;
  default:
    return BranchStrategy.main;
  }
}
