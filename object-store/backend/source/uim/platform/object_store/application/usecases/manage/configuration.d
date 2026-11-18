/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Interactors of the bucket configuration: access policies, lifecycle rules, CORS rules.
module uim.platform.object_store.application.usecases.manage.configuration;

import uim.platform.object_store;

mixin(ShowModule!());

@safe:

/// Access policies (data plane authorization of a bucket).
class ManageAccessPoliciesUseCase
  : BucketChildUseCase!(AccessPolicy, AccessPolicyId, CreateAccessPolicyRequest, UpdateAccessPolicyRequest),
  IManageAccessPoliciesUseCase {

  this(ObjectStoreRepositories repos, EventRecorder events) {
    super(repos, repos.policies, events, "Access policy", "objectstore.policy");
  }

  override protected void check(ref AccessPolicy p, const Bucket bucket) {
    p.principals = p.principals.map!(x => x.strip).filter!(x => x.length > 0).array;
    p.resources = p.resources.map!(x => x.strip).filter!(x => x.length > 0).array;
    validate(p.principals.length > 0, "Access policy '" ~ p.name ~ "' needs at least one principal");
    validate(p.actions.length > 0, "Access policy '" ~ p.name ~ "' needs at least one action");
    if (p.resources.length == 0)
      p.resources = ["*"];
  }

  AccessDecision evaluate(EvaluateAccessRequest r) {
    auto bucket = requireBucket(r.tenantId, r.bucketId);
    auto principal = r.principal.strip.length > 0 ? r.principal.strip : anonymousPrincipal;
    return evaluateAccess(children.findByBucket(r.tenantId, bucket.id), principal, r.action, r.key,
      bucket.publicAccessBlocked);
  }
}

/// Lifecycle rules and their execution.
class ManageLifecycleRulesUseCase
  : BucketChildUseCase!(LifecycleRule, LifecycleRuleId, CreateLifecycleRuleRequest, UpdateLifecycleRuleRequest),
  IManageLifecycleRulesUseCase {

  protected ObjectStorageService storage;

  this(ObjectStoreRepositories repos, EventRecorder events, ObjectStorageService storage) {
    super(repos, repos.lifecycleRules, events, "Lifecycle rule", "objectstore.lifecycle");
    this.storage = storage;
  }

  override protected void check(ref LifecycleRule r, const Bucket bucket) {
    r.prefix = r.prefix.strip;
    validateLifecycleRule(r);
  }

  LifecycleRunReport run(TenantId tenantId, BucketId bucketId, long now, UserId actor) {
    LifecycleRunReport report;
    report.tenantId = tenantId;
    report.ranAt = now;
    auto buckets = bucketId.isEmpty ? repos.buckets.findByTenant(tenantId) : [requireBucket(tenantId, bucketId)];

    foreach (bucket; buckets) {
      auto rules = children.findByBucket(tenantId, bucket.id).filter!(r => r.status == RuleStatus.enabled).array;
      if (rules.length == 0)
        continue;
      report.bucketsEvaluated++;
      report.rulesEvaluated += cast(int) rules.length;
      if (bucket.status != BucketStatus.active) {
        report.messages ~= bucket.name ~ ": skipped (bucket is suspended)";
        continue;
      }

      auto steps = planLifecycle(rules, repos.objects.findByBucket(tenantId, bucket.id),
        repos.versions.findByBucket(tenantId, bucket.id), now);
      int[string] expired, transitioned, purged;
      foreach (step; steps) {
        try {
          final switch (step.kind) {
          case LifecycleStepKind.expire:
            auto obj = repos.objects.findById(tenantId, step.objectId);
            if (obj.isNull)
              continue;
            storage.deleteObject(obj, actor);
            report.expired++;
            expired[step.ruleName]++;
            report.messages ~= "%s: expired '%s' (%s)".format(bucket.name, step.key, step.ruleName);
            break;
          case LifecycleStepKind.transition:
            auto obj = repos.objects.findById(tenantId, step.objectId);
            if (obj.isNull)
              continue;
            obj.storageClass = step.target;
            if (step.target == StorageClass.archive)
              obj.status = ObjectStatus.archived;
            obj.update(actor);
            repos.objects.update(obj);
            report.transitioned++;
            transitioned[step.ruleName]++;
            report.messages ~= "%s: moved '%s' to %s (%s)".format(bucket.name, step.key, enumText(step.target),
              step.ruleName);
            break;
          case LifecycleStepKind.purgeVersion:
            auto v = repos.versions.findById(tenantId, step.versionId);
            if (v.isNull || v.isLatest)
              continue;
            storage.purgeVersion(v, actor);
            report.versionsPurged++;
            purged[step.ruleName]++;
            report.messages ~= "%s: purged version %d of '%s' (%s)".format(bucket.name, v.versionNumber, step.key,
              step.ruleName);
            break;
          }
        } catch (ObjectStoreException e) {
          report.skipped++;
          report.messages ~= "%s: skipped '%s': %s".format(bucket.name, step.key, e.msg);
        }
      }

      foreach (rule; rules) {
        rule.lastAppliedAt = now;
        rule.lastExpired = expired.get(rule.name, 0);
        rule.lastTransitioned = transitioned.get(rule.name, 0);
        rule.lastVersionsPurged = purged.get(rule.name, 0);
        repos.lifecycleRules.update(rule);
      }
    }
    if (report.expired + report.transitioned + report.versionsPurged > 0)
      events.publish("objectstore.lifecycle.applied", encode(report, true));
    return report;
  }

  UsecaseResult apply(TenantId tenantId, LifecycleRuleId id, UserId actor) {
    return guarded(() {
      auto rule = require(tenantId, id);
      auto r = run(tenantId, rule.bucketId, nowStdTime(), actor);
      return succeeded(rule.id.value, "Lifecycle of '%s': %d expired, %d transitioned, %d version(s) purged".format(
        rule.bucketName, r.expired, r.transitioned, r.versionsPurged));
    });
  }
}

/// CORS rules.
class ManageCorsRulesUseCase
  : BucketChildUseCase!(CorsRule, CorsRuleId, CreateCorsRuleRequest, UpdateCorsRuleRequest),
  IManageCorsRulesUseCase {

  this(ObjectStoreRepositories repos, EventRecorder events) {
    super(repos, repos.corsRules, events, "CORS rule", "objectstore.cors");
  }

  override protected void check(ref CorsRule r, const Bucket bucket) {
    validateCorsRule(r);
  }

  CorsDecision check(CheckCorsRequest r) {
    auto bucket = requireBucket(r.tenantId, r.bucketId);
    return matchCors(children.findByBucket(r.tenantId, bucket.id), r.origin, r.method, r.requestHeaders);
  }
}
