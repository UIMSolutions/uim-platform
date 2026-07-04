module uim.platform.integration_suite.domain.types;
import uim.platform.integration_suite;
mixin(ShowModule!());
@safe:

struct IntegrationPackageId { string value; mixin IdTemplate; }
struct IntegrationFlowId    { string value; mixin IdTemplate; }
struct ApiProxyId           { string value; mixin IdTemplate; }
struct ApiProductId         { string value; mixin IdTemplate; }
struct MessageQueueId       { string value; mixin IdTemplate; }
struct TopicSubscriptionId  { string value; mixin IdTemplate; }
struct TradingPartnerId     { string value; mixin IdTemplate; }
struct MessageMappingId     { string value; mixin IdTemplate; }
struct IntegrationUserId    { string value; mixin IdTemplate; }
