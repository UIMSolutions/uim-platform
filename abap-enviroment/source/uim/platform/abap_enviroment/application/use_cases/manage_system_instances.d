module application.use_cases.manage_system_instances;

import application.dto;
import domain.entities.system_instance;
import domain.ports.system_instance_repository;
import domain.services.system_lifecycle_validator;
import domain.types;

import std.conv : to;
import std.uuid : randomUUID;

/// Application service for ABAP system instance lifecycle management.
class ManageSystemInstancesUseCase
{
    private SystemInstanceRepository repo;

    this(SystemInstanceRepository repo)
    {
        this.repo = repo;
    }

    CommandResult createInstance(CreateSystemInstanceRequest req)
    {
        if (req.name.length == 0)
            return CommandResult("", "System instance name is required");
        if (req.tenantId.length == 0)
            return CommandResult("", "Tenant ID is required");
        if (req.adminEmail.length == 0)
            return CommandResult("", "Admin email is required");

        // Validate SID
        if (req.sapSystemId.length > 0)
        {
            auto sidResult = SystemLifecycleValidator.validateSid(req.sapSystemId);
            if (!sidResult.valid)
                return CommandResult("", sidResult.error);
        }

        // Unique name per tenant
        auto existing = repo.findByName(req.tenantId, req.name);
        if (existing !is null)
            return CommandResult("", "System instance '" ~ req.name ~ "' already exists");

        auto id = randomUUID().toString();
        SystemInstance inst;
        inst.id = id;
        inst.tenantId = req.tenantId;
        inst.subaccountId = req.subaccountId;
        inst.name = req.name;
        inst.description = req.description;
        inst.plan = parsePlan(req.plan);
        inst.status = SystemStatus.provisioning;
        inst.region = req.region;
        inst.sapSystemId = req.sapSystemId;
        inst.adminEmail = req.adminEmail;
        inst.abapRuntimeSize = req.abapRuntimeSize > 0 ? req.abapRuntimeSize : cast(ushort) 4;
        inst.hanaMemorySize = req.hanaMemorySize > 0 ? req.hanaMemorySize : cast(ushort) 16;
        inst.softwareVersion = req.softwareVersion;
        inst.stackVersion = req.stackVersion;

        import std.datetime.systime : Clock;
        inst.createdAt = Clock.currStdTime();
        inst.updatedAt = inst.createdAt;

        repo.save(inst);
        return CommandResult(id, "");
    }

    CommandResult updateInstance(SystemInstanceId id, UpdateSystemInstanceRequest req)
    {
        auto inst = repo.findById(id);
        if (inst is null)
            return CommandResult("", "System instance not found");

        if (req.description.length > 0) inst.description = req.description;
        if (req.abapRuntimeSize > 0) inst.abapRuntimeSize = req.abapRuntimeSize;
        if (req.hanaMemorySize > 0) inst.hanaMemorySize = req.hanaMemorySize;
        if (req.softwareVersion.length > 0) inst.softwareVersion = req.softwareVersion;

        // Status transition
        if (req.status.length > 0)
        {
            auto newStatus = parseStatus(req.status);
            auto validation = SystemLifecycleValidator.validateTransition(inst.status, newStatus);
            if (!validation.valid)
                return CommandResult("", validation.error);
            inst.status = newStatus;
        }

        import std.datetime.systime : Clock;
        inst.updatedAt = Clock.currStdTime();

        repo.update(*inst);
        return CommandResult(id, "");
    }

    SystemInstance* getInstance(SystemInstanceId id)
    {
        return repo.findById(id);
    }

    SystemInstance[] listInstances(TenantId tenantId)
    {
        return repo.findByTenant(tenantId);
    }

    CommandResult deleteInstance(SystemInstanceId id)
    {
        auto inst = repo.findById(id);
        if (inst is null)
            return CommandResult("", "System instance not found");

        if (inst.status != SystemStatus.active && inst.status != SystemStatus.error
            && inst.status != SystemStatus.suspended)
            return CommandResult("", "System must be in active, suspended, or error status to delete");

        inst.status = SystemStatus.deleting;
        repo.update(*inst);
        return CommandResult(id, "");
    }
}

private SystemPlan parsePlan(string s)
{
    switch (s)
    {
    case "standard": return SystemPlan.standard;
    case "free_": return SystemPlan.free_;
    case "development": return SystemPlan.development;
    case "test": return SystemPlan.test;
    case "production": return SystemPlan.production;
    default: return SystemPlan.standard;
    }
}

private SystemStatus parseStatus(string s)
{
    switch (s)
    {
    case "provisioning": return SystemStatus.provisioning;
    case "active": return SystemStatus.active;
    case "updating": return SystemStatus.updating;
    case "suspended": return SystemStatus.suspended;
    case "deleting": return SystemStatus.deleting;
    case "deleted": return SystemStatus.deleted;
    case "error": return SystemStatus.error;
    default: return SystemStatus.active;
    }
}
