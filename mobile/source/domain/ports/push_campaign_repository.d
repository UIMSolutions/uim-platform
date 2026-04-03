module uim.platform.mobile.domain.ports.push_campaign_repository;

import uim.platform.mobile.domain.entities.push_campaign;
import uim.platform.mobile.domain.types;

/// Port: outgoing — push campaign persistence.
interface PushCampaignRepository
{
    PushCampaign findById(PushCampaignId id);
    PushCampaign[] findByApp(MobileAppId appId);
    PushCampaign[] findByStatus(MobileAppId appId, CampaignStatus status);
    void save(PushCampaign campaign);
    void update(PushCampaign campaign);
    void remove(PushCampaignId id);
}
