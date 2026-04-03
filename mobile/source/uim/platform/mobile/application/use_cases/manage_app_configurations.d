/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.mobile.application.use_cases.manage_app_configurations;

import uim.platform.mobile.domain.ports.app_configuration_repository;
import uim.platform.mobile.domain.entities.app_configuration;
import uim.platform.mobile.domain.types;
import uim.platform.mobile.application.dto;
import std.uuid : randomUUID;
import std.conv : to;

class ManageAppConfigurationsUseCase {
    private AppConfigurationRepository repo;

    this(AppConfigurationRepository repo) {
        this.repo = repo;
    }

    CommandResult create(CreateAppConfigurationRequest r) {
        auto existing = repo.findByKey(r.appId, r.key);
        if (existing.id.length > 0)
            return CommandResult(false, "", "Configuration with this key already exists");
        AppConfiguration config;
        config.id = randomUUID().to!string;
        config.tenantId = r.tenantId;
        config.appId = r.appId;
        config.key = r.key;
        config.value = r.value;
        config.description = r.description;
        config.dataType = r.dataType;
        config.isSecret = r.isSecret;
        config.createdAt = currentTimestamp();
        config.updatedAt = config.createdAt;
        config.createdBy = r.createdBy;
        repo.save(config);
        return CommandResult(true, config.id, "");
    }

    CommandResult update(AppConfigurationId id, UpdateAppConfigurationRequest r) {
        auto config = repo.findById(id);
        if (config.id.length == 0)
            return CommandResult(false, "", "Configuration not found");
        if (r.value.length > 0) config.value = r.value;
        if (r.description.length > 0) config.description = r.description;
        config.updatedAt = currentTimestamp();
        config.modifiedBy = r.modifiedBy;
        repo.update(config);
        return CommandResult(true, config.id, "");
    }

    AppConfiguration get_(AppConfigurationId id) {
        return repo.findById(id);
    }

    AppConfiguration getByKey(MobileAppId appId, string key) {
        return repo.findByKey(appId, key);
    }

    AppConfiguration[] listByApp(MobileAppId appId) {
        return repo.findByApp(appId);
    }

    void remove(AppConfigurationId id) {
        repo.remove(id);
    }

    long countByApp(MobileAppId appId) {
        return repo.countByApp(appId);
    }

    private static long currentTimestamp() {
        import std.datetime.systime : Clock;
        return Clock.currStdTime();
    }
}
