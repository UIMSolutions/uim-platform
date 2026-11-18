/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.object_store.application.services.statistics;

import uim.platform.object_store;

mixin(ShowModule!());

@safe:

/// Aggregates the figures of a tenant from the repositories.
class ObjectStoreStatisticsService : IObjectStoreStatisticsService {
  protected ObjectStoreRepositories repos;

  this(ObjectStoreRepositories repos) {
    this.repos = repos;
  }

  ObjectStoreStatistics statistics(TenantId tenantId) {
    ObjectStoreStatistics s;
    s.tenantId = tenantId;
    auto now = nowStdTime();

    foreach (b; repos.buckets.findByTenant(tenantId)) {
      s.buckets++;
      if (b.status == BucketStatus.suspended)
        s.bucketsSuspended++;
      if (b.versioningEnabled)
        s.bucketsVersioned++;
      if (b.encryptionType == EncryptionType.sseKms || b.encryptionType == EncryptionType.sseC)
        s.bucketsEncrypted++;
      s.storedBytes += b.usedBytes;
      s.quotaBytes += b.quotaBytes;
    }

    StorageClassUsage[StorageClass] usage;
    foreach (c; [EnumMembers!StorageClass])
      usage[c] = StorageClassUsage(c);
    foreach (o; repos.objects.findByTenant(tenantId)) {
      final switch (o.status) {
      case ObjectStatus.active:
        s.objects++;
        break;
      case ObjectStatus.archived:
        s.objects++;
        s.objectsArchived++;
        break;
      case ObjectStatus.deleted:
        s.objectsDeleted++;
        break;
      }
      if (o.legalHold)
        s.objectsOnLegalHold++;
      if (o.status != ObjectStatus.deleted) {
        usage[o.storageClass].objects++;
        usage[o.storageClass].bytes += o.size;
      }
    }
    foreach (c; [EnumMembers!StorageClass])
      s.usage ~= usage[c];

    foreach (v; repos.versions.findByTenant(tenantId))
      if (!v.isDeleteMarker)
        s.versions++;

    s.accessPolicies = cast(int) repos.policies.findByTenant(tenantId).length;
    foreach (r; repos.lifecycleRules.findByTenant(tenantId)) {
      s.lifecycleRules++;
      if (r.status == RuleStatus.enabled)
        s.lifecycleRulesEnabled++;
      s.lastLifecycleRunAt = max(s.lastLifecycleRunAt, r.lastAppliedAt);
    }
    s.corsRules = cast(int) repos.corsRules.findByTenant(tenantId).length;
    foreach (b; repos.bindings.findByTenant(tenantId)) {
      s.bindings++;
      final switch (effectiveStatus(b, now)) {
      case BindingStatus.active:
        s.bindingsActive++;
        break;
      case BindingStatus.revoked:
        s.bindingsRevoked++;
        break;
      case BindingStatus.expired:
        s.bindingsExpired++;
        break;
      }
    }
    return s;
  }
}
