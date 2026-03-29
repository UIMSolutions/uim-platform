module application.use_cases.manage_policies;

import domain.entities.policy;
import domain.types;
import domain.ports.policy_repository;
import application.dto;

import std.uuid;
import std.datetime.systime : Clock;

/// Application use case: authorization policy management.
class ManagePoliciesUseCase
{
    private PolicyRepository policyRepo;

    this(PolicyRepository policyRepo)
    {
        this.policyRepo = policyRepo;
    }

    PolicyResponse createPolicy(CreatePolicyRequest req)
    {
        auto now = Clock.currStdTime();
        auto policy = AuthorizationPolicy(
            randomUUID().toString(),
            req.tenantId,
            req.name,
            req.description,
            req.rules,
            req.applicationIds,
            true,
            now,
            now
        );
        policyRepo.save(policy);
        return PolicyResponse(policy.id, "");
    }

    AuthorizationPolicy getPolicy(PolicyId id)
    {
        return policyRepo.findById(id);
    }

    AuthorizationPolicy[] listPolicies(TenantId tenantId)
    {
        return policyRepo.findByTenant(tenantId);
    }

    string deletePolicy(PolicyId id)
    {
        policyRepo.remove(id);
        return "";
    }
}
