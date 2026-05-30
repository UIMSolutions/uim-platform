module uim.platform.integration_suite.application.usecases.manage_topic_subscriptions;
import uim.platform.integration_suite;

mixin(ShowModule!());
@safe:

class ManageTopicSubscriptionsUseCase {
private:
  TopicSubscriptionRepository _repo;

public:
  this(TopicSubscriptionRepository repo) { _repo = repo; }

  CommandResult create(CreateSubscriptionRequest req) {
    auto sub = TopicSubscription();
    initEntity(sub, req.tenantId, req.id);
    sub.name         = req.name;
    sub.queueId      = MessageQueueId(req.queueId);
    sub.topicPattern = req.topicPattern;
    sub.status       = SubscriptionStatus.active;
    sub.protocol     = req.protocol;
    sub.endpoint     = req.endpoint;
    sub.metadata     = req.metadata;
    auto err = IntegrationValidator.validateTopicSubscription(sub);
    if (err !is null) return CommandResult(false, err);
    _repo.add(getTenantId(req.tenantId), sub);
    return CommandResult(true, sub.toJson());
  }

  CommandResult getAll(TenantId tenantId) {
    auto items = _repo.getAll(getTenantId(tenantId));
    auto arr = Json.emptyArray;
    foreach (s; items) arr ~= s.toJson();
    return CommandResult(true, arr);
  }

  CommandResult getById(TenantId tenantId, string id) {
    auto sub = _repo.getById(getTenantId(tenantId), TopicSubscriptionId(id));
    if (sub.isNull) return CommandResult(false, "Subscription not found");
    return CommandResult(true, sub.toJson());
  }

  CommandResult listByQueue(TenantId tenantId, string queueId) {
    auto items = _repo.findByQueue(getTenantId(tenantId), MessageQueueId(queueId));
    auto arr = Json.emptyArray;
    foreach (s; items) arr ~= s.toJson();
    return CommandResult(true, arr);
  }

  CommandResult update(UpdateSubscriptionRequest req) {
    auto sub = _repo.getById(getTenantId(req.tenantId), TopicSubscriptionId(req.id));
    if (sub.isNull) return CommandResult(false, "Subscription not found");
    if (req.status.length > 0)       sub.status       = req.status.to!SubscriptionStatus;
    if (req.topicPattern.length > 0) sub.topicPattern = req.topicPattern;
    if (req.endpoint.length > 0)     sub.endpoint     = req.endpoint;
    foreach (k, v; req.metadata)     sub.metadata[k]  = v;
    _repo.update(getTenantId(req.tenantId), sub);
    return CommandResult(true, sub.toJson());
  }

  CommandResult remove(TenantId tenantId, string id) {
    auto sub = _repo.getById(getTenantId(tenantId), TopicSubscriptionId(id));
    if (sub.isNull) return CommandResult(false, "Subscription not found");
    _repo.remove(getTenantId(tenantId), TopicSubscriptionId(id));
    return CommandResult(true, "Subscription deleted");
  }
}
