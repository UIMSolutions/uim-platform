/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.mobile.domain.ports.usecases.app_configurations;
// import uim.platform.mobile.domain.ports.repositories.app_configurations;
// import uim.platform.mobile.domain.entities.app_configuration;

// import uim.platform.mobile.application.dto;

import uim.platform.mobile;

// mixin(Showmodule!());

@safe:

interface IManageAppConfigurationsUseCase { 

    /// Creates a new app configuration for the specified tenant and app.
    /// Returns a UsecaseResult indicating the success or failure of the operation.
    UsecaseResult createAppConfiguration(CreateAppConfigRequest r);

    /// Updates an existing app configuration for the specified tenant and app.
    /// Returns a UsecaseResult indicating the success or failure of the operation.
    UsecaseResult updateAppConfiguration(UpdateAppConfigRequest r);

    /// Gets an app configuration by its ID for the specified tenant.
    /// Returns the AppConfiguration if found, or null if not found.
    AppConfiguration getAppConfiguration(TenantId tenantId, AppConfigurationId id);

    /// Gets an app configuration by its key for the specified tenant and app.
    /// Returns the AppConfiguration if found, or null if not found.    
    AppConfiguration getAppConfigurationByKey(TenantId tenantId, MobileAppId appId, string key);

    /// Lists all app configurations for the specified tenant.
    /// Returns an array of AppConfiguration objects.
    AppConfiguration[] listAppConfigurations(TenantId tenantId);

    /// Lists all app configurations for the specified tenant and app.
    /// Returns an array of AppConfiguration objects.   
    AppConfiguration[] listAppConfigurations(TenantId tenantId, MobileAppId appId);

    /// Deletes an app configuration by its ID for the specified tenant.
    /// Returns a UsecaseResult indicating the success or failure of the operation.
    UsecaseResult deleteAppConfiguration(TenantId tenantId, AppConfigurationId id);

    /// Deletes an app configuration by its key for the specified tenant and app.
    /// Returns a UsecaseResult indicating the success or failure of the operation.
    size_t countAppConfigurationsByApp(TenantId tenantId, MobileAppId appId);

}
