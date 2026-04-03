module uim.platform.mobile.domain.ports.push_notification_repository;

import uim.platform.mobile.domain.entities.push_notification;
import uim.platform.mobile.domain.types;

/// Port: outgoing — push notification persistence.
interface PushNotificationRepository
{
    PushNotification findById(PushNotificationId id);
    PushNotification[] findByApp(MobileAppId appId);
    PushNotification[] findByStatus(MobileAppId appId, PushStatus status);
    PushNotification[] findScheduled(MobileAppId appId);
    void save(PushNotification notification);
    void update(PushNotification notification);
    void remove(PushNotificationId id);
}
