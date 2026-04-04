/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.mobile.application.usecases.manage_client_resources;

import uim.platform.mobile.domain.ports.client_resource_repository;
import uim.platform.mobile.domain.entities.client_resource;
import uim.platform.mobile.domain.types;
import uim.platform.mobile.application.dto;
import std.uuid : randomUUID;
import std.conv : to;

class ManageClientResourcesUseCase : UIMUseCase {
    private ClientResourceRepository repo;

    this(ClientResourceRepository repo) {
        this.repo = repo;
    }

    CommandResult create(CreateClientResourceRequest r) {
        ClientResource resource;
        resource.id = randomUUID().to!string;
        resource.tenantId = r.tenantId;
        resource.appId = r.appId;
        resource.name = r.name;
        resource.description = r.description;
        resource.resourceType = r.resourceType;
        resource.url = r.url;
        resource.checksum = r.checksum;
        resource.sizeBytes = r.sizeBytes;
        resource.version_ = r.version_;
        resource.createdAt = currentTimestamp();
        resource.updatedAt = resource.createdAt;
        resource.createdBy = r.createdBy;
        repo.save(resource);
        return CommandResult(true, resource.id, "");
    }

    CommandResult update(ClientResourceId id, UpdateClientResourceRequest r) {
        auto resource = repo.findById(id);
        if (resource.id.length == 0)
            return CommandResult(false, "", "Client resource not found");
        if (r.description.length > 0) resource.description = r.description;
        if (r.url.length > 0) resource.url = r.url;
        if (r.checksum.length > 0) resource.checksum = r.checksum;
        if (r.sizeBytes > 0) resource.sizeBytes = r.sizeBytes;
        if (r.version_.length > 0) resource.version_ = r.version_;
        resource.updatedAt = currentTimestamp();
        resource.modifiedBy = r.modifiedBy;
        repo.update(resource);
        return CommandResult(true, resource.id, "");
    }

    ClientResource get_(ClientResourceId id) {
        return repo.findById(id);
    }

    ClientResource[] listByApp(MobileAppId appId) {
        return repo.findByApp(appId);
    }

    void remove(ClientResourceId id) {
        repo.remove(id);
    }

    long countByApp(MobileAppId appId) {
        return repo.countByApp(appId);
    }

    private static long currentTimestamp() {
        import std.datetime.systime : Clock;
        return Clock.currStdTime();
    }
}
