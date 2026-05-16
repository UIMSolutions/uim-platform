/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.mobile.application.usecases.manage.app_configurations;
// import uim.platform.mobile.domain.ports.repositories.app_configurations;
// import uim.platform.mobile.domain.entities.app_configuration;
// import uim.platform.mobile.domain.types;
// import uim.platform.mobile.application.dto;

import uim.platform.mobile;

mixin(Showmodule!());

@safe:

class ManageAppConfigurationsUseCase { // TODO: UIMUseCase {
    private AppConfigurationRepository repo;

    this(AppConfigurationRepository repo) {
        this.repo = repo;
    }

    CommandResult createAppConfiguration(CreateAppConfigurationRequest r) {
        auto existing = repo.findByKey(r.tenantId, r.appId, r.key);
        if (!existing.isNull)
            return CommandResult(false, "", "Configuration with this key already exists");
        AppConfiguration config;
        config.initEntity(r.tenantId, r.createdBy);

        config.appId = r.appId;
        config.key = r.key;
        config.value = r.value;
        config.description = r.description;
        config.dataType = r.dataType;
        config.isSecret = r.isSecret;

        repo.save(config);
        return CommandResult(true, config.id.value, "");
    }

    CommandResult updateAppConfiguration(UpdateAppConfigurationRequest r) {
        auto config = repo.findById(r.tenantId, r.id);
        if (config.isNull)
            return CommandResult(false, "", "Configuration not found");
        if (r.value.length > 0)
            config.value = r.value;
        if (r.description.length > 0)
            config.description = r.description;
        config.updatedAt = currentTimestamp();
        config.updatedBy = r.updatedBy;
        repo.update(config);
        return CommandResult(true, config.id.value, "");
    }

    AppConfiguration getAppConfiguration(TenantId tenantId, AppConfigurationId id) {
        return repo.findById(tenantId, id);
    }

    AppConfiguration getAppConfigurationByKey(TenantId tenantId, MobileAppId appId, string key) {
        return repo.findByKey(tenantId, appId, key);
    }

    AppConfiguration[] listAppConfigurationsByApp(TenantId tenantId, MobileAppId appId) {
        return repo.findByApp(tenantId, appId);
    }

    CommandResult deleteAppConfiguration(TenantId tenantId, AppConfigurationId id) {
        auto config = repo.findById(tenantId, id);
        if (config.isNull)
            return CommandResult(false, "", "Configuration not found");

        repo.remove(config);
        return CommandResult(true, config.id.value, "");
    }

    size_t countAppConfigurationsByApp(TenantId tenantId, MobileAppId appId) {
        return repo.countByApp(tenantId, appId);
    }

}
