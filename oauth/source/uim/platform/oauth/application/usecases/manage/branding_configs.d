/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.oauth.application.usecases.manage.branding_configs;

import uim.platform.oauth;

mixin(ShowModule!());

@safe:

class ManageBrandingConfigsUseCase { // TODO: UIMUseCase {
    private IBrandingConfigRepository repo;

    this(IBrandingConfigRepository repo) {
        this.repo = repo;
    }

    BrandingConfig getConfig(TenantId tenantId, BrandingConfigId id) {
        return repo.findById(tenantId, id);
    }

    BrandingConfig[] listConfigs(TenantId tenantId) {
        return repo.findByTenant(tenantId);
    }

    CommandResult createConfig(BrandingConfigDTO dto) {
        BrandingConfig e;
        e.id = dto.configId;
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
        return CommandResult(true, e.id.value, "");
    }

    CommandResult updateConfig(BrandingConfigDTO dto) {
        auto existing = repo.findById(dto.tenantId, dto.configId);
        if (existing.isNull)
            return CommandResult(false, "", "Branding config not found");

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
        return CommandResult(true, existing.id.value, "");
    }


    CommandResult deleteConfig(TenantId tenantId, BrandingConfigId id) {
        auto config = repo.findById(tenantId, id);
        if (config.isNull)            
            return CommandResult(false, "", "Branding config not found");

        repo.remove(config);
        return CommandResult(true, config.id.value, "");
    }
}

///
unittest {
    auto repo = new IBrandingConfigRepository();
    auto usecase = new ManageBrandingConfigsUseCase(repo);
    auto tenantId = TenantId("test-tenant");

    // Test create
    BrandingConfigDTO createDto;
    createDto.tenantId = tenantId;
    createDto.brandingConfigId = BrandingConfigId("brandingConfig-1");
    createDto.name = "Test BrandingConfig";
    auto createResult = usecase.createConfig(createDto);
    assert(createResult.success, createResult.message);

    // Test list
    auto items = usecase.listConfigs(tenantId);
    assert(items.length == 1);

    // Test get
    auto item = usecase.getConfig(tenantId, BrandingConfigId("brandingConfig-1"));
    assert(!item.isNull);

    // Test update
    BrandingConfigDTO updateDto;
    updateDto.tenantId = tenantId;
    updateDto.brandingConfigId = BrandingConfigId("brandingConfig-1");
    updateDto.name = "Updated BrandingConfig";
    auto updateResult = usecase.updateConfig(updateDto);
    assert(updateResult.success, updateResult.message);

    // Test delete
    auto deleteResult = usecase.deleteConfig(tenantId, BrandingConfigId("brandingConfig-1"));
    assert(deleteResult.success, deleteResult.message);
    assert(usecase.listConfigs(tenantId).length == 0);

}
