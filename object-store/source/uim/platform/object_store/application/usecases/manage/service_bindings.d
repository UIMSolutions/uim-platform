/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.object_store.application.usecases.manage.service_bindings;
// import uim.platform.object_store.application.dto;
// import uim.platform.object_store.domain.entities.service_binding;
// import uim.platform.object_store.domain.ports.repositories.service_binding;
// import uim.platform.object_store.domain.ports.repositories.bucket;
// import uim.platform.object_store.domain.types;

import uim.platform.object_store;

// mixin(ShowModule!());

@safe:
/// Application service for service binding management (credentials for programmatic access).
class ManageServiceBindingsUseCase { // TODO: UIMUseCase {
  private ServiceBindingRepository bindingRepo;
  private BucketRepository bucketRepo;

  this(ServiceBindingRepository bindingRepo, BucketRepository bucketRepo) {
    this.bindingRepo = bindingRepo;
    this.bucketRepo = bucketRepo;
  }

  CommandResult createBinding(CreateServiceBindingRequest req) {
    if (req.name.length == 0)
      return CommandResult(false, "", "Binding name is required");
    if (req.bucketId.isEmpty)
      return CommandResult(false, "", "Bucket ID is required");

    auto bucket = bucketRepo.findById(req.tenantId, req.bucketId);
    if (bucket.isNull)
      return CommandResult(false, "", "Bucket not found");

    auto accessKeyId = randomUUID().toString;
    auto secretKey = randomUUID().toString;

    ServiceBinding binding;
    binding.initEntity(req.tenantId, req.createdBy);

    binding.name = req.name;
    binding.bucketId = req.bucketId;
    binding.accessKeyId = accessKeyId;
    binding.secretAccessKeyHash = hashSecret(secretKey);
    binding.permission = req.permission.to!BindingPermission;
    binding.status = BindingStatus.active;
    binding.expiresAt = req.expiresAt;

    bindingRepo.save(binding);
    return CommandResult(true, binding.id.value, "");
  }

  ServiceBinding getBinding(TenantId tenantId, ServiceBindingId id) {
    return bindingRepo.findById(tenantId, id);
  }

  ServiceBinding[] listBindings(TenantId tenantId, BucketId bucketId) {
    return bindingRepo.findByBucket(tenantId, bucketId);
  }

  CommandResult revokeBinding(TenantId tenantId, ServiceBindingId id) {
    auto binding = bindingRepo.findById(tenantId, id);
    if (binding.isNull)
      return CommandResult(false, "", "Binding not found");

    binding.status = BindingStatus.revoked;
    bindingRepo.update(binding);
    return CommandResult(true, binding.id.value, "");
  }

  CommandResult deleteBinding(TenantId tenantId, ServiceBindingId id) {
    auto binding = bindingRepo.findById(tenantId, id);
    if (binding.isNull)
      return CommandResult(false, "", "Binding not found");

    bindingRepo.remove(binding);
    return CommandResult(true, binding.id.value, "");
  }
}

private string hashSecret(string secret) {
  import std.digest.md : md5Of, toHexString;
  import std.string : representation;

  auto hash = md5Of(secret.representation);
  return toHexString(hash).idup;
}

