/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.object_store.application.usecases.manage.cors_rules;

import uim.platform.object_store.application.dto;
import uim.platform.object_store.domain.entities.cors_rule;
import uim.platform.object_store.domain.ports.repositories.cors_rule;
import uim.platform.object_store.domain.ports.repositories.bucket;
import uim.platform.object_store.domain.types;

/// Application service for CORS rule management.
class ManageCorsRulesUseCase : UIMUseCase {
  private CorsRuleRepository corsRepo;
  private BucketRepository bucketRepo;

  this(CorsRuleRepository corsRepo, BucketRepository bucketRepo) {
    this.corsRepo = corsRepo;
    this.bucketRepo = bucketRepo;
  }

  CommandResult createRule(CreateCorsRuleRequest req) {
    if (req.bucketid.isEmpty)
      return CommandResult(false, "", "Bucket ID is required");

    auto bucket = bucketRepo.findById(req.bucketId);
    if (bucket is null || bucket.id.isEmpty)
      return CommandResult(false, "", "Bucket not found");

    // import std.uuid : randomUUID;

    auto id = randomUUID().toString();
    auto ts = currentTimestamp();

    auto rule = new CorsRule();
    rule.id = randomUUID();
    rule.tenantId = req.tenantId;
    rule.bucketId = req.bucketId;
    rule.allowedOrigins = req.allowedOrigins;
    rule.allowedMethods = req.allowedMethods;
    rule.allowedHeaders = req.allowedHeaders;
    rule.exposedHeaders = req.exposedHeaders;
    rule.maxAgeSeconds = req.maxAgeSeconds > 0 ? req.maxAgeSeconds : 3600;
    rule.createdAt = ts;
    rule.updatedAt = ts;

    corsRepo.save(rule);
    return CommandResult(true, id.toString, "");
  }

  CommandResult updateRule(CorsRuleId id, UpdateCorsRuleRequest req) {
    auto rule = corsRepo.findById(id);
    if (rule is null || rule.id.isEmpty)
      return CommandResult(false, "", "CORS rule not found");

    if (req.allowedOrigins.length > 0)
      rule.allowedOrigins = req.allowedOrigins;
    if (req.allowedMethods.length > 0)
      rule.allowedMethods = req.allowedMethods;
    if (req.allowedHeaders.length > 0)
      rule.allowedHeaders = req.allowedHeaders;
    if (req.exposedHeaders.length > 0)
      rule.exposedHeaders = req.exposedHeaders;
    if (req.maxAgeSeconds > 0)
      rule.maxAgeSeconds = req.maxAgeSeconds;
    rule.updatedAt = currentTimestamp();

    corsRepo.update(rule);
    return CommandResult(true, id.toString, "");
  }

  CorsRule getRule(CorsRuleId id) {
    return corsRepo.findById(id);
  }

  CorsRule[] listRules(BucketId bucketId) {
    return corsRepo.findByBucket(bucketId);
  }

  CommandResult deleteRule(CorsRuleId id) {
    auto rule = corsRepo.findById(id);
    if (rule is null || rule.id.isEmpty)
      return CommandResult(false, "", "CORS rule not found");

    corsRepo.remove(id);
    return CommandResult(true, id.toString, "");
  }
}

private long currentTimestamp() {
  // import std.datetime.systime : Clock;

  return Clock.currStdTime();
}
