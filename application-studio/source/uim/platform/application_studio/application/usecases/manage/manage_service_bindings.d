/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.application_studio.application.usecases.manage.manage_service_bindings;

import uim.platform.application_studio;

mixin(ShowModule!());

@safe:

class ManageServiceBindingsUseCase { // TODO: UIMUseCase {
    private ServiceBindingRepository repo;

    this(ServiceBindingRepository repo) {
        this.repo = repo;
    }

    ServiceBinding getById(ServiceBindingId id) {
        return repo.findById(id);
    }

    ServiceBinding[] list() {
        return repo.findAll();
    }

    ServiceBinding[] listByTenant(TenantId tenantId) {
        return repo.findByTenant(tenantId);
    }

    ServiceBinding[] listByDevSpace(DevSpaceId devSpaceId) {
        return repo.findByDevSpace(devSpaceId);
    }

    CommandResult create(ServiceBindingDTO dto) {
        ServiceBinding e;
        e.id = ServiceBindingId(dto.id);
        e.tenantId = dto.tenantId;
        e.devSpaceId = DevSpaceId(dto.devSpaceId);
        e.name = dto.name;
        e.description = dto.description;
        e.serviceUrl = dto.serviceUrl;
        e.servicePath = dto.servicePath;
        e.authType = dto.authType;
        e.credentials = dto.credentials;
        e.systemAlias = dto.systemAlias;
        e.createdBy = dto.createdBy;
        if (!StudioValidator.isValidServiceBinding(e))
            return CommandResult(false, "", "Invalid service binding data");
        repo.save(e);
        return CommandResult(true, dto.id, "");
    }

    CommandResult update(ServiceBindingDTO dto) {
        if (!repo.existsById(ServiceBindingId(dto.id)))
            return CommandResult(false, "", "Service binding not found");
        auto existing = repo.findById(ServiceBindingId(dto.id));
        if (dto.name.length > 0) existing.name = dto.name;
        if (dto.description.length > 0) existing.description = dto.description;
        if (dto.serviceUrl.length > 0) existing.serviceUrl = dto.serviceUrl;
        if (dto.updatedBy.length > 0) existing.updatedBy = dto.updatedBy;
        repo.update(existing);
        return CommandResult(true, dto.id, "");
    }

    CommandResult remove(ServiceBindingId id) {
        if (!repo.existsById(id))
            return CommandResult(false, "", "Service binding not found");
        repo.removeById(id);
        return CommandResult(true, id.value, "");
    }
}
