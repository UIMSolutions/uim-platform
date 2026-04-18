/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.abap_environment.application.usecases.manage.service_bindings;

import uim.platform.abap_environment.application.dto;
import uim.platform.abap_environment.domain.entities.service_binding;
import uim.platform.abap_environment.domain.ports.repositories.service_bindings;
import uim.platform.abap_environment.domain.types;

// import std.conv : to;
// import std.uuid : randomUUID;

/// Application service for service binding CRUD.
class ManageServiceBindingsUseCase : UIMUseCase {
  private ServiceBindingRepository repo;

  this(ServiceBindingRepository repo) {
    this.repo = repo;
  }

  CommandResult createBinding(CreateServiceBindingRequest req) {
    if (req.name.length == 0)
      return CommandResult(false, "", "Service binding name is required");
    if (req.systemInstanceId.isEmpty)
      return CommandResult(false, "", "System instance ID is required");

    ServiceBinding binding;
    binding.id = randomUUID();
    binding.tenantId = req.tenantId;
    binding.systemInstanceId = req.systemInstanceId;
    binding.serviceDefinitionId = req.serviceDefinitionId;
    binding.name = req.name;
    binding.description = req.description;
    binding.bindingType = parseBindingType(req.bindingType);
    binding.status = BindingStatus.active;
    binding.endpoints = req.endpoints;

    // Generate service URL
    binding.serviceUrl = "/sap/opu/odata4/sap/" ~ req.name ~ "/";
    binding.metadataUrl = binding.serviceUrl ~ "$metadata";

    // import std.datetime.systime : Clock;
    binding.createdAt = Clock.currStdTime();
    binding.updatedAt = binding.createdAt;

    repo.save(binding);
    return CommandResult(true, binding.id.toString, "");
  }

  CommandResult updateBinding(string id, UpdateServiceBindingRequest req) {
    return updateBinding(ServiceBindingId(id), req);
  }

  CommandResult updateBinding(ServiceBindingId id, UpdateServiceBindingRequest req) {
    if (!repo.existsById(id))
      return CommandResult(false, "", "Service binding not found");

    auto binding = repo.findById(id);
    if (req.description.length > 0)
      binding.description = req.description;
    if (req.status.length > 0)
      binding.status = parseBindingStatus(req.status);
    if (req.endpoints.length > 0)
      binding.endpoints = req.endpoints;

    // import std.datetime.systime : Clock;
    binding.updatedAt = Clock.currStdTime();

    repo.update(binding);
    return CommandResult(true, binding.id.toString, "");
  }

  ServiceBinding getBinding(ServiceBindingId id) {
    return repo.findById(id);
  }

  ServiceBinding[] listBindings(SystemInstanceId systemId) {
    return repo.findBySystem(systemId);
  }

  CommandResult deleteBinding(ServiceBindingId id) {
    if (!repo.existsById(id))
      return CommandResult(false, "", "Service binding not found");

    repo.remove(id);
    return CommandResult(true, id.toString, "");
  }
}

private BindingType parseBindingType(string s) {
  switch (s) {
  case "odataV2":
    return BindingType.odataV2;
  case "odataV4":
    return BindingType.odataV4;
  case "soapHttp":
    return BindingType.soapHttp;
  case "restHttp":
    return BindingType.restHttp;
  case "sql":
    return BindingType.sql;
  case "inboundRfc":
    return BindingType.inboundRfc;
  default:
    return BindingType.odataV4;
  }
}

private BindingStatus parseBindingStatus(string s) {
  switch (s) {
  case "active":
    return BindingStatus.active;
  case "inactive":
    return BindingStatus.inactive;
  case "deprecated_":
    return BindingStatus.deprecated_;
  default:
    return BindingStatus.active;
  }
}
