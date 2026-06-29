/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.feature_flags.application.usecases.manage.service_instances;

import uim.platform.feature_flags;

// mixin(ShowModule!());

@safe:

class ManageServiceInstancesUseCase {
    private ServiceInstanceRepository repo;
    private AuditEntryRepository      audit;

    this(ServiceInstanceRepository repo, AuditEntryRepository audit) {
        this.repo  = repo;
        this.audit = audit;
    }

    ServiceInstance getInstance(TenantId tenantId, ServiceInstanceId id) {
        return repo.findById(tenantId, id);
    }

    ServiceInstance[] listInstances(TenantId tenantId) {
        return repo.findByTenant(tenantId);
    }

    FlagResult createInstance(CreateServiceInstanceRequest req) {
        if (req.name.length == 0)
            return FlagResult(false, "", "Instance name is required");

        ServiceInstance inst;
        inst.id          = ServiceInstanceId(generateId());
        inst.tenantId    = req.name;  // tenantId passed via name context placeholder
        inst.name        = req.name;
        inst.description = req.description;
        inst.bindingGuid = req.bindingGuid;
        inst.labels      = req.labels;
        inst.createdAt   = currentTimestamp();
        inst.updatedAt   = inst.createdAt;
        inst.createdBy   = req.createdBy;

        repo.save(inst);
        appendAudit(inst.tenantId, AuditAction.created_, "ServiceInstance", inst.id.value, inst.name, req.createdBy);
        return FlagResult(true, inst.id.value, "");
    }

    FlagResult updateInstance(TenantId tenantId, ServiceInstanceId id, UpdateServiceInstanceRequest req) {
        auto inst = repo.findById(tenantId, id);
        if (inst.isNull)
            return FlagResult(false, "", "Service instance not found");

        if (req.description.length > 0) inst.description = req.description;
        if (req.labels.length > 0)      inst.labels      = req.labels;
        inst.updatedAt = currentTimestamp();
        inst.updatedBy = req.updatedBy;

        repo.update(inst);
        appendAudit(tenantId, AuditAction.updated_, "ServiceInstance", id.value, inst.name, req.updatedBy);
        return FlagResult(true, id.value, "");
    }

    FlagResult deleteInstance(TenantId tenantId, ServiceInstanceId id, string deletedBy = "") {
        auto inst = repo.findById(tenantId, id);
        if (inst.isNull)
            return FlagResult(false, "", "Service instance not found");

        repo.remove(inst);
        appendAudit(tenantId, AuditAction.deleted_, "ServiceInstance", id.value, inst.name, deletedBy);
        return FlagResult(true, id.value, "");
    }

    private:

    void appendAudit(TenantId tenantId, AuditAction action_, string entityType,
                     string entityId, string entityName, string performedBy) {
        AuditEntry entry;
        entry.id          = AuditEntryId(generateId());
        entry.tenantId    = tenantId;
        entry.action_     = action_;
        entry.entityType  = entityType;
        entry.entityId    = entityId;
        entry.entityName  = entityName;
        entry.performedBy = performedBy;
        entry.performedAt = currentTimestamp();
        audit.append(entry);
    }

    string generateId() {
        import std.uuid : randomUUID;
        return randomUUID().toString();
    }

    string currentTimestamp() {
        import std.datetime : Clock, UTC;
        return Clock.currTime(UTC()).toISOExtString();
    }
}
