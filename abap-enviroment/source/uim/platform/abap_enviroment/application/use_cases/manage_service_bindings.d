module uim.platform.abap_enviroment.application.use_cases.manage_service_bindings;

import uim.platform.abap_enviroment.application.dto;
import uim.platform.abap_enviroment.domain.entities.service_binding;
import uim.platform.abap_enviroment.domain.ports.service_binding_repository;
import uim.platform.abap_enviroment.domain.types;

import std.conv : to;
import std.uuid : randomUUID;

/// Application service for service binding CRUD.
class ManageServiceBindingsUseCase
{
    private ServiceBindingRepository repo;

    this(ServiceBindingRepository repo)
    {
        this.repo = repo;
    }

    CommandResult createBinding(CreateServiceBindingRequest req)
    {
        if (req.name.length == 0)
            return CommandResult("", "Service binding name is required");
        if (req.systemInstanceId.length == 0)
            return CommandResult("", "System instance ID is required");

        auto id = randomUUID().toString();
        ServiceBinding binding;
        binding.id = id;
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

        import std.datetime.systime : Clock;
        binding.createdAt = Clock.currStdTime();
        binding.updatedAt = binding.createdAt;

        repo.save(binding);
        return CommandResult(id, "");
    }

    CommandResult updateBinding(ServiceBindingId id, UpdateServiceBindingRequest req)
    {
        auto binding = repo.findById(id);
        if (binding is null)
            return CommandResult("", "Service binding not found");

        if (req.description.length > 0) binding.description = req.description;
        if (req.status.length > 0) binding.status = parseBindingStatus(req.status);
        if (req.endpoints.length > 0) binding.endpoints = req.endpoints;

        import std.datetime.systime : Clock;
        binding.updatedAt = Clock.currStdTime();

        repo.update(*binding);
        return CommandResult(id, "");
    }

    ServiceBinding* getBinding(ServiceBindingId id)
    {
        return repo.findById(id);
    }

    ServiceBinding[] listBindings(SystemInstanceId systemId)
    {
        return repo.findBySystem(systemId);
    }

    CommandResult deleteBinding(ServiceBindingId id)
    {
        auto binding = repo.findById(id);
        if (binding is null)
            return CommandResult("", "Service binding not found");

        repo.remove(id);
        return CommandResult(id, "");
    }
}

private BindingType parseBindingType(string s)
{
    switch (s)
    {
    case "odataV2": return BindingType.odataV2;
    case "odataV4": return BindingType.odataV4;
    case "soapHttp": return BindingType.soapHttp;
    case "restHttp": return BindingType.restHttp;
    case "sql": return BindingType.sql;
    case "inboundRfc": return BindingType.inboundRfc;
    default: return BindingType.odataV4;
    }
}

private BindingStatus parseBindingStatus(string s)
{
    switch (s)
    {
    case "active": return BindingStatus.active;
    case "inactive": return BindingStatus.inactive;
    case "deprecated_": return BindingStatus.deprecated_;
    default: return BindingStatus.active;
    }
}
