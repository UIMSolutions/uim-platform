/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.customer_identity.application.usecases.manage.social_identities;

import uim.platform.customer_identity;

// mixin(ShowModule!());

@safe:

class ManageSocialIdentitiesUseCase {
    private SocialIdentityRepository repo;

    this(SocialIdentityRepository repo) {
        this.repo = repo;
    }

    SocialIdentity getSocialIdentity(TenantId tenantId, SocialIdentityId id) {
        return repo.findById(tenantId, id);
    }

    SocialIdentity[] listSocialIdentities(TenantId tenantId) {
        return repo.findByTenant(tenantId);
    }

    SocialIdentity[] listByCustomer(TenantId tenantId, CustomerId customerId) {
        return repo.findByCustomer(tenantId, customerId);
    }

    CommandResult linkSocialIdentity(SocialIdentityDTO dto) {
        SocialIdentity si;
        si.initEntity(dto.tenantId, dto.createdBy);
        si.customerId = dto.customerId;
        si.providerUserId = dto.providerUserId;
        si.providerEmail = dto.providerEmail;
        si.displayName = dto.displayName;
        si.accessToken = dto.accessToken;
        si.refreshToken = dto.refreshToken;
        si.tokenExpiresAt = dto.tokenExpiresAt;
        si.profileData = dto.profileData;
        si.status = SocialIdentityStatus.linked;

        
        try { si.provider = dto.provider.to!LoginProvider; }
        catch (Exception) { return CommandResult(false, "", "Invalid social provider"); }

        if (!IdentityValidator.isValidSocialIdentity(si))
            return CommandResult(false, "", "Invalid social identity data");

        repo.save(si);
        return CommandResult(true, si.id.value, "");
    }

    CommandResult unlinkSocialIdentity(TenantId tenantId, SocialIdentityId id) {
        auto existing = repo.findById(tenantId, id);
        if (existing.isNull)
            return CommandResult(false, "", "Social identity not found");

        existing.status = SocialIdentityStatus.unlinked;
        repo.update(existing);
        return CommandResult(true, existing.id.value, "");
    }

    CommandResult deleteSocialIdentity(TenantId tenantId, SocialIdentityId id) {
        auto existing = repo.findById(tenantId, id);
        if (existing.isNull)
            return CommandResult(false, "", "Social identity not found");

        repo.remove(existing);
        return CommandResult(true, existing.id.value, "");
    }
}
