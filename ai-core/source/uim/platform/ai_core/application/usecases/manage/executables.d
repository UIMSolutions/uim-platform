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

mixin(ShowModule!()); 

@safe:
class ManageExecutablesUseCase { // TODO: UIMUseCase {
    private ExecutableRepository repo;

    this(ExecutableRepository repo) {
        this.repo = repo;
    }

    CommandResult create(CreateExecutableRequest r) {
        if (r.executableId.isNull)
            return CommandResult(false, "", "Executable ID is required");
        if (r.scenarioId.isEmpty)
            return CommandResult(false, "", "Scenario ID is required");
        if (r.resourceGroupId.isEmpty)
            return CommandResult(false, "", "Resource group ID is required");

        auto existing = repo.findById(r.resourceGroupId, r.id);
        if (!existing.isNull)
            return CommandResult(false, "", "Executable already exists");

        Executable e;
        e.id = r.id;
        e.tenantId = r.tenantId;
        e.resourceGroupId = r.resourceGroupId;
        e.scenarioId = r.scenarioId;
        e.name = r.name;
        e.description = r.description;
        e.versionId = r.versionId;
        e.deployable = r.deployable;

        if (r.type == "serving")
            e.type = ExecutableType.serving;
        else
            e.type = ExecutableType.workflow;

        import core.time : MonoTime;

        auto now = MonoTime.currTime.ticks;
        e.createdAt = now;
        e.updatedAt = now;

        repo.save(e);
        return CommandResult(true, e.id.value, "");
    }

    Executable getById(ResourceGroupId rgId, ExecutableId id) {
        return repo.findById(rgId, id);
    }

    Executable[] listByScenario(ResourceGroupId rgId, ScenarioId scenarioId) {
        return repo.findByScenario(rgId, scenarioId);
    }

    Executable[] list(ResourceGroupId rgId) {
        return repo.findByResourceGroup(rgId);
    }

    CommandResult remove(ResourceGroupId rgId, ExecutableId id) {
        auto existing = repo.findById(rgId, id);
        if (existing.isNull)
            return CommandResult(false, "", "Executable not found");

        repo.remove(rgId, id);
        return CommandResult(true, id.value, "");
    }
}
