/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.customer_identity.application.usecases.manage.identity_providers;

import uim.platform.customer_identity;

mixin(ShowModule!());

@safe:

class ManageIdentityProvidersUseCase {
    private IdentityProviderRepository repo;

    this(IdentityProviderRepository repo) {
        this.repo = repo;
    }

    IdentityProvider getIdentityProvider(TenantId tenantId, IdentityProviderId id) {
        return repo.findById(tenantId, id);
    }

    IdentityProvider[] listIdentityProviders(TenantId tenantId) {
        return repo.findByTenant(tenantId);
    }

    IdentityProvider[] listActive(TenantId tenantId) {
        return repo.findActive(tenantId);
    }

    CommandResult createIdentityProvider(IdentityProviderDTO dto) {
        IdentityProvider ip;
        ip.initEntity(dto.tenantId, dto.createdBy);
        ip.name = dto.name;
        ip.description = dto.description;
        ip.clientId = dto.clientId;
        ip.clientSecret = dto.clientSecret;
        ip.issuerUrl = dto.issuerUrl;
        ip.metadataUrl = dto.metadataUrl;
        ip.redirectUri = dto.redirectUri;
        ip.attributeMapping = dto.attributeMapping;
        ip.scopes = dto.scopes;
        ip.status = IdentityProviderStatus.inactive;

        
        try { ip.providerType = dto.providerType.to!IdentityProviderType; }
        catch (Exception) { return CommandResult(false, "", "Invalid provider type"); }

        if (!IdentityValidator.isValidIdentityProvider(ip))
            return CommandResult(false, "", "Invalid identity provider data");

        repo.save(ip);
        return CommandResult(true, ip.id.value, "");
    }

    CommandResult updateIdentityProvider(IdentityProviderDTO dto) {
        auto existing = repo.findById(dto.tenantId, dto.identityProviderId);
        if (existing.isNull)
            return CommandResult(false, "", "Identity provider not found");

        if (dto.name.length > 0) existing.name = dto.name;
        if (dto.description.length > 0) existing.description = dto.description;
        if (dto.issuerUrl.length > 0) existing.issuerUrl = dto.issuerUrl;
        if (dto.metadataUrl.length > 0) existing.metadataUrl = dto.metadataUrl;
        if (dto.redirectUri.length > 0) existing.redirectUri = dto.redirectUri;
        if (dto.attributeMapping.length > 0) existing.attributeMapping = dto.attributeMapping;
        if (dto.scopes.length > 0) existing.scopes = dto.scopes;
        if (!dto.updatedBy.isNull) existing.updatedBy = dto.updatedBy;

        repo.update(existing);
        return CommandResult(true, existing.id.value, "");
    }

    CommandResult deleteIdentityProvider(TenantId tenantId, IdentityProviderId id) {
        auto existing = repo.findById(tenantId, id);
        if (existing.isNull)
            return CommandResult(false, "", "Identity provider not found");

        repo.remove(existing);
        return CommandResult(true, existing.id.value, "");
    }
}
