/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.mobile.domain.ports.usecases.client_logs;
// import uim.platform.mobile.domain.ports.repositories.client_logs;
// import uim.platform.mobile.domain.entities.client_log_entry;

// import uim.platform.mobile.application.dto;

import uim.platform.mobile;

// mixin(Showmodule!());

@safe:
interface IManageClientLogsUseCase { 

    /// Uploads a client log entry to the system.
    /// Returns a CommandResult indicating the success or failure of the operation.
    CommandResult uploadLog(UploadClientLogRequest r);

    /// Retrieves a client log entry by its ID for the specified tenant.
    /// Returns the ClientLogEntry if found, or null if not found.
    ClientLogEntry getLog(TenantId tenantId, ClientLogEntryId id);

    /// Lists all client log entries for the specified tenant.
    /// Returns an array of ClientLogEntry objects.
    ClientLogEntry[] listLogs(TenantId tenantId);

    /// Lists all client log entries for the specified tenant and app.
    /// Returns an array of ClientLogEntry objects.
    ClientLogEntry[] listLogs(TenantId tenantId, MobileAppId appId);

    /// Lists all client log entries for the specified tenant and device.
    /// Returns an array of ClientLogEntry objects.
    ClientLogEntry[] listLogs(TenantId tenantId, DeviceRegistrationId deviceId);

    /// Lists all client log entries for the specified tenant, app, and log level.
    /// Returns an array of ClientLogEntry objects.
    ClientLogEntry[] listLogs(TenantId tenantId, MobileAppId appId, string level);

    /// Deletes a client log entry by its ID for the specified tenant.
    /// Returns a CommandResult indicating the success or failure of the operation.
    CommandResult deleteLog(TenantId tenantId, ClientLogEntryId id);

    /// Counts the number of client log entries for the specified tenant and app.
    /// Returns the count as a size_t value.
    size_t countLogs(TenantId tenantId, MobileAppId appId);

}
