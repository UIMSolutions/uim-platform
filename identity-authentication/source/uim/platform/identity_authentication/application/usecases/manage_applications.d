module uim.platform.identity_authentication.application.usecases.manage_applications;

// import uim.platform.identity_authentication.domain.entities.application;
// import uim.platform.identity_authentication.domain.types;
// import uim.platform.identity_authentication.domain.ports.application;
// import uim.platform.identity_authentication.application.dto;
// 
// import std.uuid;
// import std.datetime.systime : Clock;

import uim.platform.identity_authentication;
mixin(ShowModule!());
@safe:
/// Application use case: service provider / application registration.
class ManageApplicationsUseCase {
    private ApplicationRepository appRepo;

    this(ApplicationRepository appRepo) {
        this.appRepo = appRepo;
    }

    AppResponse createApplication(CreateAppRequest req) {
        auto now = Clock.currStdTime();
        auto app = Application(
            randomUUID().toString(),
            req.tenantId,
            req.name,
            req.description,
            req.protocol,
            randomUUID().toString(), // clientId
            randomUUID()
            .toString(), // clientSecret
            req.redirectUris,
            req.allowedScopes,
            req.samlEntityId,
            req.samlAcsUrl,
            "",
            true,
            now,
            now
        );
        appRepo.save(app);
        return AppResponse(app.id, app.clientId, app.clientSecret, "");
    }

    Application getApplication(ApplicationId id) {
        return appRepo.findById(id);
    }

    Application[] listApplications(TenantId tenantId, uint offset = 0, uint limit = 100) {
        return appRepo.findByTenant(tenantId, offset, limit);
    }

    string updateApplication(UpdateAppRequest req) {
        auto app = appRepo.findById(req.applicationId);
        if (app == Application.init)
            return "Application not found";

        if (req.name.length > 0)
            app.name = req.name;
        if (req.redirectUris.length > 0)
            app.redirectUris = req.redirectUris;
        if (req.allowedScopes.length > 0)
            app.allowedScopes = req.allowedScopes;

        app.updatedAt = Clock.currStdTime();
        appRepo.update(app);
        return "";
    }

    string deleteApplication(ApplicationId id) {
        appRepo.remove(id);
        return "";
    }
}
