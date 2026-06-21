/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.ai_core.application.usecases.manage.executables;
// import uim.platform.ai_core.domain.types;
// import uim.platform.ai_core.domain.entities.executable;
// import uim.platform.ai_core.domain.ports.repositories.executables;
// import uim.platform.ai_core.application.dto;
import uim.platform.ai_core;

// mixin(ShowModule!()); 

@safe:
class ManageExecutablesUseCase { // TODO: UIMUseCase {
    private ExecutableRepository repo;

    this(ExecutableRepository repo) {
        this.repo = repo;
    }

    CommandResult createExecutable(CreateExecutableRequest r) {
        if (r.executableId.isEmpty)
            return CommandResult(false, "", "Executable ID is required");
        if (r.scenarioId.isEmpty)
            return CommandResult(false, "", "Scenario ID is required");
        if (r.resourceGroupId.isEmpty)
            return CommandResult(false, "", "Resource group ID is required");

        if (repo.existsById(r.tenantId, r.resourceGroupId, r.executableId))
            return CommandResult(false, "", "Executable already exists");

        auto executable = Executable(r.tenantId);
        executable.id = r.executableId;
        executable.tenantId = r.tenantId;
        executable.resourceGroupId = r.resourceGroupId;
        executable.scenarioId = r.scenarioId;
        executable.name = r.name;
        executable.description = r.description;
        executable.versionId = r.versionId;
        executable.deployable = r.deployable;
        executable.type = r.type == "serving" ? ExecutableType.serving : ExecutableType.workflow;

        repo.save(executable);
        return CommandResult(true, executable.id.value, "");
    }

    Executable getExecutable(TenantId tenantId, ResourceGroupId resourceGroupId, ExecutableId id) {
        return repo.findById(tenantId, resourceGroupId, id);
    }

    Executable[] listExecutables(TenantId tenantId, ResourceGroupId resourceGroupId, ScenarioId scenarioId) {
        return repo.findByScenario(tenantId, resourceGroupId, scenarioId);
    }

    Executable[] listExecutables(TenantId tenantId, ResourceGroupId resourceGroupId) {
        return repo.findByResourceGroup(tenantId, resourceGroupId);
    }

    CommandResult deleteExecutable(TenantId tenantId, ResourceGroupId resourceGroupId, ExecutableId id) {
        auto executable = repo.findById(tenantId, resourceGroupId, id);
        if (executable.isNull)
            return CommandResult(false, "", "Executable not found");

        repo.remove(executable);
        return CommandResult(true, executable.id.value, "");
    }
}
