/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.credential_store.application.usecases.manage.service_bindings;
// import uim.platform.credential_store.domain.ports.repositories.service_bindings;
// import uim.platform.credential_store.domain.entities.service_binding;

// import uim.platform.credential_store.application.dto;


import uim.platform.credential_store;

// mixin(ShowModule!());

@safe:
class ManageServiceBindingsUseCase { // TODO: UIMUseCase {
  private ServiceBindingRepository bindings;

  this(ServiceBindingRepository bindings) {
    this.bindings = bindings;
  }

  ServiceBindingResponse createServiceBinding(CreateServiceBindingRequest r) {
    ServiceBinding binding;
    binding.initEntity(r.tenantId);

    binding.name = r.name;
    binding.description = r.description;
    binding.clientId = randomUUID().toString;
    binding.clientSecret = randomUUID().to!string ~ randomUUID().to!string;
    binding.permission = r.permission.to!PermissionLevel;
    binding.status = BindingStatus.active;
    binding.allowedNamespaces = r.allowedNamespaces;
    binding.expiresAt = r.expiresAt;
    binding.createdBy = r.createdBy;

    bindings.save(binding);

    ServiceBindingResponse resp;
    resp.serviceBindingId = binding.id;
    resp.name = binding.name;
    resp.clientId = binding.clientId;
    resp.clientSecret = binding.clientSecret; // only returned on creation
    resp.permission = binding.permission.to!string;
    resp.status = "active";
    resp.allowedNamespaces = binding.allowedNamespaces;
    resp.createdAt = binding.createdAt;
    resp.expiresAt = binding.expiresAt;
    return resp;
  }

  CommandResult updateServiceBinding(UpdateServiceBindingRequest r) {
    auto binding = bindings.find(r.tenantId, r.serviceBindingId);
    if (binding.isNull)
      return CommandResult(false, "", "Service binding not found");

    if (r.description.length > 0)
      binding.description = r.description;
    if (r.permission.length > 0)
      binding.permission = r.permission.to!PermissionLevel;
    if (r.status == "revoked")
      binding.status = BindingStatus.revoked;
    if (r.allowedNamespaces.length > 0)
      binding.allowedNamespaces = r.allowedNamespaces;

    bindings.update(binding);
    return CommandResult(true, binding.id.value, "");
  }

  ServiceBinding getServiceBinding(TenantId tenantId, ServiceBindingId serviceBindingId) {
    return bindings.findById(tenantId, serviceBindingId);
  }

  ServiceBinding[] listServiceBindings(TenantId tenantId) {
    return bindings.findByTenant(tenantId);
  }

  CommandResult deleteServiceBinding(TenantId tenantId, ServiceBindingId serviceBindingId) {
    auto binding = bindings.findById(tenantId, serviceBindingId);
    if (binding.isNull)
      return CommandResult(false, "", "Service binding not found");

    bindings.remove(binding);
    return CommandResult(true, binding.id.value, "");
  }

  size_t countServiceBindings(TenantId tenantId) {
    return bindings.countByTenant(tenantId);
  }

}
