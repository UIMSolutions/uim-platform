module uim.platform.connectivity.application.usecases.manage_destinations;

// import uim.platform.connectivity.application.dto;
// import uim.platform.connectivity.domain.entities.destination;
// import uim.platform.connectivity.domain.ports.destination_repository;
// import uim.platform.connectivity.domain.ports.connectivity_log_repository;
// import uim.platform.connectivity.domain.services.auth_flow_resolver;
// import uim.platform.connectivity.domain.types;
// 
// import std.conv : to;
import uim.platform.connectivity;

mixin(ShowModule!());

@safe:
/// Application service for destination CRUD and lookup.
class ManageDestinationsUseCase
{
    private DestinationRepository repo;
    private ConnectivityLogRepository logRepo;

    this(DestinationRepository repo, ConnectivityLogRepository logRepo)
    {
        this.repo = repo;
        this.logRepo = logRepo;
    }

    CommandResult createDestination(CreateDestinationRequest req)
    {
        // Validate unique name within tenant
        auto existing = repo.findByName(req.tenantId, req.name);
        if (existing.id.length > 0)
            return CommandResult(false, "", "Destination with name '" ~ req.name ~ "' already exists");

        if (req.name.length == 0)
            return CommandResult(false, "", "Destination name is required");
        if (req.url.length == 0)
            return CommandResult(false, "", "Destination URL is required");

        import std.uuid : randomUUID;
        auto id = randomUUID().toString();

        Destination dest;
        dest.id = id;
        dest.tenantId = req.tenantId;
        dest.name = req.name;
        dest.description = req.description;
        dest.url = req.url;
        dest.destinationType = parseDestinationType(req.destinationType);
        dest.authType = parseAuthType(req.authType);
        dest.proxyType = parseProxyType(req.proxyType);
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
        if (!authResult.valid)
        {
            string msg = "Auth validation failed: ";
            foreach (i, e; authResult.errors)
            {
                if (i > 0) msg ~= "; ";
                msg ~= e;
            }
            return CommandResult(false, "", msg);
        }

        repo.save(dest);
        return CommandResult(true, id, "");
    }

    CommandResult updateDestination(DestinationId id, UpdateDestinationRequest req)
    {
        auto dest = repo.findById(id);
        if (dest.id.length == 0)
            return CommandResult(false, "", "Destination not found");

        if (req.description.length > 0) dest.description = req.description;
        if (req.url.length > 0) dest.url = req.url;
        if (req.authType.length > 0) dest.authType = parseAuthType(req.authType);
        if (req.proxyType.length > 0) dest.proxyType = parseProxyType(req.proxyType);
        if (req.user.length > 0) dest.user = req.user;
        if (req.password.length > 0) dest.password = req.password;
        if (req.clientId.length > 0) dest.clientId = req.clientId;
        if (req.clientSecret.length > 0) dest.clientSecret = req.clientSecret;
        if (req.tokenServiceUrl.length > 0) dest.tokenServiceUrl = req.tokenServiceUrl;
        if (req.tokenServiceUser.length > 0) dest.tokenServiceUser = req.tokenServiceUser;
        if (req.tokenServicePassword.length > 0) dest.tokenServicePassword = req.tokenServicePassword;
        if (req.certificateId.length > 0) dest.certificateId = req.certificateId;
        if (req.cloudConnectorLocationId.length > 0) dest.cloudConnectorLocationId = req.cloudConnectorLocationId;
        if (req.properties.length > 0) dest.properties = req.properties;
        if (req.additionalHeaders.length > 0) dest.additionalHeaders = req.additionalHeaders;

        auto authResult = AuthFlowResolver.validate(dest);
        if (!authResult.valid)
        {
            string msg = "Auth validation failed: ";
            foreach (i, e; authResult.errors)
            {
                if (i > 0) msg ~= "; ";
                msg ~= e;
            }
            return CommandResult(false, "", msg);
        }

        repo.update(dest);
        return CommandResult(true, id, "");
    }

    Destination getDestination(DestinationId id)
    {
        return repo.findById(id);
    }

    Destination getByName(TenantId tenantId, string name)
    {
        return repo.findByName(tenantId, name);
    }

    Destination[] listDestinations(TenantId tenantId)
    {
        return repo.findByTenant(tenantId);
    }

    CommandResult deleteDestination(DestinationId id)
    {
        auto dest = repo.findById(id);
        if (dest.id.length == 0)
            return CommandResult(false, "", "Destination not found");

        repo.remove(id);
        return CommandResult(true, id, "");
    }
}

private DestinationType parseDestinationType(string s)
{
    switch (s)
    {
    case "http": return DestinationType.http;
    case "rfc": return DestinationType.rfc;
    case "mail": return DestinationType.mail;
    case "ldap": return DestinationType.ldap;
    default: return DestinationType.http;
    }
}

private AuthenticationType parseAuthType(string s)
{
    switch (s)
    {
    case "noAuthentication": return AuthenticationType.noAuthentication;
    case "basicAuthentication": return AuthenticationType.basicAuthentication;
    case "oauth2ClientCredentials": return AuthenticationType.oauth2ClientCredentials;
    case "oauth2SAMLBearerAssertion": return AuthenticationType.oauth2SAMLBearerAssertion;
    case "oauth2UserTokenExchange": return AuthenticationType.oauth2UserTokenExchange;
    case "oauth2JWTBearer": return AuthenticationType.oauth2JWTBearer;
    case "oauth2Password": return AuthenticationType.oauth2Password;
    case "oauth2AuthorizationCode": return AuthenticationType.oauth2AuthorizationCode;
    case "clientCertificateAuthentication": return AuthenticationType.clientCertificateAuthentication;
    case "principalPropagation": return AuthenticationType.principalPropagation;
    case "samlAssertion": return AuthenticationType.samlAssertion;
    default: return AuthenticationType.noAuthentication;
    }
}

private ProxyType parseProxyType(string s)
{
    switch (s)
    {
    case "internet": return ProxyType.internet;
    case "onPremise": return ProxyType.onPremise;
    case "privateLink": return ProxyType.privateLink;
    default: return ProxyType.internet;
    }
}
