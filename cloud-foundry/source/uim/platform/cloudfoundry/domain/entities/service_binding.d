module domain.entities.service_binding;

import domain.types;

/// A service binding — connects an application to a service instance,
/// injecting credentials into the application's VCAP_SERVICES environment.
struct ServiceBinding
{
  ServiceBindingId id;
  AppId appId;
  ServiceInstanceId serviceInstanceId;
  TenantId tenantId;
  string name;
  BindingStatus status = BindingStatus.creating;
  string credentials;                 // JSON string of binding credentials
  string bindingOptions;              // JSON string of binding parameters
  string createdBy;
  long createdAt;
}
