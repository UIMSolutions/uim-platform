/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.mobile.application.usecases.manage.client_resources;
// import uim.platform.mobile.domain.ports.repositories.client_resources;
// import uim.platform.mobile.domain.entities.client_resource;

// import uim.platform.mobile.application.dto;


import uim.platform.mobile;

// mixin(Showmodule!());

@safe:
class ManageClientResourcesUseCase { // TODO: UIMUseCase {
    private ClientResourceRepository repo;

    this(ClientResourceRepository repo) {
        this.repo = repo;
    }

    CommandResult createClientResource(CreateClientResourceRequest r) {
        ClientResource resource;
        resource.initEntity(r.tenantId, r.createdBy);

        resource.appId = r.appId;
        resource.name = r.name;
        resource.description = r.description;
        resource.resourceType = r.resourceType;
        resource.url = r.url;
        resource.checksum = r.checksum;
        resource.sizeBytes = r.sizeBytes;
        resource.version_ = r.version_;

        repo.save(resource);
        return CommandResult(true, resource.id.value, "");
    }

    CommandResult updateClientResource(UpdateClientResourceRequest r) {
        auto resource = repo.findById(r.tenantId, r.id);
        if (resource.isNull)
            return CommandResult(false, "", "Client resource not found");
        if (r.description.length > 0)
            resource.description = r.description;
        if (r.url.length > 0)
            resource.url = r.url;
        if (r.checksum.length > 0)
            resource.checksum = r.checksum;
        if (r.sizeBytes > 0)
            resource.sizeBytes = r.sizeBytes;
        if (r.version_.length > 0)
            resource.version_ = r.version_;
        resource.updatedAt = currentTimestamp();
        resource.updatedBy = r.updatedBy;
        repo.update(resource);
        return CommandResult(true, resource.id.value, "");
    }

    ClientResource getClientResource(TenantId tenantId, ClientResourceId id) {
        return repo.findById(tenantId, id);
    }

    ClientResource[] listClientResourcesByApp(TenantId tenantId, MobileAppId appId) {
        return repo.findByApp(tenantId, appId);
    }

    CommandResult deleteClientResource(TenantId tenantId, ClientResourceId id) {
        auto resource = repo.findById(tenantId, id);
        if (resource.isNull)
            return CommandResult(false, "", "Client resource not found");

        repo.remove(resource);
        return CommandResult(true, resource.id.value, "");
    }

    size_t countClientResourcesByApp(TenantId tenantId, MobileAppId appId) {
        return repo.countByApp(tenantId, appId);
    }

}
