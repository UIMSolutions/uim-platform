/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.object_store.application.usecases.manage.bindings;

import uim.platform.object_store;

mixin(ShowModule!());

@safe:

/// Interactor: service bindings (access keys of a bucket). Secrets are
/// generated here, stored as salted hashes and handed out exactly once.
class ManageServiceBindingsUseCase
  : BucketChildUseCase!(ServiceBinding, ServiceBindingId, CreateServiceBindingRequest, UpdateServiceBindingRequest),
  IManageServiceBindingsUseCase {

  /// Plain secrets of the last create / rotate, until the adapter takes them.
  protected string[string] issued;

  this(ObjectStoreRepositories repos, EventRecorder events) {
    super(repos, repos.bindings, events, "Service binding", "objectstore.binding");
  }

  override protected ServiceBinding build(CreateServiceBindingRequest r) {
    auto b = super.build(r);
    validate(b.expiresAt == 0 || b.expiresAt > nowStdTime(), "expiresAt must be in the future");
    b.status = BindingStatus.active;
    b.accessKeyId = newAccessKeyId();
    issue(b);
    return b;
  }

  override protected void apply(ref ServiceBinding b, ServiceBindingSpec spec) {
    ensureState(b.status != BindingStatus.revoked, "Service binding '" ~ b.name ~ "' is revoked");
    validate(spec.expiresAt == b.expiresAt || spec.expiresAt == 0 || spec.expiresAt > nowStdTime(),
      "expiresAt must be in the future");
    super.apply(b, spec);
    if (b.status == BindingStatus.expired && (b.expiresAt == 0 || b.expiresAt > nowStdTime()))
      b.status = BindingStatus.active;
  }

  /// New secret for a binding (kept in `issued` until taken).
  protected void issue(ref ServiceBinding b) {
    auto secret = newSecretAccessKey();
    b.secretSalt = newSalt();
    b.secretHash = hashSecret(secret, b.secretSalt);
    b.lastRotatedAt = nowStdTime();
    issued[b.tenantId.value ~ "/" ~ b.id.value] = secret;
  }

  UsecaseResult revoke(TenantId tenantId, ServiceBindingId id, UserId actor) {
    return transition(tenantId, id, actor, "revoked", (ref b) {
      ensureState(b.status != BindingStatus.revoked, "Service binding '" ~ b.name ~ "' is already revoked");
      b.status = BindingStatus.revoked;
    });
  }

  UsecaseResult rotate(TenantId tenantId, ServiceBindingId id, UserId actor) {
    return transition(tenantId, id, actor, "rotated", (ref b) {
      ensureState(effectiveStatus(b, nowStdTime()) == BindingStatus.active,
        "Only active bindings can be rotated ('" ~ b.name ~ "' is " ~ enumText(effectiveStatus(b, nowStdTime())) ~ ")");
      issue(b);
    });
  }

  CredentialCheck verify(TenantId tenantId, string accessKeyId, string secretAccessKey) {
    CredentialCheck c;
    c.accessKeyId = accessKeyId;
    auto b = accessKeyId.length > 0 ? repos.bindings.findByAccessKey(tenantId, accessKeyId) : ServiceBinding.init;
    if (b.isNull) {
      c.reason = "Unknown access key";
      return c;
    }
    auto now = nowStdTime();
    c.bindingId = b.id.value;
    c.bindingName = b.name;
    c.bucketId = b.bucketId.value;
    c.bucketName = b.bucketName;
    c.permission = b.permission;
    c.status = effectiveStatus(b, now);
    if (c.status != BindingStatus.active) {
      c.reason = "Service binding '" ~ b.name ~ "' is " ~ enumText(c.status);
      return c;
    }
    if (!constantTimeEquals(hashSecret(secretAccessKey, b.secretSalt), b.secretHash)) {
      c.reason = "Invalid secret access key";
      return c;
    }
    c.valid = true;
    c.reason = "Valid credentials of '" ~ b.name ~ "' (" ~ enumText(b.permission) ~ " on " ~ b.bucketName ~ ")";
    // record the use (at most once a minute, to keep writes low)
    if (now - b.lastUsedAt > 60 * 10_000_000L) {
      b.lastUsedAt = now;
      repos.bindings.update(b);
    }
    return c;
  }

  string takeIssuedSecret(TenantId tenantId, ServiceBindingId id) {
    auto key = tenantId.value ~ "/" ~ id.value;
    auto secret = issued.get(key, "");
    issued.remove(key);
    return secret;
  }
}
