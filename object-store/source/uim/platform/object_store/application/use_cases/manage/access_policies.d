/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.object_store.application.usecases.manage_access_policies;

import uim.platform.object_store.application.dto;
import uim.platform.object_store.domain.entities.access_policy;
import uim.platform.object_store.domain.ports.repositories.access_policy;
import uim.platform.object_store.domain.ports.repositories.bucket;
import uim.platform.object_store.domain.types;

/// Application service for bucket access policy management.
class ManageAccessPoliciesUseCase
{
  private AccessPolicyRepository policyRepo;
  private BucketRepository bucketRepo;

  this(AccessPolicyRepository policyRepo, BucketRepository bucketRepo)
  {
    this.policyRepo = policyRepo;
    this.bucketRepo = bucketRepo;
  }

  CommandResult createPolicy(CreateAccessPolicyRequest req)
  {
    if (req.name.length == 0)
      return CommandResult(false, "", "Policy name is required");
    if (req.bucketId.length == 0)
      return CommandResult(false, "", "Bucket ID is required");

    auto bucket = bucketRepo.findById(req.bucketId);
    if (bucket is null || bucket.id.length == 0)
      return CommandResult(false, "", "Bucket not found");

    // import std.uuid : randomUUID;

    auto id = randomUUID().toString();
    auto ts = currentTimestamp();

    auto policy = new AccessPolicy();
    policy.id = id;
    policy.tenantId = req.tenantId;
    policy.bucketId = req.bucketId;
    policy.name = req.name;
    policy.effect = parseEffect(req.effect);
    policy.principal = req.principal;
    policy.actions = req.actions;
    policy.resources = req.resources;
    policy.createdBy = req.createdBy;
    policy.createdAt = ts;
    policy.updatedAt = ts;

    policyRepo.save(policy);
    return CommandResult(true, id, "");
  }

  CommandResult updatePolicy(AccessPolicyId id, UpdateAccessPolicyRequest req)
  {
    auto policy = policyRepo.findById(id);
    if (policy is null || policy.id.length == 0)
      return CommandResult(false, "", "Policy not found");

    if (req.name.length > 0)
      policy.name = req.name;
    if (req.effect.length > 0)
      policy.effect = parseEffect(req.effect);
    if (req.principal.length > 0)
      policy.principal = req.principal;
    if (req.actions.length > 0)
      policy.actions = req.actions;
    if (req.resources.length > 0)
      policy.resources = req.resources;
    policy.updatedAt = currentTimestamp();

    policyRepo.update(policy);
    return CommandResult(true, id, "");
  }

  AccessPolicy getPolicy(AccessPolicyId id)
  {
    return policyRepo.findById(id);
  }

  AccessPolicy[] listPolicies(BucketId bucketId)
  {
    return policyRepo.findByBucket(bucketId);
  }

  CommandResult deletePolicy(AccessPolicyId id)
  {
    auto policy = policyRepo.findById(id);
    if (policy is null || policy.id.length == 0)
      return CommandResult(false, "", "Policy not found");

    policyRepo.remove(id);
    return CommandResult(true, id, "");
  }
}

private PolicyEffect parseEffect(string s)
{
  switch (s)
  {
  case "deny":
    return PolicyEffect.deny;
  default:
    return PolicyEffect.allow;
  }
}

private long currentTimestamp()
{
  // import std.datetime.systime : Clock;

  return Clock.currStdTime();
}
