module uim.platform.integration_suite.domain.entities.topic_subscription;
import uim.platform.integration_suite;

mixin(ShowModule!());
@safe:

/// An Event Mesh topic subscription for event-driven integration.
struct TopicSubscription {
  mixin TenantEntity!(TopicSubscriptionId);

  MessageQueueId      queueId;
  string              name;
  string              topicPattern;
  SubscriptionStatus  status;
  string              protocol;
  string              endpoint;
  string[string]      metadata;

  Json toJson() const {
    auto j = entityToJson();
    j["queueId"]      = Json(queueId.value);
    j["name"]         = Json(name);
    j["topicPattern"] = Json(topicPattern);
    j["status"]       = Json(cast(string) status);
    j["protocol"]     = Json(protocol);
    j["endpoint"]     = Json(endpoint);
    j["metadata"]     = jsonKeyValuePairs(metadata);
    return j;
  }
}
