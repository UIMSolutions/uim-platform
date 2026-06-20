/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.object_store.application.usecases.manage.lifecycle_rules;
// import uim.platform.object_store.application.dto;
// import uim.platform.object_store.domain.entities.lifecycle_rule;
// import uim.platform.object_store.domain.ports.repositories.lifecycle_rule;
// import uim.platform.object_store.domain.ports.repositories.bucket;
// import uim.platform.object_store.domain.types;

import uim.platform.object_store;

mixin(ShowModule!());

@safe:
/// Application service for lifecycle rule management.
class ManageLifecycleRulesUseCase { // TODO: UIMUseCase {
  private LifecycleRuleRepository ruleRepo;
  private BucketRepository bucketRepo;

  this(LifecycleRuleRepository ruleRepo, BucketRepository bucketRepo) {
    this.ruleRepo = ruleRepo;
    this.bucketRepo = bucketRepo;
  }

  CommandResult createRule(CreateLifecycleRuleRequest req) {
    if (req.bucketId.isEmpty)
      return CommandResult(false, "", "Bucket ID is required");
    if (req.name.length == 0)
      return CommandResult(false, "", "Rule name is required");

    auto bucket = bucketRepo.findById(req.tenantId, req.bucketId);
    if (bucket.isNull)
      return CommandResult(false, "", "Bucket not found");

    LifecycleRule rule;
    rule.initEntity(req.tenantId, req.createdBy);
    rule.bucketId = req.bucketId;
    rule.name = req.name;
    rule.prefix = req.prefix;
    rule.status = req.status.to!RuleStatus;
    rule.expirationDays = req.expirationDays;
    rule.transitionDays = req.transitionDays;
    rule.transitionStorageClass = req.transitionStorageClass.to!StorageClass;
    rule.abortIncompleteUploadDays = req.abortIncompleteUploadDays;

    ruleRepo.save(rule);
    return CommandResult(true, rule.id.value, "");
  }

  CommandResult updateRule(UpdateLifecycleRuleRequest req) {
    auto rule = ruleRepo.findById(req.tenantId, req.lifecycleRuleId);
    if (rule.isNull)
      return CommandResult(false, "", "Lifecycle rule not found");

    if (req.name.length > 0)
      rule.name = req.name;
    if (req.prefix.length > 0)
      rule.prefix = req.prefix;
    if (req.status.length > 0)
      rule.status = req.status.to!RuleStatus;
    if (req.expirationDays > 0)
      rule.expirationDays = req.expirationDays;
    if (req.transitionDays > 0)
      rule.transitionDays = req.transitionDays;
    if (req.transitionStorageClass.length > 0)
      rule.transitionStorageClass = req.transitionStorageClass.to!StorageClass;
    if (req.abortIncompleteUploadDays > 0)
      rule.abortIncompleteUploadDays = req.abortIncompleteUploadDays;
    rule.updatedAt = currentTimestamp();

    ruleRepo.update(rule);
    return CommandResult(true, rule.id.value, "");
  }

  LifecycleRule getRule(TenantId tenantId, LifecycleRuleId lifecycleRuleId) {
    return ruleRepo.findById(tenantId, lifecycleRuleId);
  }

  LifecycleRule[] listRules(TenantId tenantId, BucketId bucketId) {
    return ruleRepo.findByBucket(tenantId, bucketId);
  }

  CommandResult deleteRule(TenantId tenantId, LifecycleRuleId lifecycleRuleId) {
    auto rule = ruleRepo.findById(tenantId, lifecycleRuleId);
    if (rule.isNull)
      return CommandResult(false, "", "Lifecycle rule not found");

    ruleRepo.remove(rule);
    return CommandResult(true, rule.id.value, "");
  }
}

