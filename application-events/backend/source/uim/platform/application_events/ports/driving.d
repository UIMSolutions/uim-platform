/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// The complete set of driving ports — what every adapter (REST, OData,
/// CLI, GUI, workers) may call.
module uim.platform.application_events.ports.driving;

import uim.platform.application_events;

mixin(ShowModule!());

@safe:

struct AehPorts {
  IManageFormations formations;
  IManageSystems systems;
  IManageTopics topics;
  IManageChannels channels;
  IManageSubscriptions subscriptions;
  IManageFilters filters;
  IPublishEvents publishing;
  IDeliverMessages delivery;
  IManageDeadLetters deadLetters;
  IAehStatisticsService statistics;
  IAuthenticate authentication;
  IManageUsers users;
}
