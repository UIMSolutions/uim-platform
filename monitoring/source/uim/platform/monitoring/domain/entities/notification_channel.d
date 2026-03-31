module domain.entities.notification_channel;

import domain.types;

/// A notification channel for delivering alert notifications.
struct NotificationChannel
{
    NotificationChannelId id;
    TenantId tenantId;
    string name;
    string description;
    ChannelType channelType = ChannelType.email;
    ChannelState state = ChannelState.active;

    /// For email channels.
    string[] emailRecipients;
    string emailSubjectPrefix;

    /// For webhook channels.
    string webhookUrl;
    string webhookSecret;
    string webhookMethod;

    /// For on-premise channels.
    string onPremiseHost;
    int onPremisePort;
    string onPremiseProtocol;

    string createdBy;
    long createdAt;
    long updatedAt;
}
