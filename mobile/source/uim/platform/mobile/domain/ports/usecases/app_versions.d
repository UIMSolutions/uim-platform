/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.mobile.domain.ports.usecases.app_versions;
// import uim.platform.mobile.domain.ports.repositories.app_versions;
// import uim.platform.mobile.domain.entities.app_version;

// import uim.platform.mobile.application.dto;


import uim.platform.mobile;

// mixin(Showmodule!());

@safe:
interface IManageAppVersionsUseCase { 

    /// Creates a new app version for the specified tenant and app.
    /// Returns a UsecaseResult indicating the success or failure of the operation.
    UsecaseResult createAppVersion(CreateAppVersionRequest r);

    /// Updates an existing app version for the specified tenant and app.
    /// Returns a UsecaseResult indicating the success or failure of the operation.
    UsecaseResult updateAppVersion(UpdateAppVersionRequest r);

    /// Gets an app version by its ID for the specified tenant.
    /// Returns the AppVersion if found, or null if not found.
    AppVersion getAppVersion(TenantId tenantId, AppVersionId id);

    /// Lists all app versions for the specified tenant.
    /// Returns an array of AppVersion objects.
    AppVersion[] listAppVersions(TenantId tenantId);

    /// Lists all app versions for the specified tenant and app.
    /// Returns an array of AppVersion objects.
    AppVersion[] listAppVersions(TenantId tenantId, MobileAppId id);

    /// Deletes an app version by its ID for the specified tenant.
    /// Returns a UsecaseResult indicating the success or failure of the operation.
    UsecaseResult deleteAppVersion(TenantId tenantId, AppVersionId id);

    /// Counts the number of app versions for the specified tenant and app.
    /// Returns the count as a size_t value.
    size_t countAppVersions(TenantId tenantId, MobileAppId id);

}
