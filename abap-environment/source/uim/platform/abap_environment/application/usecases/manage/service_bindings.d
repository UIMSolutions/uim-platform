/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.abap_environment.application.usecases.manage.service_bindings;
// import uim.platform.abap_environment.application.dto;
// import uim.platform.abap_environment.domain.entities.service_binding;
// import uim.platform.abap_environment.domain.ports.repositories.service_bindings;
// import uim.platform.abap_environment.domain.types;
// import std.uuid : randomUUID;
import uim.platform.abap_environment;

mixin(ShowModule!());

@safe:
/// Application service for service binding CRUD.
class ManageServiceBindingsUseCase { // TODO: UIMUseCase {
  private ServiceBindingRepository repo;

  this(ServiceBindingRepository repo) {
    this.repo = repo;
  }

  CommandResult createServiceBinding(CreateServiceBindingRequest req) {
    if (req.name.length == 0)
      return CommandResult(false, "", "Service binding name is required");
    if (req.systemInstanceId.isEmpty)
      return CommandResult(false, "", "System instance ID is required");

    ServiceBinding binding;
    binding.initEntity(req.tenantId);
    binding.systemInstanceId = req.systemInstanceId;
    binding.serviceDefinitionId = req.serviceDefinitionId;
    binding.name = req.name;
    binding.description = req.description;
    binding.bindingType =req.bindingType.to!BindingType;
    binding.status = BindingStatus.active;
    binding.endpoints = req.endpoints;

    // Generate service URL
    binding.serviceUrl = "/sap/opu/odata4/sap/" ~ req.name ~ "/";
    binding.metadataUrl = binding.serviceUrl ~ "$metadata";

    repo.save(binding);
    return CommandResult(true, binding.id.value, "");
  }

  CommandResult updateServiceBinding(UpdateServiceBindingRequest req) {
    auto binding = repo.findById(req.tenantId, req.id);
    if (binding.isNull)
      return CommandResult(false, "", "Service binding not found");

    if (req.description.length > 0)
      binding.description = req.description;
    if (req.status.length > 0)
      binding.status = req.status.to!BindingStatus;
    if (req.endpoints.length > 0)
      binding.endpoints = req.endpoints;

    binding.updatedAt = Clock.currStdTime();

    repo.update(binding);
    return CommandResult(true, binding.id.value, "");
  }

  ServiceBinding getServiceBinding(TenantId tenantId, ServiceBindingId id) {
    return repo.findById(tenantId, id);
  }

  ServiceBinding[] listServiceBindings(TenantId tenantId, SystemInstanceId systemId) {
    return repo.findBySystem(tenantId, systemId);
  }

  CommandResult deleteServiceBinding(TenantId tenantId, ServiceBindingId id) {
    auto binding = repo.findById(tenantId, id);
    if (binding.isNull)
      return CommandResult(false, "", "Service binding not found");

    repo.remove(binding);
    return CommandResult(true, binding.id.value, "");
  }
}


