/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Bucket configuration aggregates: access policies, lifecycle rules, CORS rules.
module uim.platform.object_store.domain.entities.rules;

import uim.platform.object_store;

mixin(ShowModule!());

@safe:

/// An access policy statement of a bucket (data plane authorization).
///
/// Principals are user ids, "binding:<name>" for service bindings,
/// "anonymous" for unauthenticated callers, or glob patterns ("*", "team-*").
/// Resources are key patterns ("*", "images/*", "reports/????.pdf").
struct AccessPolicy {
  mixin TenantEntity!AccessPolicyId;

  BucketId bucketId;
  string bucketName;
  string name; /// unique per bucket
  string description;
  PolicyEffect effect = PolicyEffect.allow;
  string[] principals;
  PolicyAction[] actions;
  string[] resources;
  bool enabled = true;
}

/// A lifecycle rule: expire objects, move them to colder storage classes and
/// purge old versions, for all keys below a prefix.
struct LifecycleRule {
  mixin TenantEntity!LifecycleRuleId;

  BucketId bucketId;
  string bucketName;
  string name; /// unique per bucket
  string prefix; /// "" = whole bucket
  RuleStatus status = RuleStatus.enabled;
  int expirationDays; /// delete objects older than N days (0 = off)
  int transitionDays; /// move objects older than N days … (0 = off)
  StorageClass transitionStorageClass = StorageClass.coldline; /// … to this class
  int noncurrentVersionExpirationDays; /// purge noncurrent versions older than N days (0 = off)

  // Outcome of the last run
  long lastAppliedAt;
  int lastExpired;
  int lastTransitioned;
  int lastVersionsPurged;
}

/// A CORS rule of a bucket: which browser origins may call the content API.
struct CorsRule {
  mixin TenantEntity!CorsRuleId;

  BucketId bucketId;
  string bucketName;
  string name; /// unique per bucket
  string[] allowedOrigins; /// "https://app.example.com", "https://*.example.com", "*"
  CorsMethod[] allowedMethods;
  string[] allowedHeaders; /// "*" = any
  string[] exposedHeaders; /// e.g. "ETag"
  int maxAgeSeconds = 3600;
}
