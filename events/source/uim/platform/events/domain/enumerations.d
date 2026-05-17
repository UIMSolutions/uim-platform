module uim.platform.events.domain.enumerations;

enum MessagingServiceStatus { creating, active, inactive, updating, deleting, failed }
enum MessagingServicePlan   { dev, standard, premium }

enum MessageClientStatus   { active, inactive, suspended }
enum MessageClientProtocol { amqp10, mqtt311, mqtt500, httprest }

enum QueueStatus     { active, inactive, pendingDelete }
enum QueueAccessType { exclusive, nonExclusive }

enum QueueSubscriptionStatus { active, inactive, pendingDelete }

enum WebhookStatus       { active, paused, inactive, failed }
enum WebhookAuthType     { none_, oauth2, basic, apiKey }
enum WebhookDeliveryMode { atLeastOnce, atMostOnce }

enum EventChannelStatus { active, inactive, deprecated_ }
enum EventChannelType   { queue, topic, eventChannel }

enum MessageBindingStatus     { active, inactive }
enum MessageBindingPermission { publish, subscribe, manage, publishSubscribe }
