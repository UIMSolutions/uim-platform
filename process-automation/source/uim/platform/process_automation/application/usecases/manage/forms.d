/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.process_automation.application.usecases.manage.forms;

import uim.platform.process_automation;

mixin(ShowModule!());

@safe:
class ManageFormsUseCase : UIMUseCase {
    private FormRepository repo;

    this(FormRepository repo) {
        this.repo = repo;
    }

    CommandResult create(CreateFormRequest r) {
        if (r.id.isEmpty)
            return CommandResult(false, "", "Form ID is required");
        if (r.name.length == 0)
            return CommandResult(false, "", "Form name is required");

        auto existing = repo.findById(r.id);
        if (existing.id.length > 0)
            return CommandResult(false, "", "Form already exists");

        Form f;
        f.id = r.id;
        f.tenantId = r.tenantId;
        f.projectId = r.projectId;
        f.name = r.name;
        f.description = r.description;
        f.status = FormStatus.draft;
        f.version_ = r.version_;
        f.createdBy = r.createdBy;

        import core.time : MonoTime;
        auto now = MonoTime.currTime.ticks;
        f.createdAt = now;
        f.modifiedAt = now;

        repo.save(f);
        return CommandResult(true, f.id, "");
    }

    Form get_(FormId id) {
        return repo.findById(id);
    }

    Form[] list(TenantId tenantId) {
        return repo.findByTenant(tenantId);
    }

    CommandResult update(UpdateFormRequest r) {
        auto existing = repo.findById(r.id);
        if (existing.id.isEmpty)
            return CommandResult(false, "", "Form not found");

        existing.name = r.name;
        existing.description = r.description;
        existing.version_ = r.version_;
        existing.modifiedBy = r.modifiedBy;

        import core.time : MonoTime;
        existing.modifiedAt = MonoTime.currTime.ticks;

        repo.update(existing);
        return CommandResult(true, existing.id, "");
    }

    CommandResult remove(FormId id) {
        auto existing = repo.findById(id);
        if (existing.id.isEmpty)
            return CommandResult(false, "", "Form not found");

        repo.remove(id);
        return CommandResult(true, id.toString, "");
    }
}
