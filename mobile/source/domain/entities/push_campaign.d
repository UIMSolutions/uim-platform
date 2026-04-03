module uim.platform.mobile.domain.entities.push_campaign;

import uim.platform.mobile.domain.types;

/// A push notification campaign targeting segments over time.
struct PushCampaign
{
    PushCampaignId id;
    MobileAppId appId;
    TenantId tenantId;
    string name;
    string description;
    PushTemplateId templateId;
    CampaignStatus status = CampaignStatus.draft;
    string targetSegment;           // user segment expression
    MobilePlatform[] targetPlatforms;
    long scheduledStartAt;
    long scheduledEndAt;
    int sentCount;
    int deliveredCount;
    int openedCount;
    int failedCount;
    string[string] templateVariables;
    string createdBy;
    long createdAt;
    long updatedAt;
}
