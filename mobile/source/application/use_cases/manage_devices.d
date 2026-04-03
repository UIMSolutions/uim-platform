module uim.platform.xyz.application.usecases.manage_devices;

import uim.platform.xyz.application.dto;
import uim.platform.xyz.domain.entities.device_registration;
import uim.platform.xyz.domain.ports.device_registration_repository;
import uim.platform.xyz.domain.types;

/// Use case: manage mobile device registrations.
class ManageDevicesUseCase
{
    private DeviceRegistrationRepository repo;

    this(DeviceRegistrationRepository repo)
    {
        this.repo = repo;
    }

    CommandResult register(RegisterDeviceRequest req)
    {
        if (req.appId.length == 0)
            return CommandResult(false, "", "App ID is required");

        if (req.userId.length == 0)
            return CommandResult(false, "", "User ID is required");

        // Check if device with same push token already registered
        if (req.pushToken.length > 0)
        {
            auto existing = repo.findByPushToken(req.pushToken);
            if (existing.id.length > 0)
            {
                // Update existing registration
                existing.userId = req.userId;
                existing.osVersion = req.osVersion;
                existing.appVersion = req.appVersion;
                existing.locale = req.locale;
                existing.timeZone = req.timeZone;
                existing.status = DeviceStatus.active;
                existing.lastActiveAt = clockSeconds();
                existing.updatedAt = clockSeconds();
                repo.update(existing);
                return CommandResult(true, existing.id, "");
            }
        }

        import std.uuid : randomUUID;
        auto id = randomUUID().toString();

        DeviceRegistration reg;
        reg.id = id;
        reg.appId = req.appId;
        reg.tenantId = req.tenantId;
        reg.userId = req.userId;
        reg.deviceName = req.deviceName;
        reg.platform = parsePlatform(req.platform);
        reg.osVersion = req.osVersion;
        reg.appVersion = req.appVersion;
        reg.deviceModel = req.deviceModel;
        reg.pushToken = req.pushToken;
        reg.status = DeviceStatus.active;
        reg.locale = req.locale;
        reg.timeZone = req.timeZone;
        reg.registeredAt = clockSeconds();
        reg.updatedAt = reg.registeredAt;
        reg.lastActiveAt = reg.registeredAt;
        reg.attributes = req.attributes;

        repo.save(reg);
        return CommandResult(true, id, "");
    }

    CommandResult updateDevice(DeviceRegistrationId id, UpdateDeviceRequest req)
    {
        auto reg = repo.findById(id);
        if (reg.id.length == 0)
            return CommandResult(false, "", "Device not found");

        if (req.pushToken.length > 0) reg.pushToken = req.pushToken;
        if (req.osVersion.length > 0) reg.osVersion = req.osVersion;
        if (req.appVersion.length > 0) reg.appVersion = req.appVersion;
        if (req.locale.length > 0) reg.locale = req.locale;
        if (req.timeZone.length > 0) reg.timeZone = req.timeZone;
        if (req.attributes.length > 0) reg.attributes = req.attributes;
        reg.lastActiveAt = clockSeconds();
        reg.updatedAt = clockSeconds();

        repo.update(reg);
        return CommandResult(true, id, "");
    }

    CommandResult block(DeviceRegistrationId id)
    {
        auto reg = repo.findById(id);
        if (reg.id.length == 0)
            return CommandResult(false, "", "Device not found");
        reg.status = DeviceStatus.blocked;
        reg.updatedAt = clockSeconds();
        repo.update(reg);
        return CommandResult(true, id, "");
    }

    CommandResult deregister(DeviceRegistrationId id)
    {
        auto reg = repo.findById(id);
        if (reg.id.length == 0)
            return CommandResult(false, "", "Device not found");
        reg.status = DeviceStatus.deregistered;
        reg.updatedAt = clockSeconds();
        repo.update(reg);
        return CommandResult(true, id, "");
    }

    DeviceRegistration getById(DeviceRegistrationId id) { return repo.findById(id); }
    DeviceRegistration[] listByApp(MobileAppId appId) { return repo.findByApp(appId); }
    DeviceRegistration[] listByUser(MobileAppId appId, string userId) { return repo.findByUser(appId, userId); }

    CommandResult remove(DeviceRegistrationId id)
    {
        auto reg = repo.findById(id);
        if (reg.id.length == 0)
            return CommandResult(false, "", "Device not found");
        repo.remove(id);
        return CommandResult(true, id, "");
    }
}

private MobilePlatform parsePlatform(string s)
{
    switch (s)
    {
    case "ios": return MobilePlatform.ios;
    case "android": return MobilePlatform.android;
    case "windows": return MobilePlatform.windows;
    case "webApp": return MobilePlatform.webApp;
    default: return MobilePlatform.ios;
    }
}

private long clockSeconds()
{
    import core.time : MonoTime;
    return MonoTime.currTime.ticks / 1_000_000_000;
}
