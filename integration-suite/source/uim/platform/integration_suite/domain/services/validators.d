module uim.platform.integration_suite.domain.services.validators;
import uim.platform.integration_suite;
mixin(ShowModule!());
@safe:

struct IntegrationValidator {

  static string validatePackage(IntegrationPackage p) {
    if (p.name.length == 0) return "Package name is required";
    return null;
  }

  static string validateFlow(IntegrationFlow f) {
    if (f.name.length == 0)              return "Flow name is required";
    if (f.packageId.value.length == 0)   return "Package ID is required";
    if (f.senderEndpoint.length == 0)    return "Sender endpoint is required";
    if (f.receiverEndpoint.length == 0)  return "Receiver endpoint is required";
    return null;
  }

  static string validateApiProxy(ApiProxy p) {
    if (p.name.length == 0)           return "API proxy name is required";
    if (p.targetEndpoint.length == 0) return "Target endpoint is required";
    if (p.basePath.length == 0)       return "Base path is required";
    return null;
  }

  static string validateApiProduct(ApiProduct p) {
    if (p.name.length == 0) return "API product name is required";
    return null;
  }

  static string validateMessageQueue(MessageQueue q) {
    if (q.name.length == 0) return "Queue name is required";
    return null;
  }

  static string validateTopicSubscription(TopicSubscription s) {
    if (s.name.length == 0)         return "Subscription name is required";
    if (s.topicPattern.length == 0) return "Topic pattern is required";
    if (s.queueId.value.length == 0) return "Queue ID is required";
    return null;
  }

  static string validateTradingPartner(TradingPartner p) {
    if (p.name.length == 0) return "Partner name is required";
    return null;
  }

  static string validateMessageMapping(MessageMapping m) {
    if (m.name.length == 0)            return "Mapping name is required";
    if (m.packageId.value.length == 0) return "Package ID is required";
    return null;
  }

  static string validateUser(IntegrationUser u) {
    if (u.email.length == 0) return "Email is required";
    return null;
  }
}
