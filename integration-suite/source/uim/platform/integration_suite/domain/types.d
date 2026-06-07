module uim.platform.integration_suite.domain.types;
import uim.platform.integration_suite;
// mixin(ShowModule!());
@safe:

struct IntegrationPackageId { string value; mixin DomainId; }
struct IntegrationFlowId    { string value; mixin DomainId; }
struct ApiProxyId           { string value; mixin DomainId; }
struct ApiProductId         { string value; mixin DomainId; }
struct MessageQueueId       { string value; mixin DomainId; }
struct TopicSubscriptionId  { string value; mixin DomainId; }
struct TradingPartnerId     { string value; mixin DomainId; }
struct MessageMappingId     { string value; mixin DomainId; }
struct IntegrationUserId    { string value; mixin DomainId; }
