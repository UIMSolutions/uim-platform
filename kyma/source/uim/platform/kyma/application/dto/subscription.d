module uim.platform.kyma.application.dto.subscription;
import uim.platform.kyma;

mixin(ShowModule!());

@safe:
struct CreateEventSubscriptionRequest {
  TenantId tenantId;
  NamespaceId namespaceId;
  KymaEnvironmentId environmentId;
  string name;
  string description;
  string source;
  string[] eventTypes;
  string typeEncoding; // "exact", "prefix"
  string sinkUrl;
  string sinkServiceName;
  int sinkServicePort;
  int maxInFlightMessages;
  bool exactTypeMatching;
  string[string] filterAttributes;
  string[string] labels;
  string createdBy;
}

struct UpdateEventSubscriptionRequest {
  string description;
  string[] eventTypes;
  string sinkUrl;
  string sinkServiceName;
  int sinkServicePort;
  int maxInFlightMessages;
  bool exactTypeMatching;
  string[string] filterAttributes;
  string[string] labels;
}