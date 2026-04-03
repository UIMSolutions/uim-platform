module uim.platform.xyz.domain.ports.device_registration_repository;

import uim.platform.xyz.domain.entities.device_registration;
import uim.platform.xyz.domain.types;

/// Port: outgoing — device registration persistence.
interface DeviceRegistrationRepository
{
    DeviceRegistration findById(DeviceRegistrationId id);
    DeviceRegistration[] findByApp(MobileAppId appId);
    DeviceRegistration[] findByUser(MobileAppId appId, string userId);
    DeviceRegistration[] findByPlatform(MobileAppId appId, MobilePlatform platform);
    DeviceRegistration[] findByStatus(MobileAppId appId, DeviceStatus status);
    DeviceRegistration findByPushToken(string pushToken);
    void save(DeviceRegistration reg);
    void update(DeviceRegistration reg);
    void remove(DeviceRegistrationId id);
}
