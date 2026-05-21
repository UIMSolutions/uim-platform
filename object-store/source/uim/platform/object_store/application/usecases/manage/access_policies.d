/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.object_store.application.usecases.manage.access_policies;
// import uim.platform.object_store.application.dto;
// import uim.platform.object_store.domain.entities.access_policy;
// import uim.platform.object_store.domain.ports.repositories.access_policy;
// import uim.platform.object_store.domain.ports.repositories.bucket;
// import uim.platform.object_store.domain.types;
import uim.platform.object_store;

mixin(ShowModule!());

@safe:
/// Application service for bucket access policy management.
class ManageAccessPoliciesUseCase { // TODO: UIMUseCase {
  private AccessPolicyRepository policyRepo;
  private BucketRepository bucketRepo;

  this(AccessPolicyRepository policyRepo, BucketRepository bucketRepo) {
    this.policyRepo = policyRepo;
    this.bucketRepo = bucketRepo;
  }

  CommandResult createAccessPolicy(CreateAccessPolicyRequest req) {
    if (req.name.length == 0)
      return CommandResult(false, "", "Policy name is required");

    if (req.bucketId.isEmpty)
      return CommandResult(false, "", "Bucket ID is required");

    auto bucket = bucketRepo.findById(req.tenantId, req.bucketId);
    if (bucket.isNull)
      return CommandResult(false, "", "Bucket not found");

    AccessPolicy policy;
    policy.initEntity(req.tenantId, req.createdBy);
    policy.bucketId = req.bucketId;
    policy.name = req.name;
    policy.effect = req.effect.to!PolicyEffect;
    policy.principal = req.principal;
    policy.actions = req.actions;
    policy.resources = req.resources;
 
    policyRepo.save(policy);
    return CommandResult(true, policy.id.value, "");
  }

  CommandResult updateAccessPolicy(UpdateAccessPolicyRequest req) {
    auto policy = policyRepo.findById(req.tenantId, req.accessPolicyId);
    if (policy.isNull)
      return CommandResult(false, "", "Policy not found");

    if (req.name.length > 0)
      policy.name = req.name;
    // if (req.effect.length > 0)
    //   policy.effect = parseEffect(req.effect);
    if (req.principal.length > 0)
      policy.principal = req.principal;
    if (req.actions.length > 0)
      policy.actions = req.actions;
    if (req.resources.length > 0)
      policy.resources = req.resources;
    policy.updatedAt = currentTimestamp();

    policyRepo.update(policy);
    return CommandResult(true, policy.id.value, "");
  }

  AccessPolicy getAccessPolicy(TenantId tenantId, AccessPolicyId id) {
    return policyRepo.findById(tenantId, id);
  }

  AccessPolicy[] listAccessPolicies(TenantId tenantId, BucketId bucketId) {
    return policyRepo.findByBucket(tenantId, bucketId);
  }

  CommandResult deleteAccessPolicy(UpdateAccessPolicyRequest req) {
    auto policy = policyRepo.findById(req.tenantId, req.accessPolicyId);
    if (policy.isNull)
      return CommandResult(false, "", "Access policy not found");

    policyRepo.remove(policy);
    return CommandResult(true, policy.id.value, "");
  }
}

