module uim.platform.situation_automation.application.dtos.notification;
import uim.platform.situation_automation;

mixin(ShowModule!());

@safe:
struct CreateNotificationRequest {
    TenantId tenantId;
    SituationInstanceId situationInstanceId;
    NotificationId notificationId;
    UserId recipientId;
    string title;
    string message;
    string channel;
    string priority;
    string actionUrl;
}

struct UpdateNotificationRequest {
    TenantId tenantId;
    NotificationId notificationId;
    string status;
}