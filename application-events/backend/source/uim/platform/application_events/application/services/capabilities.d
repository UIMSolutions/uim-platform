/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// What the service supports (GET <api>/capabilities).
module uim.platform.application_events.application.services.capabilities;

import uim.platform.application_events;

mixin(ShowModule!());

@safe:

Json capabilitiesJson(string deliveryMode, const AehPolicy policy) {
  Json texts(const string[] values) {
    auto a = Json.emptyArray;
    foreach (v; values)
      a ~= Json(v);
    return a;
  }

  auto j = Json.emptyObject;
  j["apiVersion"] = "v1";
  j["cloudEvents"] = cloudEventsSpecVersion;
  j["contentModes"] = texts(["structured", "batch"]);
  j["deliveryGateway"] = deliveryMode;
  j["requireRegisteredTopics"] = policy.requireRegisteredTopics;
  j["deliverOnPublish"] = policy.deliverOnPublish;
  j["maxPayloadBytes"] = policy.maxPayloadBytes;
  j["maxBatchEvents"] = policy.maxBatchEvents;
  j["maxRetries"] = maxRetriesLimit;
  j["retryBackoffSeconds"] = Json(["min": Json(minBackoffSeconds), "max": Json(maxBackoffSeconds), "default": Json(30),
      "cap": Json(policy.maxBackoffSeconds)]);
  j["messageRetentionHours"] = policy.messageRetentionHours;
  j["deadLetterRetentionDays"] = policy.deadLetterRetentionDays;
  j["eventTypePatterns"] = "'*' matches one segment; a trailing '*' matches the rest; '*' alone matches everything";
  j["filterAttributes"] = texts(envelopeAttributes ~ ["data.<member>[.<member>…]"]);
  j["systemTypes"] = texts(domainEnumValues!SystemType);
  j["topicStatuses"] = texts(domainEnumValues!TopicStatus);
  j["channelTypes"] = texts(domainEnumValues!ChannelType);
  j["channelStatuses"] = texts(domainEnumValues!ChannelStatus);
  j["deliveryModes"] = texts(domainEnumValues!DeliveryMode);
  j["subscriptionStatuses"] = texts(domainEnumValues!SubscriptionStatus);
  j["filterTypes"] = texts(domainEnumValues!FilterType);
  j["filterOperators"] = texts(domainEnumValues!EventFilterOperator);
  j["messageStatuses"] = texts(domainEnumValues!MessageStatus);
  j["deadLetterStatuses"] = texts(domainEnumValues!DeadLetterStatus);
  j["scopes"] = texts(knownScopes);
  return j;
}

///
unittest {
  auto j = capabilitiesJson("simulate", AehPolicy.init);
  assert(j["messageStatuses"].length == 6 && j["deliveryGateway"].get!string == "simulate");
}
