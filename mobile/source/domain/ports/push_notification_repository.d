module uim.platform.xyz.domain.ports.push_notification_repository;

import domain.entities.push_notification;
import domain.types;

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
