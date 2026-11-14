/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.events.domain.entities.messaging_service;

import uim.platform.events;

mixin(ShowModule!());

@safe:

/// A messaging service instance (SAP Event Mesh "service descriptor"): owns
/// a namespace in which all of its topics, queues and channels live.
struct MessagingService {
  mixin TenantEntity!MessagingServiceId;

  string name;
  string description;
  string namespace; /// e.g. "acme/sales/orders"
  MessagingServiceStatus status = MessagingServiceStatus.active;
  MessagingServicePlan plan = MessagingServicePlan.standard;
  string region;
  int maxConnections; /// 0 = plan default
  int maxQueues; /// 0 = plan default
  int maxQueueDepth; /// messages per queue, 0 = plan default
  long maxMessageSize; /// bytes, 0 = plan default
  string tokenEndpoint;
  string messagingEndpoint;

  bool isActive() const {
    return status == MessagingServiceStatus.active;
  }

  void validate() const {
    requireText(name, "Messaging service name");
    if (!isValidNamespace(namespace))
      throw EventsException.invalid("Namespace '" ~ namespace ~ "' must look like 'org/app/service'");
    requireNonNegative(maxConnections, "maxConnections");
    requireNonNegative(maxQueues, "maxQueues");
    requireNonNegative(maxQueueDepth, "maxQueueDepth");
    requireNonNegative(maxMessageSize, "maxMessageSize");
    foreach (url; [tokenEndpoint, messagingEndpoint])
      if (url.length > 0 && !isHttpUrl(url))
        throw EventsException.invalid("Endpoint '" ~ url ~ "' must be an http(s) URL");
  }
}

///
unittest {
  MessagingService s;
  s.name = "orders";
  s.namespace = "acme/sales/orders";
  s.validate();
  s.namespace = "acme";
  assert(failsWith(EventsErrorKind.invalid, () { s.validate(); }));
}
