module uim.platform.identity_authentication.application.usecases.manage_policies;

// import uim.platform.identity_authentication.domain.entities.policy;
// import uim.platform.identity_authentication.domain.types;
// import uim.platform.identity_authentication.domain.ports.policy;
// import uim.platform.identity_authentication.application.dto;
// 
// // import std.uuid;
// // import std.datetime.systime : Clock;
import uim.platform.identity_authentication;
mixin(ShowModule!());
@safe:
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
