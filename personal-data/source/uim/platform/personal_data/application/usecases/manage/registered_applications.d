/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.personal_data.application.usecases.manage.registered_applications;

import uim.platform.personal_data;

mixin(ShowModule!());

@safe:

class ManageRegisteredApplicationsUseCase { // TODO: UIMUseCase {
    private RegisteredApplicationRepository repo;

    this(RegisteredApplicationRepository repo) {
        this.repo = repo;
    }

    CommandResult createApplication(CreateRegisteredApplicationRequest r) {
        if (r.isNull) return CommandResult(false, "", "ID is required");
        if (r.name.isEmpty) return CommandResult(false, "", "Application name is required");

        RegisteredApplication app;
        app.id = r.id;
        app.tenantId = r.tenantId;
        app.name = r.name;
        app.description = r.description;
        app.status = ApplicationStatus.registered;
        app.endpointUrl = r.endpointUrl;
        app.apiVersion = r.apiVersion;
        app.dataCategoryIds = r.dataCategoryIds;
        app.purposeIds = r.purposeIds;
        app.contactEmail = r.contactEmail;
        app.contactName = r.contactName;
        app.registeredBy = r.registeredBy;
        app.registeredAt = clockTime();

        repo.save(app);
        return CommandResult(true, app.id.value, "");
    }

    RegisteredApplication getApplication(RegisteredApplicationId id) {
        return repo.findById(tenantId, id);
    }

    RegisteredApplication[] listApplications(TenantId tenantId) {
        return repo.findByTenant(tenantId);
    }

    CommandResult updateApplication(UpdateRegisteredApplicationRequest r) {
        auto existing = repo.findById(r.id);
        if (existing.isNull)
            return CommandResult(false, "", "Application not found");

        if (r.name.length > 0) existing.name = r.name;
        if (r.description.length > 0) existing.description = r.description;
        if (r.endpointUrl.length > 0) existing.endpointUrl = r.endpointUrl;
        if (r.apiVersion.length > 0) existing.apiVersion = r.apiVersion;
        if (r.contactEmail.length > 0) existing.contactEmail = r.contactEmail;
        if (r.contactName.length > 0) existing.contactName = r.contactName;
        existing.updatedBy = r.updatedBy;
        existing.updatedAt = clockTime();

        repo.update(existing);
        return CommandResult(true, existing.id.value, "");
    }

    CommandResult activateApplication(RegisteredApplicationId id) {
        auto existing = repo.findById(tenantId, id);
        if (existing.isNull)
            return CommandResult(false, "", "Application not found");
        existing.status = ApplicationStatus.active;
        existing.updatedAt = clockTime();
        repo.update(existing);
        return CommandResult(true, existing.id.value, "");
    }

    CommandResult suspendApplication(RegisteredApplicationId id) {
        auto existing = repo.findById(tenantId, id);
        if (existing.isNull)
            return CommandResult(false, "", "Application not found");
        existing.status = ApplicationStatus.suspended;
        existing.updatedAt = clockTime();
        repo.update(existing);
        return CommandResult(true, existing.id.value, "");
    }

    CommandResult deleteApplication(RegisteredApplicationId id) {
        auto application = repo.findById(tenantId, id);
        if (application.isNull)
            return CommandResult(false, "", "Application not found");

        repo.remove(application);
        return CommandResult(true, application.id.value, "");
    }
}
