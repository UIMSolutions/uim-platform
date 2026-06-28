/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.agentry.presentation.rest.interfaces.device;

import uim.platform.agentry;

mixin(ShowModule!());

@safe:

interface IDeviceApi {
    @headerParam("tenantId", "X-Tenant-Id")
    Device[] listDevices(string tenantId);

    @headerParam("tenantId", "X-Tenant-Id")
    Device getDevice(string tenantId, string deviceId);

    @headerParam("tenantId", "X-Tenant-Id")
    void createDevice(string tenantId, Device device);

    @headerParam("tenantId", "X-Tenant-Id")
    void updateDevice(string tenantId, Device device);

    @headerParam("tenantId", "X-Tenant-Id")
    void deleteDevice(string tenantId, string deviceId);
}
