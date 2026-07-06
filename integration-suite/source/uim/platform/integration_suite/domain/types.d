module uim.platform.integration_suite.domain.types;
import uim.platform.integration_suite;

mixin(ShowModule!());
@safe:

struct IntegrationPackageId {
  mixin(IdTemplate);
}

struct IntegrationFlowId {
  mixin(IdTemplate);
}

struct ApiProxyId {
  mixin(IdTemplate);
}

struct ApiProductId {
  mixin(IdTemplate);
}

struct MessageQueueId {
  mixin(IdTemplate);
}

struct TopicSubscriptionId {
  mixin(IdTemplate);
}

struct TradingPartnerId {
  mixin(IdTemplate);
}

struct MessageMappingId {
  mixin(IdTemplate);
}

struct IntegrationUserId {
  mixin(IdTemplate);
}
