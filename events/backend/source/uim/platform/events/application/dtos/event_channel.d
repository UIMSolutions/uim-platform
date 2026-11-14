/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.events.application.dtos.event_channel;

import uim.platform.events;

mixin(ShowModule!());

@safe:

struct CreateEventChannelRequest {
  TenantId tenantId;
  UserId actor;
  string id; /// optional, generated if empty

  string serviceId;
  string name;
  string description;
  string channelType;
  string topicName;
  string asyncapiDefinition;
  int retentionHours;
  int partitions;
}

struct UpdateEventChannelRequest {
  TenantId tenantId;
  UserId actor;
  EventChannelId id;

  Patch!(string) name;
  Patch!(string) description;
  Patch!(string) status;
  Patch!(string) channelType;
  Patch!(string) asyncapiDefinition;
  Patch!(int) retentionHours;
  Patch!(int) partitions;
}
