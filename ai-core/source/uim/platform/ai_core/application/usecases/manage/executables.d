/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.ai_core.application.usecases.manage.executables;

import uim.platform.ai_core;

mixin(ShowModule!()); 

@safe:
class ManageExecutablesUseCase {
    protected IExecutableRepository repo;

    this(IExecutableRepository repo) {
        this.repo = repo;
    }

    UsecaseResult createExecutable(CreateExecutableRequest r) {
        if (r.executableId.isEmpty)
            return UsecaseResult(false, "", "Executable ID is required");
        if (r.scenarioId.isEmpty)
            return UsecaseResult(false, "", "Scenario ID is required");
        if (r.resourceGroupId.isEmpty)
            return UsecaseResult(false, "", "Resource group ID is required");

        if (repo.existsById(r.tenantId, r.resourceGroupId, r.executableId))
            return UsecaseResult(false, "", "Executable already exists");

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
        return UsecaseResult(true, executable.id.value, "");
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

    UsecaseResult deleteExecutable(TenantId tenantId, ResourceGroupId resourceGroupId, ExecutableId id) {
        auto executable = repo.findById(tenantId, resourceGroupId, id);
        if (executable.isNull)
            return UsecaseResult(false, "", "Executable not found");

        repo.remove(executable);
        return UsecaseResult(true, executable.id.value, "");
    }
}

///
unittest {
//    auto repo = new ExecutableRepository();
//    auto usecase = new ManageExecutablesUseCase(repo);
//    auto tenantId = TenantId("test-tenant");
//
//    assert(usecase !is null);
}
