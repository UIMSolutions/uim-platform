/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.saas_provisioning.application.usecases.manage.saas_applications;

import uim.platform.saas_provisioning;



// mixin(ShowModule!());

@safe:

/// Use case: full CRUD lifecycle for registered multitenant SaaS applications (provider side).
class ManageSaasApplicationsUseCase {
    private SaasApplicationRepository repo;

    this(SaasApplicationRepository repo) {
        this.repo = repo;
    }

    SaasApplication[] listApplications(TenantId tenantId) {
        return repo.find(tenantId);
    }

    SaasApplication getApplication(TenantId tenantId, SaasApplicationId id) {
        return repo.findById(tenantId, id);
    }

    SaasApplication getApplicationByName(TenantId tenantId, string appName) {
        return repo.findByAppName(tenantId, appName);
    }

    CommandResult registerApplication(TenantId tenantId, RegisterAppRequest req) {
        long   now   = MonoTime.currTime.ticks;
        string newId = now.to!string ~ "-app-" ~ req.appName;

        auto app = new SaasApplication();
        app.id                          = SaasApplicationId(newId);
        app.tenantId                    = tenantId;
        app.appName                     = req.appName;
        app.displayName                 = req.displayName;
        app.description                 = req.description;
        app.category                    = req.category;
        app.appUrls                     = req.appUrls;
        app.providerSubaccountId        = req.providerSubaccountId;
        app.globalAccountId             = req.accountId;
        app.xsuaaServiceInstanceId      = req.xsuaaServiceInstanceId;
        app.plan                        = req.plan;
        app.autoSubscribeGlobalAccounts = req.autoSubscribeGlobalAccounts;
        app.dependencies                = req.dependencies;
        app.status                      = AppRegistrationStatus.registered;
        app.createdAt                   = now;
        app.updatedAt                   = now;

        repo.add(app);
        return CommandResult(true, newId, "");
    }

    CommandResult updateApplication(TenantId tenantId, SaasApplicationId id, UpdateAppRequest req) {
        auto app = repo.findById(tenantId, id);
        if (app.isNull) return CommandResult(false, "", "Application not found");

        long now = MonoTime.currTime.ticks;
        app.displayName                 = req.displayName;
        app.description                 = req.description;
        app.category                    = req.category;
        app.appUrls                     = req.appUrls;
        app.plan                        = req.plan;
        app.autoSubscribeGlobalAccounts = req.autoSubscribeGlobalAccounts;
        app.dependencies                = req.dependencies;
        app.status                      = AppRegistrationStatus.updating;
        app.updatedAt                   = now;

        repo.update(app);
        return CommandResult(true, id.value, "");
    }

    CommandResult deregisterApplication(TenantId tenantId, SaasApplicationId id) {
        auto app = repo.findById(tenantId, id);
        if (app.isNull) return CommandResult(false, "", "Application not found");
        repo.remove(tenantId, id);
        return CommandResult(true, id.value, "");
    }
}
