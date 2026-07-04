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
        auto err = ProcessValidator.validate(r.tenantId, r.processId, r.name);
        if (err.length > 0)
            return CommandResult(false, "", err);

        auto existing = repo.findById(r.tenantId, r.processId);
        if (!existing.isNull)
            return CommandResult(false, "", "Process already exists");

        auto p = Process(r.tenantId, r.processId, r.createdBy);
        p.projectId = r.projectId;
        p.name = r.name;
        p.description = r.description;
        p.status = ProcessStatus.draft;
        p.version_ = r.version_;

        repo.save(p);
        return CommandResult(true, p.id.value, "");
    }

    Process getProcess(TenantId tenantId, ProcessId processId) {
        return repo.findById(tenantId, processId);
    }

    Process[] listProcesses(TenantId tenantId) {
        return repo.findByTenant(tenantId);
    }

    Process[] listProcesses(TenantId tenantId, ProjectId projectId) {
        return repo.findByProject(tenantId, projectId);
    }

    CommandResult updateProcess(UpdateProcessRequest r) {
        auto process = repo.findById(r.tenantId, r.processId);
        if (process.isNull)
            return CommandResult(false, "", "Process not found");

        process.name = r.name;
        process.description = r.description;
        process.version_ = r.version_;
        process.updatedBy = r.updatedBy;

        
        process.updatedAt = currentTimestamp;

        repo.update(process);
        return CommandResult(true, process.id.value, "");
    }

    CommandResult deployProcess(DeployProcessRequest r) {
        auto process = repo.findById(r.tenantId, r.processId);
        if (process.isNull)
            return CommandResult(false, "", "Process not found");

        switch (r.action) {
        case "activate":
            process.status = ProcessStatus.active;
            break;
        case "deactivate":
            process.status = ProcessStatus.inactive;
            break;
        default:
            return CommandResult(false, "", "Unknown action: " ~ r.action);
        }

        
        process.updatedAt = currentTimestamp;

        repo.update(process);
        return CommandResult(true, process.id.value, "");
    }

    CommandResult deleteProcess(TenantId tenantId, ProcessId processId) {
        auto process = repo.findById(tenantId, processId);
        if (process.isNull)
            return CommandResult(false, "", "Process not found");

        repo.remove(process);
        return CommandResult(true, process.id.value, "");
    }
}
