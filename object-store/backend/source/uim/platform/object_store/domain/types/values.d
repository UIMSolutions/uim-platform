/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Value objects embedded in the aggregates (OData complex types), reference
/// data and the results of the pure domain services.
module uim.platform.object_store.domain.types.values;

import uim.platform.object_store;

mixin(ShowModule!());

@safe:

/// A user defined metadata entry (x-meta-*) or a bucket label.
struct MetadataEntry {
  string key;
  string value;
}

/// A region of an IaaS provider (reference data, read-only OData entity set).
struct Region {
  string id; /// e.g. "eu-central-1"
  string name; /// e.g. "Europe (Frankfurt)"
  IaasProvider provider;
  string location; /// e.g. "Frankfurt, DE"
}

/// Properties of a storage class (reference data).
struct StorageClassInfo {
  string id; /// StorageClass name
  string name;
  string description;
  int minStorageDays; /// minimum billable storage duration
  int relativeCost; /// storage cost relative to standard (= 100)
  bool requiresRestore; /// content must be restored before reading
}

/// Limits of the object store (configured per deployment).
struct StorageLimits {
  /// Maximum size of one object (bytes).
  long maxObjectSize = 64L * 1024 * 1024;
  /// Maximum number of buckets per tenant.
  int maxBucketsPerTenant = 100;
  /// Maximum length of an object key (bytes, UTF-8).
  int maxKeyLength = 1024;
  /// Region used when a bucket does not name one.
  string defaultRegion = "eu-central-1";
}

/// Outcome of an access policy evaluation.
struct AccessDecision {
  bool allowed;
  PolicyEffect effect = PolicyEffect.deny;
  string principal;
  PolicyAction action;
  string key;
  string matchedPolicy; /// name of the deciding policy ("" = implicit)
  string reason;
}

/// Outcome of a CORS preflight check.
struct CorsDecision {
  bool allowed;
  string origin;
  string matchedRule; /// name of the matching rule
  string allowOrigin; /// Access-Control-Allow-Origin
  string[] allowMethods;
  string[] allowHeaders;
  string[] exposeHeaders;
  int maxAgeSeconds;
  string reason;
}

/// One planned lifecycle step.
struct LifecycleStep {
  LifecycleStepKind kind;
  StorageObjectId objectId;
  ObjectVersionId versionId; /// purgeVersion
  string key;
  StorageClass target; /// transition
  string ruleName;
}
