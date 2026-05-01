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

    CommandResult create(CreateProcessRequest r) {
        auto err = ProcessValidator.validate(r.id, r.name);
        if (err.length > 0)
            return CommandResult(false, "", err);

        auto existing = repo.findById(r.id);
        if (existing.id.length > 0)
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
        return CommandResult(true, p.id, "");
    }

    Process getById(ProcessId id) {
        return repo.findById(id);
    }

    Process[] list(TenantId tenantId) {
        return repo.findByTenant(tenantId);
    }

    Process[] listByProject(ProjectId projectId) {
        return repo.findByProject(projectId);
    }

    CommandResult update(UpdateProcessRequest r) {
        auto existing = repo.findById(r.id);
        if (existing.isNull)
            return CommandResult(false, "", "Process not found");

        existing.name = r.name;
        existing.description = r.description;
        existing.version_ = r.version_;
        existing.modifiedBy = r.modifiedBy;

        import core.time : MonoTime;
        existing.updatedAt = MonoTime.currTime.ticks;

        repo.update(existing);
        return CommandResult(true, existing.id, "");
    }

    CommandResult deploy(DeployProcessRequest r) {
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
        return CommandResult(true, existing.id, "");
    }

    CommandResult remove(ProcessId id) {
        auto existing = repo.findById(id);
        if (existing.isNull)
            return CommandResult(false, "", "Process not found");

        repo.remove(id);
        return CommandResult(true, id.toString, "");
    }
}
