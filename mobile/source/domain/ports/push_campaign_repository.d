/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
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
