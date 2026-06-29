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


import uim.platform.abap_environment;

// // mixin(ShowModule!());

@safe:
/// Application service for software component lifecycle (clone, pull, manage).
class ManageSoftwareComponentsUseCase { // TODO: UIMUseCase {
  private SoftwareComponentRepository repo;
  private SystemInstanceRepository systemRepo;

  this(SoftwareComponentRepository repo, SystemInstanceRepository systemRepo) {
    this.repo = repo;
    this.systemRepo = systemRepo;
  }

  CommandResult createSoftwareComponent(CreateSoftwareComponentRequest req) {
    if (req.name.length == 0)
      return CommandResult(false, "", "Component name is required");
    
    if (req.systemInstanceId.isEmpty)
      return CommandResult(false, "", "System instance ID is required");

    auto system = systemRepo.findById(req.tenantId, req.systemInstanceId);
    if (system.isNull)
      return CommandResult(false, "", "System instance not found");
 
    if (system.status != SystemStatus.active)
      return CommandResult(false, "", "System instance must be active");

    if (repo.existsByName(req.tenantId, req.systemInstanceId, req.name))
      return CommandResult(false, "", "Software component '" ~ req.name ~ "' already exists in this system");

    SoftwareComponent comp;
    comp.initEntity(req.tenantId);
    
    comp.systemInstanceId = req.systemInstanceId;
    comp.name = req.name;
    comp.description = req.description;
    comp.componentType = req.componentType.to!ComponentType;
    comp.status = ComponentStatus.notCloned;
    comp.repositoryUrl = req.repositoryUrl;
    comp.branch = req.branch.length > 0 ? req.branch : "main";
    comp.branchStrategy = req.branchStrategy.to!BranchStrategy;
    comp.namespace = req.namespace;

    repo.save(comp);
    return CommandResult(true, comp.id.value, "");
  }

  CommandResult cloneSoftwareComponent(CloneSoftwareComponentRequest req) {
    auto comp = repo.findById(req.tenantId, req.softwareComponentId);
    if (comp.isNull)
      return CommandResult(false, "", "Software component not found");

    if (comp.status != ComponentStatus.notCloned && comp.status != ComponentStatus.error)
      return CommandResult(false, "", "Component is already cloned or cloning in progress");

    comp.status = ComponentStatus.cloning;
    if (req.branch.length > 0)
      comp.branch = req.branch;

  
    comp.clonedAt = currentTimestamp();
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

  CommandResult pullSoftwareComponent(PullSoftwareComponentRequest req) {
    auto comp = repo.findById(req.tenantId, req.softwareComponentId);
    if (comp.isNull)
      return CommandResult(false, "", "Software component not found");

    if (comp.status != ComponentStatus.cloned)
      return CommandResult(false, "", "Component must be cloned before pulling");

    comp.status = ComponentStatus.pulling;

  
    auto now = currentTimestamp();

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

  SoftwareComponent getSoftwareComponent(TenantId tenantId, SoftwareComponentId id) {
    return repo.findById(tenantId, id);
  }

  SoftwareComponent[] listSoftwareComponents(TenantId tenantId, SystemInstanceId systemId) {
    return repo.findBySystem(tenantId, systemId);
  }

  CommandResult deleteSoftwareComponent(TenantId tenantId, SoftwareComponentId id) {
    auto comp = repo.findById(tenantId, id);
    if (comp.isNull)
      return CommandResult(false, "", "Software component not found");

    repo.remove(comp);
    return CommandResult(true, comp.id.value, "");
  }
}

