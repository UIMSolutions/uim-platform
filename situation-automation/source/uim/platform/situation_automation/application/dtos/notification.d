module uim.platform.situation_automation.application.dtos.notification;

struct CreateNotificationRequest {
    TenantId tenantId;
    string instanceId;
    string id;
    string recipientId;
    string title;
    string message;
    string channel;
    string priority;
    string actionUrl;
}

struct UpdateNotificationRequest {
    TenantId tenantId;
    string id;
    string status;
}