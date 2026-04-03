module uim.platform.cloud_foundry.domain.entities.service_instance;

import uim.platform.cloud_foundry.domain.types;

/// A service instance — a provisioned instance of a marketplace service
/// (e.g. XSUAA, HANA, Destination Service) within a space.
struct ServiceInstance
{
  ServiceInstanceId id;
  SpaceId spaceId;
  TenantId tenantId;
  string name;
  string serviceName;                 // e.g. "xsuaa", "hana", "destination"
  string servicePlanName;             // e.g. "lite", "standard", "application"
  ServiceInstanceStatus status = ServiceInstanceStatus.creating;
  string parameters;                  // JSON string of creation parameters
  string dashboardUrl;
  string tags;                        // comma-separated tags
  string createdBy;
  long createdAt;
  long updatedAt;
}
