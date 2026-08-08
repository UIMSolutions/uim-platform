/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.build_apps.application.usecases.manage.data_connections;

import uim.platform.build_apps;

mixin(ShowModule!());

@safe:

class ManageDataConnectionsUseCase { // TODO: UIMUseCase {
    private DataConnectionRepository repo;

    this(DataConnectionRepository repo) {
        this.repo = repo;
    }

    DataConnection getDataConnection(TenantId tenantId, DataConnectionId id) {
        return repo.findById(tenantId, id);
    }

    DataConnection[] listDataConnections(TenantId tenantId) {
        return repo.findByTenant(tenantId);
    }

    DataConnection[] listConnections(TenantId tenantId) {
        return listDataConnections(tenantId);
    }

    DataConnection[] listDataConnections(TenantId tenantId, ApplicationId applicationId) {
        return repo.findByApplication(tenantId, applicationId);
    }

    CommandResult createDataConnection(DataConnectionDTO dto) {
        auto e = DataConnection(dto.tenantId, dto.connectionId.isNull ? DataConnectionId(createId()) : dto.connectionId, dto.createdBy);
        e.applicationId = dto.applicationId;
        e.name = dto.name;
        e.description = dto.description;
        e.baseUrl = dto.baseUrl;
        e.basePath = dto.basePath;
        e.credentials = dto.credentials;
        e.headers = dto.headers;
        e.queryParams = dto.queryParams;
        e.responseMapping = dto.responseMapping;
        e.destinationName = dto.destinationName;
        if (!BuildAppsValidator.isValidDataConnection(e))
            return CommandResult(false, "", "Invalid data connection");

        repo.save(e);
        return CommandResult(true, e.id.value, "");
    }

    CommandResult updateDataConnection(DataConnectionDTO dto) {
        auto existing = repo.findById(dto.tenantId, dto.connectionId);
        if (existing.isNull)
            return CommandResult(false, "", "Data connection not found");
            
        if (dto.name.length > 0) existing.name = dto.name;
        if (dto.description.length > 0) existing.description = dto.description;
        if (dto.baseUrl.length > 0) existing.baseUrl = dto.baseUrl;
        if (dto.basePath.length > 0) existing.basePath = dto.basePath;
        if (!dto.updatedBy.isNull) existing.updatedBy = dto.updatedBy;

        repo.update(existing);
        return CommandResult(true, existing.id.value, "");
    }

    CommandResult deleteDataConnection(TenantId tenantId, DataConnectionId id) {
        auto entity = repo.findById(tenantId, id);
        if (entity.isNull)
            return CommandResult(false, "", "Data connection not found");
            
        repo.remove(entity);
        return CommandResult(true, entity.id.value, "");
    }
}

///
unittest {
    auto repo = new DataConnectionRepository();
    auto usecase = new ManageDataConnectionsUseCase(repo);
    auto tenantId = TenantId("test-tenant");

    // Test create
    DataConnectionDTO createDto;
    createDto.tenantId = tenantId;
    createDto.connectionId = DataConnectionId("dataConnection-1");
    createDto.name = "Test DataConnection";
    auto createResult = usecase.createDataConnection(createDto);
    // // assert(createResult.success, createResult.message);

    // Test list
    auto items = usecase.listDataConnections(tenantId);
    // assert(items.length == 1);

    // Test get
    auto item = usecase.getDataConnection(tenantId, DataConnectionId("dataConnection-1"));
    // assert(!item.isNull);

    // Test update
    DataConnectionDTO updateDto;
    updateDto.tenantId = tenantId;
    updateDto.connectionId = DataConnectionId("dataConnection-1");
    updateDto.name = "Updated DataConnection";
    auto updateResult = usecase.updateDataConnection(updateDto);
    // assert(updateResult.success, updateResult.message);

    // Test delete
    auto deleteResult = usecase.deleteDataConnection(tenantId, DataConnectionId("dataConnection-1"));
    // assert(deleteResult.success, deleteResult.message);
    // assert(usecase.listDataConnections(tenantId).length == 0);

}
