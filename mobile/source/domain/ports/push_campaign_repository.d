module uim.platform.xyz.domain.ports.push_campaign_repository;

import domain.entities.push_campaign;
import domain.types;

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
