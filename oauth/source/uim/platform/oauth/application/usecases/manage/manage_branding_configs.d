/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.oauth.application.usecases.manage.manage_branding_configs;

import uim.platform.oauth;

mixin(ShowModule!());

@safe:

class ManageBrandingConfigsUseCase { // TODO: UIMUseCase {
    private BrandingConfigRepository repo;

    this(BrandingConfigRepository repo) {
        this.repo = repo;
    }

    BrandingConfig getById(BrandingConfigId id) {
        return repo.findById(id);
    }

    BrandingConfig[] list() {
        return repo.findAll();
    }

    BrandingConfig[] listByTenant(TenantId tenantId) {
        return repo.findByTenant(tenantId);
    }

    CommandResult create(BrandingConfigDTO dto) {
        BrandingConfig e;
        e.id = BrandingConfigId(dto.id);
        e.tenantId = dto.tenantId;
        e.name = dto.name;
        e.description = dto.description;
        e.logoUrl = dto.logoUrl;
        e.backgroundUrl = dto.backgroundUrl;
        e.primaryColor = dto.primaryColor;
        e.secondaryColor = dto.secondaryColor;
        e.pageTitle = dto.pageTitle;
        e.footerText = dto.footerText;
        e.customCss = dto.customCss;
        e.createdBy = dto.createdBy;
        auto error = OAuthValidator.validateBrandingConfig(e);
        if (error.length > 0)
            return CommandResult(false, "", error);
        repo.save(e);
        return CommandResult(true, dto.id, "");
    }

    CommandResult update(BrandingConfigDTO dto) {
        if (!repo.existsById(BrandingConfigId(dto.id)))
            return CommandResult(false, "", "Branding config not found");
        auto existing = repo.findById(BrandingConfigId(dto.id));
        existing.name = dto.name;
        existing.description = dto.description;
        existing.logoUrl = dto.logoUrl;
        existing.backgroundUrl = dto.backgroundUrl;
        existing.primaryColor = dto.primaryColor;
        existing.secondaryColor = dto.secondaryColor;
        existing.pageTitle = dto.pageTitle;
        existing.footerText = dto.footerText;
        existing.customCss = dto.customCss;
        existing.updatedBy = dto.updatedBy;
        repo.update(existing);
        return CommandResult(true, dto.id, "");
    }

    CommandResult remove(BrandingConfigId id) {
        if (!repo.existsById(id))
            return CommandResult(false, "", "Branding config not found");
        repo.removeById(id);
        return CommandResult(true, id.value, "");
    }
}
