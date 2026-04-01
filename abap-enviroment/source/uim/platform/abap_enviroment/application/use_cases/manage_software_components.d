module uim.platform.abap_enviroment.application.usecases.manage_software_components;

import uim.platform.abap_enviroment.application.dto;
import uim.platform.abap_enviroment.domain.entities.software_component;
import uim.platform.abap_enviroment.domain.ports.software_component_repository;
import uim.platform.abap_enviroment.domain.ports.system_instance_repository;
import uim.platform.abap_enviroment.domain.types;

import std.conv : to;
import std.uuid : randomUUID;

/// Application service for software component lifecycle (clone, pull, manage).
class ManageSoftwareComponentsUseCase
{
    private SoftwareComponentRepository repo;
    private SystemInstanceRepository systemRepo;

    this(SoftwareComponentRepository repo, SystemInstanceRepository systemRepo)
    {
        this.repo = repo;
        this.systemRepo = systemRepo;
    }

    CommandResult createComponent(CreateSoftwareComponentRequest req)
    {
        if (req.name.length == 0)
            return CommandResult("", "Component name is required");
        if (req.systemInstanceId.length == 0)
            return CommandResult("", "System instance ID is required");

        auto system = systemRepo.findById(req.systemInstanceId);
        if (system is null)
            return CommandResult("", "System instance not found");
        if (system.status != SystemStatus.active)
            return CommandResult("", "System instance must be active");

        auto existing = repo.findByName(req.systemInstanceId, req.name);
        if (existing !is null)
            return CommandResult("", "Software component '" ~ req.name ~ "' already exists in this system");

        auto id = randomUUID().toString();
        SoftwareComponent comp;
        comp.id = id;
        comp.tenantId = req.tenantId;
        comp.systemInstanceId = req.systemInstanceId;
        comp.name = req.name;
        comp.description = req.description;
        comp.componentType = parseComponentType(req.componentType);
        comp.status = ComponentStatus.notCloned;
        comp.repositoryUrl = req.repositoryUrl;
        comp.branch = req.branch.length > 0 ? req.branch : "main";
        comp.branchStrategy = parseBranchStrategy(req.branchStrategy);
        comp.namespace = req.namespace;

        import std.datetime.systime : Clock;
        comp.createdAt = Clock.currStdTime();
        comp.updatedAt = comp.createdAt;

        repo.save(comp);
        return CommandResult(id, "");
    }

    CommandResult cloneComponent(SoftwareComponentId id, CloneSoftwareComponentRequest req)
    {
        auto comp = repo.findById(id);
        if (comp is null)
            return CommandResult("", "Software component not found");

        if (comp.status != ComponentStatus.notCloned && comp.status != ComponentStatus.error)
            return CommandResult("", "Component is already cloned or cloning in progress");

        comp.status = ComponentStatus.cloning;
        if (req.branch.length > 0) comp.branch = req.branch;

        import std.datetime.systime : Clock;
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

        repo.update(*comp);
        return CommandResult(id, "");
    }

    CommandResult pullComponent(SoftwareComponentId id, PullSoftwareComponentRequest req)
    {
        auto comp = repo.findById(id);
        if (comp is null)
            return CommandResult("", "Software component not found");

        if (comp.status != ComponentStatus.cloned)
            return CommandResult("", "Component must be cloned before pulling");

        comp.status = ComponentStatus.pulling;

        import std.datetime.systime : Clock;
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

        repo.update(*comp);
        return CommandResult(id, "");
    }

    SoftwareComponent* getComponent(SoftwareComponentId id)
    {
        return repo.findById(id);
    }

    SoftwareComponent[] listComponents(SystemInstanceId systemId)
    {
        return repo.findBySystem(systemId);
    }

    CommandResult deleteComponent(SoftwareComponentId id)
    {
        auto comp = repo.findById(id);
        if (comp is null)
            return CommandResult("", "Software component not found");

        repo.remove(id);
        return CommandResult(id, "");
    }
}

private ComponentType parseComponentType(string s)
{
    switch (s)
    {
    case "developmentPackage": return ComponentType.developmentPackage;
    case "businessConfiguration": return ComponentType.businessConfiguration;
    case "extensibility": return ComponentType.extensibility;
    case "customCode": return ComponentType.customCode;
    default: return ComponentType.developmentPackage;
    }
}

private BranchStrategy parseBranchStrategy(string s)
{
    switch (s)
    {
    case "main": return BranchStrategy.main;
    case "release": return BranchStrategy.release;
    case "feature": return BranchStrategy.feature;
    case "correction": return BranchStrategy.correction;
    default: return BranchStrategy.main;
    }
}
