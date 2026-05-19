/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.customer_identity.application.usecases.manage.site_policies;

import uim.platform.customer_identity;

mixin(ShowModule!());

@safe:

class ManageSitePoliciesUseCase {
    private SitePolicyRepository repo;

    this(SitePolicyRepository repo) {
        this.repo = repo;
    }

    SitePolicy getSitePolicy(TenantId tenantId, SitePolicyId id) {
        return repo.findById(tenantId, id);
    }

    SitePolicy[] listSitePolicies(TenantId tenantId) {
        return repo.findByTenant(tenantId);
    }

    CommandResult createSitePolicy(SitePolicyDTO dto) {
        SitePolicy sp;
        sp.initEntity(dto.tenantId, dto.createdBy);
        sp.name = dto.name;
        sp.description = dto.description;
        sp.passwordMinLength = dto.passwordMinLength > 0 ? dto.passwordMinLength : 8;
        sp.passwordRequirements = dto.passwordRequirements;
        sp.sessionTimeoutSeconds = dto.sessionTimeoutSeconds > 0 ? dto.sessionTimeoutSeconds : 3600;
        sp.mfaRequired = dto.mfaRequired;
        sp.captchaEnabled = dto.captchaEnabled;
        sp.socialLoginEnabled = dto.socialLoginEnabled;
        sp.progressiveProfilingEnabled = dto.progressiveProfilingEnabled;
        sp.maxLoginAttempts = dto.maxLoginAttempts > 0 ? dto.maxLoginAttempts : 5;
        sp.lockoutDurationSeconds = dto.lockoutDurationSeconds > 0 ? dto.lockoutDurationSeconds : 300;
        sp.emailVerificationRequired = dto.emailVerificationRequired;
        sp.version_ = dto.version_;

        import std.conv : to;
        try { sp.policyType = dto.policyType.to!PolicyType; }
        catch (Exception) { return CommandResult(false, "", "Invalid policy type"); }
        try { sp.passwordComplexity = dto.passwordComplexity.to!PasswordComplexity; }
        catch (Exception) { sp.passwordComplexity = PasswordComplexity.medium; }
        try { sp.mfaMethod = dto.mfaMethod.to!MfaMethod; }
        catch (Exception) { sp.mfaMethod = MfaMethod.none; }

        if (!IdentityValidator.isValidSitePolicy(sp))
            return CommandResult(false, "", "Invalid site policy data");

        repo.save(sp);
        return CommandResult(true, sp.id.value, "");
    }

    CommandResult updateSitePolicy(SitePolicyDTO dto) {
        auto existing = repo.findById(dto.tenantId, dto.sitePolicyId);
        if (existing.isNull)
            return CommandResult(false, "", "Site policy not found");

        if (dto.name.length > 0) existing.name = dto.name;
        if (dto.description.length > 0) existing.description = dto.description;
        if (dto.passwordMinLength > 0) existing.passwordMinLength = dto.passwordMinLength;
        if (dto.sessionTimeoutSeconds > 0) existing.sessionTimeoutSeconds = dto.sessionTimeoutSeconds;
        if (dto.maxLoginAttempts > 0) existing.maxLoginAttempts = dto.maxLoginAttempts;
        existing.mfaRequired = dto.mfaRequired;
        existing.captchaEnabled = dto.captchaEnabled;
        existing.socialLoginEnabled = dto.socialLoginEnabled;
        if (!dto.updatedBy.isNull) existing.updatedBy = dto.updatedBy;

        repo.update(existing);
        return CommandResult(true, existing.id.value, "");
    }

    CommandResult deleteSitePolicy(TenantId tenantId, SitePolicyId id) {
        auto existing = repo.findById(tenantId, id);
        if (existing.isNull)
            return CommandResult(false, "", "Site policy not found");

        repo.remove(existing);
        return CommandResult(true, existing.id.value, "");
    }
}
