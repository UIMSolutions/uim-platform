/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.process_automation.application.usecases.manage.processes;

import uim.platform.process_automation;

mixin(ShowModule!());

@safe:
class ManageProcessesUseCase { // TODO: UIMUseCase {
    private ProcessRepository repo;

    this(ProcessRepository repo) {
        this.repo = repo;
    }

    CommandResult createProcess(CreateProcessRequest r) {
        auto err = ProcessValidator.validate(r.id, r.name);
        if (err.length > 0)
            return CommandResult(false, "", err);

        auto existing = repo.findById(r.id);
        if (!existing.isNull)
            return CommandResult(false, "", "Process already exists");

        Process p;
        p.id = r.id;
        p.tenantId = r.tenantId;
        p.projectId = r.projectId;
        p.name = r.name;
        p.description = r.description;
        p.status = ProcessStatus.draft;
        p.version_ = r.version_;
        p.createdBy = r.createdBy;

        import core.time : MonoTime;
        auto now = MonoTime.currTime.ticks;
        p.createdAt = now;
        p.updatedAt = now;

        repo.save(p);
        return CommandResult(true, p.id.value, "");
    }

    Process getProcess(ProcessId id) {
        return repo.findById(tenantId, id);
    }

    Process[] listProcesses(TenantId tenantId) {
        return repo.findByTenant(tenantId);
    }

    Process[] listProcesses(ProjectId projectId) {
        return repo.findByProject(projectId);
    }

    CommandResult updateProcess(UpdateProcessRequest r) {
        auto existing = repo.findById(r.id);
        if (existing.isNull)
            return CommandResult(false, "", "Process not found");

        existing.name = r.name;
        existing.description = r.description;
        existing.version_ = r.version_;
        existing.updatedBy = r.updatedBy;

        import core.time : MonoTime;
        existing.updatedAt = MonoTime.currTime.ticks;

        repo.update(existing);
        return CommandResult(true, existing.id.value, "");
    }

    CommandResult deployProcess(DeployProcessRequest r) {
        auto existing = repo.findById(r.id);
        if (existing.isNull)
            return CommandResult(false, "", "Process not found");

        switch (r.action) {
        case "activate":
            existing.status = ProcessStatus.active;
            break;
        case "deactivate":
            existing.status = ProcessStatus.inactive;
            break;
        default:
            return CommandResult(false, "", "Unknown action: " ~ r.action);
        }

        import core.time : MonoTime;
        existing.updatedAt = MonoTime.currTime.ticks;

        repo.update(existing);
        return CommandResult(true, existing.id.value, "");
    }

    CommandResult deleteProcess(ProcessId id) {
        auto process = repo.findById(tenantId, id);
        if (process.isNull)
            return CommandResult(false, "", "Process not found");

        repo.remove(process);
        return CommandResult(true, id.value, "");
    }
}
