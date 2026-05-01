/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.object_store.application.usecases.manage.lifecycle_rules;

import uim.platform.object_store.application.dto;
import uim.platform.object_store.domain.entities.lifecycle_rule;
import uim.platform.object_store.domain.ports.repositories.lifecycle_rule;
import uim.platform.object_store.domain.ports.repositories.bucket;
import uim.platform.object_store.domain.types;

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

    auto bucket = bucketRepo.findById(req.bucketId);
    if (bucket.isNull || bucket.isNull)
      return CommandResult(false, "", "Bucket not found");

    // import std.uuid : randomUUID;
    
    LifecycleRule rule;
    rule.id = randomUUID();
    rule.tenantId = req.tenantId;
    rule.bucketId = req.bucketId;
    rule.name = req.name;
    rule.prefix = req.prefix;
    rule.status = parseRuleStatus(req.status);
    rule.expirationDays = req.expirationDays;
    rule.transitionDays = req.transitionDays;
    rule.transitionStorageClass = parseStorageClass(req.transitionStorageClass);
    rule.abortIncompleteUploadDays = req.abortIncompleteUploadDays;
    rule.createdBy = req.createdBy;
    rule.createdAt = currentTimestamp();
    rule.updatedAt = rule.createdAt;

    ruleRepo.save(rule);
    return CommandResult(true, rule.id.toString, "");
  }

  CommandResult updateRule(LifecycleRuleId id, UpdateLifecycleRuleRequest req) {
    auto rule = ruleRepo.findById(id);
    if (rule.isNull || rule.isNull)
      return CommandResult(false, "", "Rule not found");

    if (req.name.length > 0)
      rule.name = req.name;
    if (req.prefix.length > 0)
      rule.prefix = req.prefix;
    if (req.status.length > 0)
      rule.status = parseRuleStatus(req.status);
    if (req.expirationDays > 0)
      rule.expirationDays = req.expirationDays;
    if (req.transitionDays > 0)
      rule.transitionDays = req.transitionDays;
    if (req.transitionStorageClass.length > 0)
      rule.transitionStorageClass = parseStorageClass(req.transitionStorageClass);
    if (req.abortIncompleteUploadDays > 0)
      rule.abortIncompleteUploadDays = req.abortIncompleteUploadDays;
    rule.updatedAt = currentTimestamp();

    ruleRepo.update(rule);
    return CommandResult(true, id.toString, "");
  }

  LifecycleRule getRule(LifecycleRuleId id) {
    return ruleRepo.findById(id);
  }

  LifecycleRule[] listRules(BucketId bucketId) {
    return ruleRepo.findByBucket(bucketId);
  }

  CommandResult deleteRule(LifecycleRuleId id) {
    auto rule = ruleRepo.findById(id);
    if (rule.isNull || rule.isNull)
      return CommandResult(false, "", "Rule not found");

    ruleRepo.removeById(id);
    return CommandResult(true, id.toString, "");
  }
}

private RuleStatus parseRuleStatus(string s) {
  switch (s) {
  case "disabled":
    return RuleStatus.disabled;
  default:
    return RuleStatus.enabled;
  }
}

private StorageClass parseStorageClass(string s) {
  switch (s) {
  case "nearline":
    return StorageClass.nearline;
  case "coldline":
    return StorageClass.coldline;
  case "archive":
    return StorageClass.archive;
  default:
    return StorageClass.nearline;
  }
}

private long currentTimestamp() {
  // import std.datetime.systime : Clock;

  return Clock.currStdTime();
}
