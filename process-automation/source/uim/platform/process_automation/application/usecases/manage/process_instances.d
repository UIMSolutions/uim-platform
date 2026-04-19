/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.process_automation.application.usecases.manage.process_instances;

import uim.platform.process_automation;

mixin(ShowModule!());

@safe:
class ManageProcessInstancesUseCase { // TODO: UIMUseCase {
    private ProcessInstanceRepository repo;

    this(ProcessInstanceRepository repo) {
        this.repo = repo;
    }

    CommandResult start(StartProcessInstanceRequest r) {
        auto err = ProcessValidator.validateInstance(r.processId, r.startedBy);
        if (err.length > 0)
            return CommandResult(false, "", err);

        ProcessInstance i;
        i.id = r.id;
        i.processId = r.processId;
        i.tenantId = r.tenantId;
        i.status = InstanceStatus.running;
        i.startedBy = r.startedBy;
        i.dueDate = r.dueDate;

        import core.time : MonoTime;
        i.startedAt = MonoTime.currTime.ticks;

        repo.save(i);
        return CommandResult(true, i.id, "");
    }

    ProcessInstance getById(ProcessInstanceId id) {
        return repo.findById(id);
    }

    ProcessInstance[] list(TenantId tenantId) {
        return repo.findByTenant(tenantId);
    }

    ProcessInstance[] listByProcess(ProcessId processId) {
        return repo.findByProcess(processId);
    }

    ProcessInstance[] listByStatus(TenantId tenantId, InstanceStatus status) {
        return repo.findByStatus(tenantId, status);
    }

    CommandResult performAction(ProcessInstanceActionRequest r) {
        auto existing = repo.findById(r.id);
        if (existing.id.isEmpty)
            return CommandResult(false, "", "Process instance not found");

        switch (r.action) {
        case "suspend":
            existing.status = InstanceStatus.suspended;
            break;
        case "resume":
            existing.status = InstanceStatus.running;
            break;
        case "cancel":
            existing.status = InstanceStatus.cancelled;
            import core.time : MonoTime;
            existing.completedAt = MonoTime.currTime.ticks;
            break;
        case "retry":
            existing.status = InstanceStatus.running;
            existing.retryCount = existing.retryCount + 1;
            break;
        default:
            return CommandResult(false, "", "Unknown action: " ~ r.action);
        }

        repo.update(existing);
        return CommandResult(true, existing.id, "");
    }

    CommandResult remove(ProcessInstanceId id) {
        auto existing = repo.findById(id);
        if (existing.id.isEmpty)
            return CommandResult(false, "", "Process instance not found");

        repo.remove(id);
        return CommandResult(true, id.toString, "");
    }
}
