module application.usecases.manage_retention;

import std.uuid;
import std.datetime.systime : Clock;

import uim.platform.auditlog.domain.types;
import uim.platform.auditlog.domain.entities.retention_policy;
import uim.platform.auditlog.domain.ports.retention_policy_repository;
import application.dto;

class ManageRetentionUseCase
{
    private RetentionPolicyRepository repo;

    this(RetentionPolicyRepository repo)
    {
        this.repo = repo;
    }

    CommandResult createPolicy(CreateRetentionPolicyRequest req)
    {
        if (req.tenantId.length == 0)
            return CommandResult("", "Tenant ID is required");
        if (req.name.length == 0)
            return CommandResult("", "Policy name is required");
        if (req.retentionDays <= 0)
            return CommandResult("", "Retention days must be positive");

        auto now = Clock.currStdTime();
        auto policy = RetentionPolicy();
        policy.id = randomUUID().toString();
        policy.tenantId = req.tenantId;
        policy.name = req.name;
        policy.description = req.description;
        policy.retentionDays = req.retentionDays;
        policy.categories = req.categories;
        policy.isDefault = req.isDefault;
        policy.status = RetentionStatus.active;
        policy.createdAt = now;
        policy.updatedAt = now;

        repo.save(policy);
        return CommandResult(policy.id, "");
    }

    RetentionPolicy* getPolicy(RetentionPolicyId id, TenantId tenantId)
    {
        return repo.findById(id, tenantId);
    }

    RetentionPolicy[] listPolicies(TenantId tenantId)
    {
        return repo.findByTenant(tenantId);
    }

    CommandResult updatePolicy(UpdateRetentionPolicyRequest req)
    {
        auto policy = repo.findById(req.id, req.tenantId);
        if (policy is null)
            return CommandResult("", "Retention policy not found");

        if (req.name.length > 0) policy.name = req.name;
        if (req.description.length > 0) policy.description = req.description;
        if (req.retentionDays > 0) policy.retentionDays = req.retentionDays;
        if (req.categories.length > 0) policy.categories = req.categories;
        policy.status = req.status;
        policy.updatedAt = Clock.currStdTime();

        repo.update(*policy);
        return CommandResult(policy.id, "");
    }

    void deletePolicy(RetentionPolicyId id, TenantId tenantId)
    {
        repo.remove(id, tenantId);
    }
}
