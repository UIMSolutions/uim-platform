/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity.application.usecases.manage.applications;

import uim.platform.identity;

// mixin(ShowModule!());

@safe:

class ManageApplicationsUseCase {
    private ApplicationRepository repo;

    this(ApplicationRepository repo) { this.repo = repo; }

    Application getApplication(TenantId tenantId, ApplicationId id) { return repo.findById(tenantId, id); }
    Application[] listApplications(TenantId tenantId) { return repo.find(tenantId); }
    Application[] listByProtocol(TenantId tenantId, AppProtocol protocol) { return repo.findByProtocol(tenantId, protocol); }

    CommandResult createApplication(ApplicationDTO dto) {
        import std.digest.sha : sha256Of, toHexString;
        import std.random : uniform;
        
        auto app = Application(dto.tenantId);
        app.id = dto.applicationId;
        app.name = dto.name;
        app.description = dto.description;
        app.status = AppStatus.active;

        if (dto.protocol.length > 0) {
            
            try { app.protocol = dto.protocol.to!AppProtocol; } catch (Exception) { app.protocol = AppProtocol.oidc; }
        }
        if (dto.authScheme.length > 0) {
            
            try { app.authScheme = dto.authScheme.to!AuthScheme; } catch (Exception) { app.authScheme = AuthScheme.form; }
        }

        // Generate clientId if not provided
        if (dto.clientId.length > 0) app.clientId = dto.clientId;
        else {
            import std.format : format;
            app.clientId = format!"app-%s-%d"(app.id.value[0..8], uniform(1000, 9999));
        }

        app.redirectUris = dto.redirectUris;
        app.scopes = dto.scopes;
        app.logoUrl = dto.logoUrl;
        app.homepageUrl = dto.homepageUrl;
        app.multiTenantEnabled = dto.multiTenantEnabled;
        app.riskBasedAuthEnabled = dto.riskBasedAuthEnabled;

        if (!IdentityValidator.isValidApplication(app))
            return CommandResult(false, "", "Invalid application: name and clientId are required");

        repo.save(app);
        return CommandResult(true, app.id.value, "");
    }

    CommandResult updateApplication(ApplicationDTO dto) {
        auto existing = repo.findById(dto.tenantId, dto.applicationId);
        if (existing.isNull) return CommandResult(false, "", "Application not found");

        if (dto.name.length > 0) existing.name = dto.name;
        if (dto.description.length > 0) existing.description = dto.description;
        if (dto.status.length > 0) {
            
            try { existing.status = dto.status.to!AppStatus; } catch (Exception) {}
        }
        if (dto.redirectUris.length > 0) existing.redirectUris = dto.redirectUris;
        if (dto.scopes.length > 0) existing.scopes = dto.scopes;
        if (dto.logoUrl.length > 0) existing.logoUrl = dto.logoUrl;
        if (dto.homepageUrl.length > 0) existing.homepageUrl = dto.homepageUrl;
        existing.multiTenantEnabled = dto.multiTenantEnabled;
        existing.riskBasedAuthEnabled = dto.riskBasedAuthEnabled;
        if (!dto.updatedBy.isNull) existing.updatedBy = dto.updatedBy;

        repo.update(existing);
        return CommandResult(true, existing.id.value, "");
    }

    CommandResult deleteApplication(TenantId tenantId, ApplicationId id) {
        auto entity = repo.findById(tenantId, id);
        if (entity.isNull) return CommandResult(false, "", "Application not found");
        repo.remove(entity);
        return CommandResult(true, id.value, "");
    }
}
