/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.process_automation.application.usecases.manage.process_instances;

import uim.platform.process_automation;

// mixin(ShowModule!());

@safe:
class ManageProcessInstancesUseCase { // TODO: UIMUseCase {
    private ProcessInstanceRepository repo;

    this(ProcessInstanceRepository repo) {
        this.repo = repo;
    }

    CommandResult startProcessInstance(StartProcessInstanceRequest r) {
        auto err = ProcessValidator.validateInstance(r.tenantId, r.processId, r.startedBy);
        if (err.length > 0)
            return CommandResult(false, "", err);

        ProcessInstance i;
        i.id = r.processInstanceId;
        i.processId = r.processId;
        i.tenantId = r.tenantId;
        i.status = InstanceStatus.running;
        i.startedBy = r.startedBy;
        i.dueDate = r.dueDate;

        
        i.startedAt = currentTimestamp;

        repo.save(i);
        return CommandResult(true, i.id.value, "");
    }

    ProcessInstance getProcessInstance(TenantId tenantId, ProcessInstanceId id) {
        return repo.findById(tenantId, id);
    }

    ProcessInstance[] listProcessInstances(TenantId tenantId) {
        return repo.findByTenant(tenantId);
    }

    ProcessInstance[] listProcessInstances(TenantId tenantId, ProcessId processId) {
        return repo.findByProcess(tenantId, processId);
    }

    ProcessInstance[] listProcessInstances(TenantId tenantId, InstanceStatus status) {
        return repo.findByStatus(tenantId, status);
    }

    CommandResult performProcessInstanceAction(ProcessInstanceActionRequest r) {
        auto existing = repo.findById(r.tenantId, r.processInstanceId);
        if (existing.isNull)
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
            
            existing.completedAt = currentTimestamp;
            break;
        case "retry":
            existing.status = InstanceStatus.running;
            existing.retryCount = existing.retryCount + 1;
            break;
        default:
            return CommandResult(false, "", "Unknown action: " ~ r.action);
        }

        repo.update(existing);
        return CommandResult(true, existing.id.value, "");
    }

    CommandResult deleteProcessInstance(TenantId tenantId, ProcessInstanceId id) {
        auto instance = repo.findById(tenantId, id);
        if (instance.isNull)
            return CommandResult(false, "", "Process instance not found");

        repo.remove(instance);
        return CommandResult(true, instance.id.value, "");
    }
}
