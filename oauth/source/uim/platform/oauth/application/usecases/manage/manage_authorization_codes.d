/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.oauth.application.usecases.manage.manage_authorization_codes;

import uim.platform.oauth;

mixin(ShowModule!());

@safe:

class ManageAuthorizationCodesUseCase { // TODO: UIMUseCase {
    private AuthorizationCodeRepository repo;

    this(AuthorizationCodeRepository repo) {
        this.repo = repo;
    }

    AuthorizationCode getById(AuthorizationCodeId id) {
        return repo.findById(id);
    }

    AuthorizationCode getByCode(string code) {
        return repo.findByCode(code);
    }

    AuthorizationCode[] list() {
        return repo.findAll();
    }

    AuthorizationCode[] listByTenant(TenantId tenantId) {
        return repo.findByTenant(tenantId);
    }

    CommandResult create(AuthorizationCodeDTO dto) {
        AuthorizationCode e;
        e.id = AuthorizationCodeId(dto.id);
        e.tenantId = dto.tenantId;
        e.code = dto.code;
        e.clientId = dto.clientId;
        e.userId = dto.userId;
        e.redirectUri = dto.redirectUri;
        e.scopes = dto.scopes;
        e.expiresAt = dto.expiresAt;
        auto error = OAuthValidator.validateAuthorizationCode(e);
        if (error.length > 0)
            return CommandResult(false, "", error);
        repo.save(e);
        return CommandResult(true, dto.id, "");
    }

    CommandResult markUsed(AuthorizationCodeId id) {
        if (!repo.existsById(id))
            return CommandResult(false, "", "Authorization code not found");
        auto existing = repo.findById(id);
        existing.status = AuthCodeStatus.used;
        repo.update(existing);
        return CommandResult(true, id.value, "");
    }

    CommandResult remove(AuthorizationCodeId id) {
        if (!repo.existsById(id))
            return CommandResult(false, "", "Authorization code not found");
        repo.removeById(id);
        return CommandResult(true, id.value, "");
    }
}
