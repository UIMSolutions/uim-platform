/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Docker registry secrets (tenant wide) and object store secrets (per
/// resource group). Secret material is reduced to a fingerprint.
module uim.platform.ai_core.application.usecases.manage.secrets;

import uim.platform.ai_core;

mixin(ShowModule!());

@safe:

class ManageSecretsUseCase : AiCoreInteractor, IManageSecrets {
  this(AiCoreRepositories repos, IClock clock, IAiCoreEventPublisher events, LifecyclePolicy policy) {
    super(repos, clock, events, policy);
  }

  // ── docker registry ───────────────────────────────────────────────────────
  DockerRegistrySecret createDockerRegistrySecret(CreateDockerRegistrySecretRequest r) {
    auto id = r.id.strip;
    requireResourceId(id, "secret name");
    if (repos.dockerSecrets.existsById(r.tenantId, DockerRegistrySecretId(id)))
      throw AiCoreException.conflict("Docker registry secret '" ~ id ~ "' already exists");
    DockerRegistrySecret s;
    stampCreated!(DockerRegistrySecret, DockerRegistrySecretId)(s, r.tenantId, r.actor, id, now);
    s.server = r.server.strip;
    s.username = r.username.strip;
    requireText(r.password, "Registry password");
    s.credentialFingerprint = fingerprintOf(s.server ~ "\n" ~ s.username ~ "\n" ~ r.password);
    s.validate();
    repos.dockerSecrets.save(s);
    emit("secret.created", r.tenantId, id, Json(["kind": Json("dockerRegistry")]));
    return s;
  }

  DockerRegistrySecret updateDockerRegistrySecret(UpdateDockerRegistrySecretRequest r) {
    auto s = getDockerRegistrySecret(r.tenantId, DockerRegistrySecretId(r.id));
    r.server.applyTo(s.server);
    r.username.applyTo(s.username);
    if (r.password.isSet) {
      requireText(r.password.value, "Registry password");
      s.credentialFingerprint = fingerprintOf(s.server ~ "\n" ~ s.username ~ "\n" ~ r.password.value);
    }
    s.validate();
    stampUpdated(s, r.actor, now);
    repos.dockerSecrets.save(s);
    return s;
  }

  DockerRegistrySecret getDockerRegistrySecret(TenantId t, DockerRegistrySecretId id) {
    return required(repos.dockerSecrets.findById(t, id), "Docker registry secret '" ~ id.value ~ "'");
  }

  DockerRegistrySecret[] listDockerRegistrySecrets(TenantId t) {
    return repos.dockerSecrets.findAll(t);
  }

  void deleteDockerRegistrySecret(TenantId t, DockerRegistrySecretId id) {
    getDockerRegistrySecret(t, id);
    repos.dockerSecrets.removeById(t, id);
    emit("secret.deleted", t, id.value, Json(["kind": Json("dockerRegistry")]));
  }

  // ── object store ──────────────────────────────────────────────────────────
  ObjectStoreSecret createObjectStoreSecret(CreateObjectStoreSecretRequest r) {
    groupOf(r.tenantId, r.resourceGroupId);
    auto id = r.id.strip;
    requireResourceId(id, "secret name");
    if (repos.objectStoreSecrets.existsById(r.tenantId, r.resourceGroupId, ObjectStoreSecretId(id)))
      throw AiCoreException.conflict("Object store secret '" ~ id ~ "' already exists");
    ObjectStoreSecret s;
    stampCreated!(ObjectStoreSecret, ObjectStoreSecretId)(s, r.tenantId, r.actor, id, now);
    s.resourceGroupId = r.resourceGroupId;
    s.type = parseDomainEnumOr!ObjectStoreType(r.type, ObjectStoreType.s3, "object store type");
    s.bucket = r.bucket.strip;
    s.endpoint = r.endpoint.strip;
    s.region = r.region.strip;
    s.pathPrefix = r.pathPrefix.strip;
    s.credentialFingerprint = r.secretAccessKey.length > 0 ? fingerprintOf(r.accessKeyId ~ "\n" ~ r.secretAccessKey) : "";
    s.validate();
    repos.objectStoreSecrets.save(s);
    emit("secret.created", r.tenantId, resourceKey(r.resourceGroupId.value, id), Json(["kind": Json("objectStore")]));
    return s;
  }

  ObjectStoreSecret updateObjectStoreSecret(UpdateObjectStoreSecretRequest r) {
    auto s = getObjectStoreSecret(r.tenantId, r.resourceGroupId, ObjectStoreSecretId(r.id));
    r.bucket.applyTo(s.bucket);
    r.endpoint.applyTo(s.endpoint);
    r.region.applyTo(s.region);
    r.pathPrefix.applyTo(s.pathPrefix);
    if (r.secretAccessKey.isSet)
      s.credentialFingerprint = r.secretAccessKey.value.length > 0
        ? fingerprintOf(r.accessKeyId.value ~ "\n" ~ r.secretAccessKey.value) : "";
    s.validate();
    stampUpdated(s, r.actor, now);
    repos.objectStoreSecrets.save(s);
    return s;
  }

  ObjectStoreSecret getObjectStoreSecret(TenantId t, ResourceGroupId rg, ObjectStoreSecretId id) {
    return required(repos.objectStoreSecrets.findById(t, rg, id), "Object store secret '" ~ id.value ~ "'");
  }

  ObjectStoreSecret[] listObjectStoreSecrets(TenantId t, ResourceGroupId rg) {
    return repos.objectStoreSecrets.findByGroup(t, rg);
  }

  void deleteObjectStoreSecret(TenantId t, ResourceGroupId rg, ObjectStoreSecretId id) {
    getObjectStoreSecret(t, rg, id);
    repos.objectStoreSecrets.removeById(t, rg, id);
    emit("secret.deleted", t, resourceKey(rg.value, id.value), Json(["kind": Json("objectStore")]));
  }
}
