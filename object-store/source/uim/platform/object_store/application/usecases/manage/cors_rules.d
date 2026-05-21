/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.object_store.application.usecases.manage.cors_rules;
// import uim.platform.object_store.application.dto;
// import uim.platform.object_store.domain.entities.cors_rule;
// import uim.platform.object_store.domain.ports.repositories.cors_rule;
// import uim.platform.object_store.domain.ports.repositories.bucket;
// import uim.platform.object_store.domain.types;
import uim.platform.object_store;

mixin(ShowModule!());

@safe:
/// Application service for CORS rule management.
class ManageCorsRulesUseCase { // TODO: UIMUseCase {
  private CorsRuleRepository corsRules;
  private BucketRepository bucketRepo;

  this(CorsRuleRepository corsRules, BucketRepository bucketRepo) {
    this.corsRules = corsRules;
    this.bucketRepo = bucketRepo;
  }

  CommandResult createCorsRule(CreateCorsRuleRequest req) {
    if (req.bucketId.isEmpty)
      return CommandResult(false, "", "Bucket ID is required");

    auto bucket = bucketRepo.findById(req.tenantId, req.bucketId);
    if (bucket.isNull)
      return CommandResult(false, "", "Bucket not found");

    CorsRule rule;
    rule.initEntity(req.tenantId);

    rule.bucketId = req.bucketId;
    rule.allowedOrigins = req.allowedOrigins;
    rule.allowedMethods = req.allowedMethods;
    rule.allowedHeaders = req.allowedHeaders;
    rule.exposedHeaders = req.exposedHeaders;
    rule.maxAgeSeconds = req.maxAgeSeconds > 0 ? req.maxAgeSeconds : 3600;

    corsRules.save(rule);
    return CommandResult(true, rule.id.value, "");
  }

  CommandResult updateCorsRule(UpdateCorsRuleRequest req) {
    auto rule = corsRules.findById(req.tenantId, req.corsRuleId);
    if (rule.isNull)
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

    corsRules.update(rule);
    return CommandResult(true, rule.id.value, "");
  }

  CorsRule getCorsRule(TenantId tenantId, CorsRuleId corsRuleId) {
    return corsRules.findById(tenantId, corsRuleId);
  }

  CorsRule[] listCorsRules(TenantId tenantId, BucketId bucketId) {
    return corsRules.findByBucket(tenantId, bucketId);
  }

  CommandResult deleteCorsRule(TenantId tenantId, CorsRuleId corsRuleId) {
    auto rule = corsRules.findById(tenantId, corsRuleId);
    if (rule.isNull)
      return CommandResult(false, "", "CORS rule not found");

    corsRules.remove(rule);
    return CommandResult(true, rule.id.value, "");
  }
}
