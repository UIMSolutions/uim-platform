module uim.platform.identity_authentication.application.usecases.delegated_auth;

// import uim.platform.identity_authentication.domain.entities.idp_config;
// import uim.platform.identity_authentication.domain.entities.user;
// import uim.platform.identity_authentication.domain.types;
// import uim.platform.identity_authentication.domain.ports.idp_config;
// import uim.platform.identity_authentication.domain.ports.user;
// 
// // import std.string : split;
import uim.platform.identity_authentication;

mixin(ShowModule!());
@safe:
/// Application use case: delegate authentication to an external IdP.
class DelegatedAuthUseCase
{
    private IdpConfigRepository idpRepo;
    private UserRepository userRepo;

    this(IdpConfigRepository idpRepo, UserRepository userRepo)
    {
        this.idpRepo = idpRepo;
        this.userRepo = userRepo;
    }

    /// Determine which IdP to redirect to, based on email domain or default.
    IdpConfig resolveIdp(TenantId tenantId, string email)
    {
        // Extract domain from email
        auto parts = email.split("@");
        if (parts.length == 2)
        {
            auto idp = idpRepo.findByDomainHint(tenantId, parts[1]);
            if (idp != IdpConfig.init)
                return idp;
        }

        // Fallback to default IdP
        return idpRepo.findDefaultForTenant(tenantId);
    }

    /// Build the authorization URL for the external IdP.
    string buildAuthorizationUrl(IdpConfig idp, string redirectUri, string state)
    {
        if (idp == IdpConfig.init)
            return "";

        return idp.authorizationEndpoint
            ~ "?client_id=" ~ idp.clientId
            ~ "&redirect_uri=" ~ redirectUri
            ~ "&response_type=code"
            ~ "&state=" ~ state;
    }

    /// List all configured IdPs for a tenant.
    IdpConfig[] listIdps(TenantId tenantId)
    {
        return idpRepo.findByTenant(tenantId);
    }
}
