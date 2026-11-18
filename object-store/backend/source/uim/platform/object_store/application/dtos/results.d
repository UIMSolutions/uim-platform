/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.object_store.application.dtos.results;

import uim.platform.object_store;

mixin(ShowModule!());

@safe:

/// The content of an object version (data plane read).
struct ObjectContent {
  StorageObject object;
  ObjectVersion version_;
  const(ubyte)[] data;
}

/// S3 style listing of a bucket: objects directly below a prefix and the
/// "folders" (common prefixes) when a delimiter is given.
struct ObjectListing {
  string bucketName;
  string prefix;
  string delimiter;
  StorageObject[] objects;
  string[] commonPrefixes;
}

/// Outcome of verifying a pair of binding credentials.
struct CredentialCheck {
  bool valid;
  string accessKeyId;
  string bindingId;
  string bindingName;
  string bucketId;
  string bucketName;
  BindingPermission permission;
  BindingStatus status;
  string reason;
}

/// Outcome of a lifecycle run.
struct LifecycleRunReport {
  TenantId tenantId;
  int bucketsEvaluated;
  int rulesEvaluated;
  int expired;
  int transitioned;
  int versionsPurged;
  int skipped; /// steps refused (suspended bucket, legal hold set meanwhile)
  string[] messages;
  long ranAt;
}

/// Stored objects and bytes of one storage class.
struct StorageClassUsage {
  StorageClass storageClass;
  int objects;
  long bytes;
}

/// Aggregated figures of a tenant (Fiori KPI header, CLI "stats", GUI overview).
struct ObjectStoreStatistics {
  TenantId tenantId;
  int buckets;
  int bucketsSuspended;
  int bucketsVersioned;
  int bucketsEncrypted; /// sseKms or sseC
  int objects; /// active + archived
  int objectsArchived;
  int objectsDeleted; /// delete marker on top
  int objectsOnLegalHold;
  int versions;
  long storedBytes; /// all versions
  long quotaBytes; /// sum of bucket quotas (0 = unlimited buckets only)
  int accessPolicies;
  int lifecycleRules;
  int lifecycleRulesEnabled;
  int corsRules;
  int bindings;
  int bindingsActive;
  int bindingsRevoked;
  int bindingsExpired;
  StorageClassUsage[] usage;
  long lastLifecycleRunAt;
}
