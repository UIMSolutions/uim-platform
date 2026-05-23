/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.connectivity.application.usecases.manage.destinations;
// import uim.platform.connectivity.application.dto;
// import uim.platform.connectivity.domain.entities.destination;
// import uim.platform.connectivity.domain.ports.repositories.destinations;
// import uim.platform.connectivity.domain.ports.repositories.connectivity_logs;
// import uim.platform.connectivity.domain.services.auth_flow_resolver;
// import uim.platform.connectivity.domain.types;
// 
// 
import uim.platform.connectivity;

mixin(ShowModule!());

@safe:
/// Application service for destination CRUD and lookup.
class ManageDestinationsUseCase { // TODO: UIMUseCase {
  private DestinationRepository destinations;
  private ConnectivityLogRepository logs;

  this(DestinationRepository destinations, ConnectivityLogRepository logs) {
    this.destinations = destinations;
    this.logs = logs;
  }

  CommandResult createDestination(CreateDestinationRequest req) {
    // Validate unique name within tenant
    auto existing = destinations.findByName(req.tenantId, req.name);
    if (!existing.isNull)
      return CommandResult(false, "", "Destination with name '" ~ req.name ~ "' already exists");

    if (req.name.length == 0)
      return CommandResult(false, "", "Destination name is required");
    if (req.url.length == 0)
      return CommandResult(false, "", "Destination URL is required");

   

    Destination dest;
    dest.initEntity(req.tenantId);
    dest.name = req.name;
    dest.description = req.description;
    dest.url = req.url;
    dest.destinationType = req.destinationType.to!DestinationType;
    dest.authType = req.authType.to!AuthenticationType;
    dest.proxyType = req.proxyType.to!ProxyType;
    dest.user = req.user;
    dest.password = req.password;
    dest.clientId = req.clientId;
    dest.clientSecret = req.clientSecret;
    dest.tokenServiceUrl = req.tokenServiceUrl;
    dest.tokenServiceUser = req.tokenServiceUser;
    dest.tokenServicePassword = req.tokenServicePassword;
    dest.certificateId = req.certificateId;
    dest.cloudConnectorLocationId = req.cloudConnectorLocationId;
    dest.properties = req.properties;
    dest.additionalHeaders = req.additionalHeaders;

    // Validate auth configuration
    auto authResult = AuthFlowResolver.validate(dest);
    if (!authResult.valid) {
      string msg = "Auth validation failed: ";
      foreach (i, error; authResult.errors) {
        if (i > 0)
          msg ~= "; ";
        msg ~= error;
      }
      return CommandResult(false, "", msg);
    }

    destinations.save(dest);
    return CommandResult(true, dest.id.value, "");
  }

  CommandResult updateDestination(UpdateDestinationRequest req) {
    auto dest = destinations.findById(req.tenantId, req.destinationId);
    if (dest.isNull)
      return CommandResult(false, "", "Destination not found");

    if (req.description.length > 0)
      dest.description = req.description;
    if (req.url.length > 0)
      dest.url = req.url;
    if (req.authType.length > 0)
      dest.authType = req.authType.to!AuthenticationType;
    if (req.proxyType.length > 0)
      dest.proxyType = req.proxyType.to!ProxyType;
    if (req.user.length > 0)
      dest.user = req.user;
    if (req.password.length > 0)
      dest.password = req.password;
    if (req.clientId.length > 0)
      dest.clientId = req.clientId;
    if (req.clientSecret.length > 0)
      dest.clientSecret = req.clientSecret;
    if (req.tokenServiceUrl.length > 0)
      dest.tokenServiceUrl = req.tokenServiceUrl;
    if (req.tokenServiceUser.length > 0)
      dest.tokenServiceUser = req.tokenServiceUser;
    if (req.tokenServicePassword.length > 0)
      dest.tokenServicePassword = req.tokenServicePassword;
    if (req.certificateId.length > 0)
      dest.certificateId = req.certificateId;
    if (req.cloudConnectorLocationId.length > 0)
      dest.cloudConnectorLocationId = req.cloudConnectorLocationId;
    if (req.properties.length > 0)
      dest.properties = req.properties;
    if (req.additionalHeaders.length > 0)
      dest.additionalHeaders = req.additionalHeaders;

    auto authResult = AuthFlowResolver.validate(dest);
    if (!authResult.valid) {
      string msg = "Auth validation failed: ";
      foreach (i, error; authResult.errors) {
        if (i > 0)
          msg ~= "; ";
        msg ~= error;
      }
      return CommandResult(false, "", msg);
    }

    destinations.update(dest);
    return CommandResult(true, dest.id.value, "");
  }

  Destination getDestination(TenantId tenantId, DestinationId id) {
    return destinations.findById(tenantId, id);
  }

  Destination getByName(TenantId tenantId, string name) {
    return destinations.findByName(tenantId, name);
  }

  Destination[] listDestinations(TenantId tenantId) {
    return destinations.findByTenant(tenantId);
  }

  CommandResult deleteDestination(TenantId tenantId, DestinationId id) {
    auto dest = destinations.findById(tenantId, id);
    if (dest.isNull)
      return CommandResult(false, "", "Destination not found");

    destinations.remove(dest);
    return CommandResult(true, dest.id.value, "");
  }
}
