/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.object_store.application.usecases.manage.service_bindings;

import uim.platform.object_store.application.dto;
import uim.platform.object_store.domain.entities.service_binding;
import uim.platform.object_store.domain.ports.repositories.service_binding;
import uim.platform.object_store.domain.ports.repositories.bucket;
import uim.platform.object_store.domain.types;

// import std.conv : to;

/// Application service for service binding management (credentials for programmatic access).
class ManageServiceBindingsUseCase : UIMUseCase {
  private ServiceBindingRepository bindingRepo;
  private BucketRepository bucketRepo;

  this(ServiceBindingRepository bindingRepo, BucketRepository bucketRepo) {
    this.bindingRepo = bindingRepo;
    this.bucketRepo = bucketRepo;
  }

  CommandResult createBinding(CreateServiceBindingRequest req) {
    if (req.name.length == 0)
      return CommandResult(false, "", "Binding name is required");
    if (req.bucketid.isEmpty)
      return CommandResult(false, "", "Bucket ID is required");

    auto bucket = bucketRepo.findById(req.bucketId);
    if (bucket is null || bucket.id.isEmpty)
      return CommandResult(false, "", "Bucket not found");

    // import std.uuid : randomUUID;

    auto id = randomUUID().toString();
    auto accessKeyId = randomUUID().toString();
    auto secretKey = randomUUID().toString();
    auto ts = currentTimestamp();

    auto binding = new ServiceBinding();
    binding.id = randomUUID();
    binding.tenantId = req.tenantId;
    binding.name = req.name;
    binding.bucketId = req.bucketId;
    binding.accessKeyId = accessKeyId;
    binding.secretAccessKeyHash = hashSecret(secretKey);
    binding.permission = parsePermission(req.permission);
    binding.status = BindingStatus.active;
    binding.expiresAt = req.expiresAt;
    binding.createdBy = req.createdBy;
    binding.createdAt = ts;

    bindingRepo.save(binding);
    return CommandResult(true, id.toString, "");
  }

  ServiceBinding getBinding(ServiceBindingId id) {
    return bindingRepo.findById(id);
  }

  ServiceBinding[] listBindings(BucketId bucketId) {
    return bindingRepo.findByBucket(bucketId);
  }

  CommandResult revokeBinding(ServiceBindingId id) {
    auto binding = bindingRepo.findById(id);
    if (binding is null || binding.id.isEmpty)
      return CommandResult(false, "", "Binding not found");

    binding.status = BindingStatus.revoked;
    bindingRepo.update(binding);
    return CommandResult(true, id.toString, "");
  }

  CommandResult deleteBinding(ServiceBindingId id) {
    auto binding = bindingRepo.findById(id);
    if (binding is null || binding.id.isEmpty)
      return CommandResult(false, "", "Binding not found");

    bindingRepo.remove(id);
    return CommandResult(true, id.toString, "");
  }
}

private BindingPermission parsePermission(string s) {
  switch (s) {
  case "readWrite":
    return BindingPermission.readWrite;
  case "admin":
    return BindingPermission.admin;
  default:
    return BindingPermission.readOnly;
  }
}

private string hashSecret(string secret) {
  // import std.digest.md : md5Of, toHexString;
  // import std.string : representation;

  auto hash = md5Of(secret.representation);
  return toHexString(hash).idup;
}

private long currentTimestamp() {
  // import std.datetime.systime : Clock;

  return Clock.currStdTime();
}
