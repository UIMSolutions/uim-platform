/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity.application.usecases.manage.identity_providers;

import uim.platform.identity;

mixin(ShowModule!());

@safe:

class ManageIdentityProvidersUseCase {
    private IdentityProviderRepository repo;

    this(IdentityProviderRepository repo) { this.repo = repo; }

    IdentityProvider getIdentityProvider(TenantId tenantId, IdentityProviderId id) {
        return repo.findById(tenantId, id);
    }
    IdentityProvider[] listIdentityProviders(TenantId tenantId) { return repo.findByTenant(tenantId); }
    IdentityProvider findDefault(TenantId tenantId) { return repo.findDefault(tenantId); }

    CommandResult createIdentityProvider(IdentityProviderDTO dto) {
        IdentityProvider idp;
        idp.initEntity(dto.tenantId, dto.createdBy);
        idp.id = dto.idpId;
        idp.name = dto.name;
        idp.description = dto.description;
        idp.entityId = dto.entityId;
        idp.ssoUrl = dto.ssoUrl;
        idp.sloUrl = dto.sloUrl;
        idp.metadataUrl = dto.metadataUrl;
        idp.clientId = dto.clientId;
        idp.allowedDomains = dto.allowedDomains;
        idp.isDefault = dto.isDefault;
        idp.status = IdpStatus.active;

        if (dto.type_.length > 0) {
            import std.conv : to;
            try { idp.type_ = dto.type_.to!IdpType; } catch (Exception) { idp.type_ = IdpType.oidc; }
        }

        if (!IdentityValidator.isValidIdentityProvider(idp))
            return CommandResult(false, "", "Invalid IdP: name and entityId are required");

        repo.save(idp);
        return CommandResult(true, idp.id.value, "");
    }

    CommandResult updateIdentityProvider(IdentityProviderDTO dto) {
        auto existing = repo.findById(dto.tenantId, dto.idpId);
        if (existing.isNull) return CommandResult(false, "", "Identity provider not found");

        if (dto.name.length > 0) existing.name = dto.name;
        if (dto.description.length > 0) existing.description = dto.description;
        if (dto.ssoUrl.length > 0) existing.ssoUrl = dto.ssoUrl;
        if (dto.sloUrl.length > 0) existing.sloUrl = dto.sloUrl;
        if (dto.metadataUrl.length > 0) existing.metadataUrl = dto.metadataUrl;
        if (dto.allowedDomains.length > 0) existing.allowedDomains = dto.allowedDomains;
        existing.isDefault = dto.isDefault;
        if (dto.status.length > 0) {
            import std.conv : to;
            try { existing.status = dto.status.to!IdpStatus; } catch (Exception) {}
        }
        if (!dto.updatedBy.isNull) existing.updatedBy = dto.updatedBy;

        repo.update(existing);
        return CommandResult(true, existing.id.value, "");
    }

    CommandResult deleteIdentityProvider(TenantId tenantId, IdentityProviderId id) {
        auto entity = repo.findById(tenantId, id);
        if (entity.isNull) return CommandResult(false, "", "Identity provider not found");
        repo.remove(entity);
        return CommandResult(true, id.value, "");
    }
}
