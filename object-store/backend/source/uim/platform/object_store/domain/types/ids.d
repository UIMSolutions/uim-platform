/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Strongly typed identifiers of the object store aggregates.
/// (TenantId, UserId and ServiceBindingId come from uim-platform:service.)
module uim.platform.object_store.domain.types.ids;

import uim.platform.object_store;

mixin(ShowModule!());

@safe:

/// A bucket (container of objects, bound to one IaaS provider and region).
struct BucketId {
  mixin(IdTemplate);
}

/// An object (key) inside a bucket.
struct StorageObjectId {
  mixin(IdTemplate);
}

/// One stored version of an object (or a delete marker).
struct ObjectVersionId {
  mixin(IdTemplate);
}

/// An access policy of a bucket.
struct AccessPolicyId {
  mixin(IdTemplate);
}

/// A lifecycle rule of a bucket.
struct LifecycleRuleId {
  mixin(IdTemplate);
}

/// A CORS rule of a bucket.
struct CorsRuleId {
  mixin(IdTemplate);
}
