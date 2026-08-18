/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.process_automation.application.usecases.manage.forms;

import uim.platform.process_automation;

mixin(ShowModule!());

@safe:
class ManageFormsUseCase {
    private IFormRepository repo;

    this(IFormRepository repo) {
        this.repo = repo;
    }

    UsecaseResult createForm(CreateFormRequest r) {
        if (r.formId.isEmpty)
            return UsecaseResult(false, "", "Form ID is required");
        if (r.name.isEmpty)
            return UsecaseResult(false, "", "Form name is required");

        auto existing = repo.findById(r.tenantId, r.formId);
        if (!existing.isNull)
            return UsecaseResult(false, "", "Form already exists");

        auto f = Form(r.tenantId, r.formId, r.createdBy);
        f.projectId = r.projectId;
        f.name = r.name;
        f.description = r.description;
        f.status = FormStatus.draft;
        f.version_ = r.version_;
        f.updatedAt = f.createdAt;

        repo.save(f);
        return UsecaseResult(true, f.id.value, "");
    }

    Form getForm(TenantId tenantId, FormId id) {
        return repo.findById(tenantId, id);
    }

    Form[] listForms(TenantId tenantId) {
        return repo.findByTenant(tenantId);
    }

    UsecaseResult updateForm(UpdateFormRequest r) {
        auto form = repo.findById(r.tenantId, r.formId);
        if (form.isNull)
            return UsecaseResult(false, "", "Form not found");

        form.name = r.name;
        form.description = r.description;
        form.version_ = r.version_;
        form.updatedBy = r.updatedBy;

        
        form.updatedAt = currentTimestamp;

        repo.update(form);
        return UsecaseResult(true, form.id.value, "");
    }

    UsecaseResult deleteForm(TenantId tenantId, FormId id) {
        auto form = repo.findById(tenantId, id);
        if (form.isNull)
            return UsecaseResult(false, "", "Form not found");

        repo.remove(form);
        return UsecaseResult(true, form.id.value, "");
    }
}
