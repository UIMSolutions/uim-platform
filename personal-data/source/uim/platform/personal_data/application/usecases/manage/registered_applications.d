/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.personal_data.application.usecases.manage.registered_applications;

import uim.platform.personal_data;

mixin(ShowModule!());

@safe:

class ManageRegisteredApplicationsUseCase : UIMUseCase {
    private RegisteredApplicationRepository repo;

    this(RegisteredApplicationRepository repo) {
        this.repo = repo;
    }

    CommandResult create(CreateRegisteredApplicationRequest r) {
        if (r.id.isEmpty) return CommandResult(false, "", "ID is required");
        if (r.name.length == 0) return CommandResult(false, "", "Application name is required");

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
        return CommandResult(true, app.id, "");
    }

    RegisteredApplication getById(RegisteredApplicationId id) {
        return repo.findById(id);
    }

    RegisteredApplication[] list(TenantId tenantId) {
        return repo.findByTenant(tenantId);
    }

    CommandResult update(UpdateRegisteredApplicationRequest r) {
        auto existing = repo.findById(r.id);
        if (existing.id.isEmpty)
            return CommandResult(false, "", "Application not found");

        if (r.name.length > 0) existing.name = r.name;
        if (r.description.length > 0) existing.description = r.description;
        if (r.endpointUrl.length > 0) existing.endpointUrl = r.endpointUrl;
        if (r.apiVersion.length > 0) existing.apiVersion = r.apiVersion;
        if (r.contactEmail.length > 0) existing.contactEmail = r.contactEmail;
        if (r.contactName.length > 0) existing.contactName = r.contactName;
        existing.modifiedBy = r.modifiedBy;
        existing.modifiedAt = clockTime();

        repo.update(existing);
        return CommandResult(true, existing.id, "");
    }

    CommandResult activate(RegisteredApplicationId id) {
        auto existing = repo.findById(id);
        if (existing.id.isEmpty)
            return CommandResult(false, "", "Application not found");
        existing.status = ApplicationStatus.active;
        existing.modifiedAt = clockTime();
        repo.update(existing);
        return CommandResult(true, existing.id, "");
    }

    CommandResult suspend(RegisteredApplicationId id) {
        auto existing = repo.findById(id);
        if (existing.id.isEmpty)
            return CommandResult(false, "", "Application not found");
        existing.status = ApplicationStatus.suspended;
        existing.modifiedAt = clockTime();
        repo.update(existing);
        return CommandResult(true, existing.id, "");
    }

    CommandResult remove(RegisteredApplicationId id) {
        auto existing = repo.findById(id);
        if (existing.id.isEmpty)
            return CommandResult(false, "", "Application not found");
        repo.remove(id);
        return CommandResult(true, id.toString, "");
    }
}
