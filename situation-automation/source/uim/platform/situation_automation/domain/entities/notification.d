/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.situation_automation.domain.entities.notification;

// import uim.platform.situation_automation.domain.types;
import uim.platform.situation_automation;

mixin(ShowModule!());

@safe:
struct Notification {
    mixin TenantEntity!(NotificationId);

    SituationInstanceId instanceId;
    string recipientId;
    string title;
    string message;
    NotificationChannel channel;
    NotificationStatus status;
    NotificationPriority priority;
    string actionUrl;
    long sentAt;
    long readAt;

    Json toJson() const {
        auto j = entityToJson
            .set("instanceId", instanceId.value)
            .set("recipientId", recipientId)
            .set("title", title)
            .set("message", message)
            .set("channel", channel.toString())
            .set("status", status.toString())
            .set("priority", priority.toString())
            .set("actionUrl", actionUrl)
            .set("sentAt", sentAt)
            .set("readAt", readAt);

        return j;
    }
}
