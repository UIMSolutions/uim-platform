module uim.platform.destination.application.usecases.manage_destinations;

import uim.platform.destination.application.dto;
import uim.platform.destination.domain.entities.destination;
import uim.platform.destination.domain.ports.destination_repository;
import uim.platform.destination.domain.services.destination_resolver;
import uim.platform.destination.domain.types;

// import std.conv : to;

/// Application service for destination CRUD operations.
class ManageDestinationsUseCase
{
    private DestinationRepository repo;

    this(DestinationRepository repo)
    {
        this.repo = repo;
    }

    CommandResult create(CreateDestinationRequest req)
    {
        if (req.name.length == 0)
            return CommandResult(false, "", "Destination name is required");

        if (req.url.length == 0 && req.destinationType != "rfc")
            return CommandResult(false, "", "URL is required for non-RFC destinations");

        auto existing = repo.findByName(req.tenantId, req.subaccountId, req.name);
        if (existing.id.length > 0)
            return CommandResult(false, "", "Destination '" ~ req.name ~ "' already exists in this subaccount");

        // import std.uuid : randomUUID;
        auto id = randomUUID().toString();

        Destination d;
        d.id = id;
        d.tenantId = req.tenantId;
        d.subaccountId = req.subaccountId;
        d.serviceInstanceId = req.serviceInstanceId;
        d.name = req.name;
        d.description = req.description;
        d.destinationType = parseDestType(req.destinationType);
        d.url = req.url;
        d.authenticationType = DestinationResolver.parseAuthType(req.authenticationType);
        d.proxyType = DestinationResolver.parseProxyType(req.proxyType);
        d.level = parseLevel(req.level);
        d.status = DestinationStatus.active;

        d.urlPath = req.urlPath;
        d.httpMethod = req.httpMethod;

        d.user = req.user;
        d.password = req.password;
        d.clientId = req.clientId;
        d.clientSecret = req.clientSecret;
        d.tokenServiceUrl = req.tokenServiceUrl;
        d.tokenServiceUser = req.tokenServiceUser;
        d.tokenServicePassword = req.tokenServicePassword;
        d.audience = req.audience;
        d.systemUser = req.systemUser;
        d.samlAudience = req.samlAudience;
        d.nameIdFormat = req.nameIdFormat;
        d.authnContextClassRef = req.authnContextClassRef;

        d.keystoreId = req.keystoreId;
        d.keystorePassword = req.keystorePassword;
        d.truststoreId = req.truststoreId;

        d.locationId = req.locationId;
        d.sccVirtualHost = req.sccVirtualHost;
        d.sccVirtualPort = cast(ushort) req.sccVirtualPort;

        d.properties = req.properties;
        d.fragmentIds = req.fragmentIds;
        d.createdBy = req.createdBy;
        d.createdAt = clockSeconds();
        d.modifiedAt = d.createdAt;

        repo.save(d);
        return CommandResult(true, id, "");
    }

    CommandResult updateDestination(DestinationId id, UpdateDestinationRequest req)
    {
        auto d = repo.findById(id);
        if (d.id.length == 0)
            return CommandResult(false, "", "Destination not found");

        if (req.description.length > 0) d.description = req.description;
        if (req.url.length > 0) d.url = req.url;
        if (req.authenticationType.length > 0) d.authenticationType = DestinationResolver.parseAuthType(req.authenticationType);
        if (req.proxyType.length > 0) d.proxyType = DestinationResolver.parseProxyType(req.proxyType);
        if (req.user.length > 0) d.user = req.user;
        if (req.password.length > 0) d.password = req.password;
        if (req.clientId.length > 0) d.clientId = req.clientId;
        if (req.clientSecret.length > 0) d.clientSecret = req.clientSecret;
        if (req.tokenServiceUrl.length > 0) d.tokenServiceUrl = req.tokenServiceUrl;
        if (req.tokenServiceUser.length > 0) d.tokenServiceUser = req.tokenServiceUser;
        if (req.tokenServicePassword.length > 0) d.tokenServicePassword = req.tokenServicePassword;
        if (req.audience.length > 0) d.audience = req.audience;
        if (req.keystoreId.length > 0) d.keystoreId = req.keystoreId;
        if (req.keystorePassword.length > 0) d.keystorePassword = req.keystorePassword;
        if (req.truststoreId.length > 0) d.truststoreId = req.truststoreId;
        if (req.locationId.length > 0) d.locationId = req.locationId;
        if (req.sccVirtualHost.length > 0) d.sccVirtualHost = req.sccVirtualHost;
        if (req.sccVirtualPort > 0) d.sccVirtualPort = cast(ushort) req.sccVirtualPort;
        if (req.status.length > 0) d.status = parseDestStatus(req.status);
        if (req.properties.length > 0) d.properties = req.properties;
        if (req.fragmentIds.length > 0) d.fragmentIds = req.fragmentIds;
        d.modifiedAt = clockSeconds();

        repo.update(d);
        return CommandResult(true, id, "");
    }

    Destination getDestination(DestinationId id)
    {
        return repo.findById(id);
    }

    Destination[] listBySubaccount(TenantId tenantId, SubaccountId subaccountId)
    {
        return repo.findBySubaccount(tenantId, subaccountId);
    }

    Destination[] listByServiceInstance(TenantId tenantId, ServiceInstanceId instanceId)
    {
        return repo.findByServiceInstance(tenantId, instanceId);
    }

    Destination findByName(TenantId tenantId, SubaccountId subaccountId, string name)
    {
        return repo.findByName(tenantId, subaccountId, name);
    }

    CommandResult removeDestination(DestinationId id)
    {
        auto d = repo.findById(id);
        if (d.id.length == 0)
            return CommandResult(false, "", "Destination not found");
        repo.remove(id);
        return CommandResult(true, id, "");
    }

    private static long clockSeconds()
    {
        // import std.datetime.systime : Clock;
        return Clock.currTime().toUnixTime();
    }

    private static DestinationType parseDestType(string s)
    {
        switch (s)
        {
            case "rfc":     return DestinationType.rfc;
            case "mail":    return DestinationType.mail;
            case "ldap":    return DestinationType.ldap;
            default:        return DestinationType.http;
        }
    }

    private static DestinationLevel parseLevel(string s)
    {
        switch (s)
        {
            case "serviceInstance":  return DestinationLevel.serviceInstance;
            default:                 return DestinationLevel.subaccount;
        }
    }

    private static DestinationStatus parseDestStatus(string s)
    {
        switch (s)
        {
            case "inactive": return DestinationStatus.inactive;
            case "error":    return DestinationStatus.error;
            default:         return DestinationStatus.active;
        }
    }
}
