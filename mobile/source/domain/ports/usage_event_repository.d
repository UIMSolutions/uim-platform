/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.mobile.domain.ports.usage_event_repository;

import uim.platform.mobile.domain.entities.usage_event;
import uim.platform.mobile.domain.types;

/// Port: outgoing — usage event persistence.
interface UsageEventRepository
{
  UsageEvent findById(UsageEventId id);
  UsageEvent[] findByApp(MobileAppId appId);
  UsageEvent[] findByUser(MobileAppId appId, string userId);
  UsageEvent[] findByType(MobileAppId appId, UsageEventType eventType);
  UsageEvent[] findByDevice(MobileAppId appId, string deviceId);
  void save(UsageEvent event);
  void remove(UsageEventId id);
}
