/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.oauth.application.usecases.manage.authorization_codes;

import uim.platform.oauth;

// mixin(ShowModule!());

@safe:

class ManageAuthorizationCodesUseCase { // TODO: UIMUseCase {
    private AuthorizationCodeRepository repo;

    this(AuthorizationCodeRepository repo) {
        this.repo = repo;
    }

    AuthorizationCode getCode(TenantId tenantId, AuthorizationCodeId id) {
        return repo.findById(tenantId, id);
    }

    AuthorizationCode[] listCodes(TenantId tenantId) {
        return repo.findByTenant(tenantId);
    }

    CommandResult createCode(AuthorizationCodeDTO dto) {
        AuthorizationCode code;

        code.initEntity(dto.tenantId);
        code.id = dto.codeId;
        code.tenantId = dto.tenantId;
        code.code = dto.code;
        // code.clientId = dto.clientId;
        code.userId = dto.userId;
        code.redirectUri = dto.redirectUri;
        code.scopes = dto.scopes;
        code.expiresAt = dto.expiresAt;
        auto error = OAuthValidator.validateAuthorizationCode(code);
        if (error.length > 0)
            return CommandResult(false, "", error);

        repo.save(code);
        return CommandResult(true, code.id.value, "");
    }

    CommandResult markUsedCode(TenantId tenantId, AuthorizationCodeId id) {
        auto code = repo.findById(tenantId, id);
        if (code.isNull)
            return CommandResult(false, "", "Authorization code not found");
        code.status = AuthCodeStatus.used;
        repo.update(code);
        return CommandResult(true, code.id.value, "");
    }

    CommandResult deleteCode(TenantId tenantId, AuthorizationCodeId id) {
        auto code = repo.findById(tenantId, id);
        if (code.isNull)
            return CommandResult(false, "", "Authorization code not found");

        repo.remove(code);
        return CommandResult(true, code.id.value, "");
    }
}
