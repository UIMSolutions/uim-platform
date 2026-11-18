/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.object_store.domain.entities.service_binding;

import uim.platform.object_store;

mixin(ShowModule!());

@safe:

/// A service binding: an access key pair for programmatic access to one
/// bucket through the content API. Only a salted SHA-256 hash of the secret
/// is stored; the secret itself is shown once (on create and rotate).
struct ServiceBinding {
  mixin TenantEntity!ServiceBindingId;

  BucketId bucketId;
  string bucketName;
  string name; /// unique per bucket
  string description;
  BindingPermission permission = BindingPermission.readOnly;
  BindingStatus status = BindingStatus.active;
  long expiresAt; /// 0 = never

  // Credentials (generated)
  string accessKeyId; /// public part, e.g. "OSAK2F7Q…"
  string secretHash; /// SHA-256(salt ~ secret), hex
  string secretSalt;
  long lastRotatedAt;
  long lastUsedAt;
}

/// The status of a binding at `now` (an active binding past expiresAt is expired).
BindingStatus effectiveStatus(const ServiceBinding b, long now) pure nothrow {
  if (b.status == BindingStatus.active && b.expiresAt > 0 && b.expiresAt <= now)
    return BindingStatus.expired;
  return b.status;
}
