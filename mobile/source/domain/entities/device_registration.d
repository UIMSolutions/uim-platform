module uim.platform.mobile.domain.entities.device_registration;

import uim.platform.mobile.domain.types;

/// A registered mobile device with push token and metadata.
struct DeviceRegistration
{
    DeviceRegistrationId id;
    MobileAppId appId;
    TenantId tenantId;
    string userId;
    string deviceName;
    MobilePlatform platform;
    string osVersion;
    string appVersion;
    string deviceModel;
    string pushToken;               // APNS or FCM token
    DeviceStatus status = DeviceStatus.registered;
    string locale;
    string timeZone;
    string ipAddress;
    double latitude = 0;
    double longitude = 0;
    long lastActiveAt;
    long registeredAt;
    long updatedAt;
    string[string] attributes;      // custom device attributes
}
