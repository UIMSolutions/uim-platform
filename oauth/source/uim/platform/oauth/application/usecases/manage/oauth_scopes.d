/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.oauth.application.usecases.manage.oauth_scopes;

import uim.platform.oauth;

mixin(ShowModule!());

@safe:

class ManageOAuthScopesUseCase { // TODO: UIMUseCase {
    private IOAuthScopeRepository repo;

    this(IOAuthScopeRepository repo) {
        this.repo = repo;
    }

    OAuthScope getScope(TenantId tenantId, OAuthScopeId id) {
        return repo.findById(tenantId, id);
    }

    OAuthScope[] listScopes(TenantId tenantId) {
        return repo.findByTenant(tenantId);
    }

    OAuthScope[] listScopes(TenantId tenantId, string applicationId) {
        return repo.findByApplication(tenantId, applicationId);
    }

    CommandResult createScope(OAuthScopeDTO dto) {
        OAuthScope scope_;
        scope_.id = dto.scopeId;
        scope_.tenantId = dto.tenantId;
        scope_.applicationId = dto.applicationId;
        scope_.name = dto.name;
        scope_.description = dto.description;
        scope_.createdBy = dto.createdBy;
        auto error = OAuthValidator.validateOAuthScope(scope_);
        if (error.length > 0)
            return CommandResult(false, "", error);

        repo.save(scope_);
        return CommandResult(true, scope_.id.value, "");
    }

    CommandResult updateScope(OAuthScopeDTO dto) {
        auto scope_ = repo.findById(dto.tenantId, dto.scopeId);
        if (scope_.isNull)
            return CommandResult(false, "", "OAuth scope not found");

        scope_.name = dto.name;
        scope_.description = dto.description;
        scope_.updatedBy = dto.updatedBy;

        repo.update(scope_);
        return CommandResult(true, scope_.id.value, "");
    }

    CommandResult deleteOAuthScope(TenantId tenantId, OAuthScopeId id) {
        auto scope_ = repo.findById(tenantId, id);
        if (scope_.isNull)
            return CommandResult(false, "", "OAuth scope not found");

        repo.remove(scope_);
        return CommandResult(true, scope_.id.value, "");
    }
}

///
unittest {
    // auto repo = new OAuthScopeRepository();
    // auto usecase = new ManageOAuthScopesUseCase(repo);
    // auto tenantId = TenantId("test-tenant");

    // // Test create
    // OAuthScopeDTO createDto;
    // createDto.tenantId = tenantId;
    // createDto.oAuthScopeId = OAuthScopeId("oAuthScope-1");
    // createDto.name = "Test OAuthScope";
    // auto createResult = usecase.createScope(createDto);
    // assert(createResult.success, createResult.message);

    // // Test list
    // auto items = usecase.listScopes(tenantId);
    // assert(items.length == 1);

    // // Test get
    // auto item = usecase.getScope(tenantId, OAuthScopeId("oAuthScope-1"));
    // assert(!item.isNull);

    // // Test update
    // OAuthScopeDTO updateDto;
    // updateDto.tenantId = tenantId;
    // updateDto.oAuthScopeId = OAuthScopeId("oAuthScope-1");
    // updateDto.name = "Updated OAuthScope";
    // auto updateResult = usecase.updateScope(updateDto);
    // assert(updateResult.success, updateResult.message);

    // // Test delete
    // auto deleteResult = usecase.deleteOAuthScope(tenantId, OAuthScopeId("oAuthScope-1"));
    // assert(deleteResult.success, deleteResult.message);
    // assert(usecase.listScopes(tenantId).length == 0);

}
