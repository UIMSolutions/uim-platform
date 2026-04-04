/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.credential_store.application.use_cases.manage_service_bindings;

import uim.platform.credential_store.domain.ports.service_binding_repository;
import uim.platform.credential_store.domain.entities.service_binding;
import uim.platform.credential_store.domain.types;
import uim.platform.credential_store.application.dto;

import std.uuid : randomUUID;
import std.conv : to;

class ManageServiceBindingsUseCase : UIMUseCase {
  private ServiceBindingRepository repo;

  this(ServiceBindingRepository repo) {
    this.repo = repo;
  }

  ServiceBindingResponse create(CreateServiceBindingRequest r) {
    ServiceBinding binding;
    binding.id = randomUUID().to!string;
    binding.tenantId = r.tenantId;
    binding.name = r.name;
    binding.description = r.description;
    binding.clientId = randomUUID().to!string;
    binding.clientSecret = randomUUID().to!string ~ randomUUID().to!string;
    binding.permission = parsePermission(r.permission);
    binding.status = BindingStatus.active;
    binding.allowedNamespaces = r.allowedNamespaces;
    binding.createdAt = currentTimestamp();
    binding.expiresAt = r.expiresAt;
    binding.createdBy = r.createdBy;

    repo.save(binding);

    ServiceBindingResponse resp;
    resp.id = binding.id;
    resp.name = binding.name;
    resp.clientId = binding.clientId;
    resp.clientSecret = binding.clientSecret; // only returned on creation
    resp.permission = r.permission;
    resp.status = "active";
    resp.allowedNamespaces = binding.allowedNamespaces;
    resp.createdAt = binding.createdAt;
    resp.expiresAt = binding.expiresAt;
    return resp;
  }

  CommandResult update(ServiceBindingId id, UpdateServiceBindingRequest r) {
    auto binding = repo.findById(id);
    if (binding.id.length == 0)
      return CommandResult(false, "", "Service binding not found");

    if (r.description.length > 0)
      binding.description = r.description;
    if (r.permission.length > 0)
      binding.permission = parsePermission(r.permission);
    if (r.status == "revoked")
      binding.status = BindingStatus.revoked;
    if (r.allowedNamespaces.length > 0)
      binding.allowedNamespaces = r.allowedNamespaces;

    repo.update(binding);
    return CommandResult(true, binding.id, "");
  }

  ServiceBinding get_(ServiceBindingId id) {
    return repo.findById(id);
  }

  ServiceBinding[] list(TenantId tenantId) {
    return repo.findByTenant(tenantId);
  }

  void remove(ServiceBindingId id) {
    repo.remove(id);
  }

  long count(TenantId tenantId) {
    return repo.countByTenant(tenantId);
  }

  private static PermissionLevel parsePermission(string p) {
    switch (p) {
    case "readOnly":
      return PermissionLevel.readOnly;
    case "admin":
      return PermissionLevel.admin;
    default:
      return PermissionLevel.readWrite;
    }
  }

  private static long currentTimestamp() {
    import std.datetime.systime : Clock;

    return Clock.currStdTime();
  }
}
