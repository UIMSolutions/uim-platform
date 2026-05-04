/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.application_studio.application.usecases.manage.project_templates;

import uim.platform.application_studio;

mixin(ShowModule!());

@safe:

class ManageProjectTemplatesUseCase { // TODO: UIMUseCase {
    private ProjectTemplateRepository repo;

    this(ProjectTemplateRepository repo) {
        this.repo = repo;
    }

    ProjectTemplate getById(ProjectTemplateId id) {
        return repo.findById(id);
    }

    ProjectTemplate[] list() {
        return repo.findAll();
    }

    ProjectTemplate[] listByTenant(TenantId tenantId) {
        return repo.findByTenant(tenantId);
    }

    CommandResult create(ProjectTemplateDTO dto) {
        ProjectTemplate e;
        e.id = ProjectTemplateId(dto.id);
        e.tenantId = dto.tenantId;
        e.name = dto.name;
        e.description = dto.description;
        e.version_ = dto.version_;
        e.requiredExtensions = dto.requiredExtensions;
        e.scaffoldConfig = dto.scaffoldConfig;
        e.defaultFiles = dto.defaultFiles;
        e.iconUrl = dto.iconUrl;
        e.createdBy = dto.createdBy;
        if (!StudioValidator.isValidProjectTemplate(e))
            return CommandResult(false, "", "Invalid project template data");
        repo.save(e);
        return CommandResult(true, dto.id, "");
    }

    CommandResult update(ProjectTemplateDTO dto) {
        if (!repo.existsById(ProjectTemplateId(dto.id)))
            return CommandResult(false, "", "Project template not found");
        auto existing = repo.findById(ProjectTemplateId(dto.id));
        if (dto.name.length > 0) existing.name = dto.name;
        if (dto.description.length > 0) existing.description = dto.description;
        if (dto.version_.length > 0) existing.version_ = dto.version_;
        if (!dto.updatedBy.isNull) existing.updatedBy = dto.updatedBy;
        repo.update(existing);
        return CommandResult(true, dto.id, "");
    }

    CommandResult remove(ProjectTemplateId id) {
        if (!repo.existsById(id))
            return CommandResult(false, "", "Project template not found");
        repo.removeById(id);
        return CommandResult(true, id.value, "");
    }
}
