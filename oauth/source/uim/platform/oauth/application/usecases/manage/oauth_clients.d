/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.oauth.application.usecases.manage.oauth_clients;

import uim.platform.oauth;

mixin(ShowModule!());

@safe:

class ManageOAuthClientsUseCase { // TODO: UIMUseCase {
    private IOAuthClientRepository repo;

    this(IOAuthClientRepository repo) {
        this.repo = repo;
    }

    OAuthClient getClient(TenantId tenantId, OAuthClientId id) {
        return repo.findById(tenantId, id);
    }

    OAuthClient[] listClients(TenantId tenantId) {
        return repo.findByTenant(tenantId);
    }

    CommandResult createClient(OAuthClientDTO dto) {
        OAuthClient client;
        client.id = dto.clientId;
        client.tenantId = dto.tenantId;
        // client.clientId = dto.clientId;
        client.clientSecret = dto.clientSecret;
        client.name = dto.name;
        client.description = dto.description;
        client.redirectUris = dto.redirectUris;
        client.allowedScopes = dto.allowedScopes;
        client.grantTypes = dto.grantTypes;
        client.accessTokenValidity = dto.accessTokenValidity;
        client.refreshTokenValidity = dto.refreshTokenValidity;
        client.contacts = dto.contacts;
        client.createdBy = dto.createdBy;
        auto error = OAuthValidator.validateOAuthClient(client);
        if (error.length > 0)
            return CommandResult(false, "", error);
            
        repo.save(client);
        return CommandResult(true, client.id.value, "");
    }

    CommandResult updateClient(OAuthClientDTO dto) {
        auto client = repo.findById(dto.tenantId, dto.clientId);
         if (client.isNull)
            return CommandResult(false, "", "OAuth client not found");  

        client.name = dto.name;
        client.description = dto.description;
        client.redirectUris = dto.redirectUris;
        client.allowedScopes = dto.allowedScopes;
        client.grantTypes = dto.grantTypes;
        client.accessTokenValidity = dto.accessTokenValidity;
        client.refreshTokenValidity = dto.refreshTokenValidity;
        client.contacts = dto.contacts;
        client.updatedBy = dto.updatedBy;
        repo.update(client);
        return CommandResult(true, client.id.value, "");
    }

    CommandResult deleteClient(TenantId tenantId, OAuthClientId id) {
        auto client = repo.findById(tenantId, id);
        if (client.isNull)
            return CommandResult(false, "", "OAuth client not found");

        repo.remove(client);
        return CommandResult(true, client.id.value, "");
    }
}

///
unittest {
    // auto repo = new OAuthClientRepository();
    // auto usecase = new ManageOAuthClientsUseCase(repo);
    // auto tenantId = TenantId("test-tenant");

    // // Test create
    // OAuthClientDTO createDto;
    // createDto.tenantId = tenantId;
    // createDto.oAuthClientId = OAuthClientId("oAuthClient-1");
    // createDto.name = "Test OAuthClient";
    // auto createResult = usecase.createClient(createDto);
    // assert(createResult.success, createResult.message);

    // // Test list
    // auto items = usecase.listClients(tenantId);
    // assert(items.length == 1);

    // // Test get
    // auto item = usecase.getClient(tenantId, OAuthClientId("oAuthClient-1"));
    // assert(!item.isNull);

    // // Test update
    // OAuthClientDTO updateDto;
    // updateDto.tenantId = tenantId;
    // updateDto.oAuthClientId = OAuthClientId("oAuthClient-1");
    // updateDto.name = "Updated OAuthClient";
    // auto updateResult = usecase.updateClient(updateDto);
    // assert(updateResult.success, updateResult.message);

    // // Test delete
    // auto deleteResult = usecase.deleteClient(tenantId, OAuthClientId("oAuthClient-1"));
    // assert(deleteResult.success, deleteResult.message);
    // assert(usecase.listClients(tenantId).length == 0);

}
