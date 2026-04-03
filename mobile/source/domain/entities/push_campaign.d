/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
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
  string targetSegment; // user segment expression
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
