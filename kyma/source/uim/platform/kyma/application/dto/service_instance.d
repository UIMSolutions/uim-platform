module uim.platform.kyma.application.dto.service_instance;
import uim.platform.kyma;

mixin(ShowModule!());

@safe:
struct CreateServiceInstanceRequest {
    NamespaceId namespaceId;
    KymaEnvironmentId environmentId;
    TenantId tenantId;
    string name;
    string description;
    string serviceOfferingName;
    string servicePlanName;
    string servicePlanId;
    string externalName;
    string parametersJson;
    string[string] labels;
    string createdBy;
}

struct UpdateServiceInstanceRequest {
    string description;
    string servicePlanName;
    string servicePlanId;
    string parametersJson;
    string[string] labels;
}
