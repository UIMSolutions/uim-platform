/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// The complete set of driving ports — what every adapter (REST, OData, CLI, GUI, workers) may call.
module uim.platform.events.ports.driving;

import uim.platform.events;

mixin(ShowModule!());

@safe:

struct EventsPorts {
  IManageMessagingServices services;
  IManageMessageClients clients;
  IManageQueues queues;
  IManageQueueSubscriptions subscriptions;
  IManageWebhooks webhooks;
  IManageEventChannels channels;
  IManageMessageBindings bindings;
  IPublishEvents publisher;
  IConsumeMessages consumer;
  IDeliverWebhooks delivery;
  IEventsStatistics statistics;
}
