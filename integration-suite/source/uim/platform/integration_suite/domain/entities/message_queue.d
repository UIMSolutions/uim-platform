module uim.platform.integration_suite.domain.entities.message_queue;
import uim.platform.integration_suite;

mixin(ShowModule!());
@safe:

/// An Event Mesh message queue for reliable message delivery.
struct MessageQueue {
  mixin TenantEntity!(MessageQueueId);

  string        name;
  string        description;
  QueueStatus   status;
  int           maxMessageSize;   // bytes
  int           maxQueueSize;     // MB
  int           retentionPeriod;  // seconds
  bool          deadLetterQueue;
  string        deadLetterQueueName;
  string[string] metadata;

  Json toJson() const {
    auto j = entityToJson();
    j["name"]                 = Json(name);
    j["description"]          = Json(description);
    j["status"]               = Json(cast(string) status);
    j["maxMessageSize"]       = Json(maxMessageSize);
    j["maxQueueSize"]         = Json(maxQueueSize);
    j["retentionPeriod"]      = Json(retentionPeriod);
    j["deadLetterQueue"]      = Json(deadLetterQueue);
    j["deadLetterQueueName"]  = Json(deadLetterQueueName);
    j["metadata"]             = jsonKeyValuePairs(metadata);
    return j;
  }
}
