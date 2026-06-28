/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.translation.application.usecases.manage.translation_projects;

import uim.platform.translation;


// mixin(ShowModule!());

@safe:

class ManageTranslationProjectsUseCase {
    private TranslationProjectRepository repo;

    this(TranslationProjectRepository repo) {
        this.repo = repo;
    }

    CommandResult createProject(CreateTranslationProjectRequest r) {
        if (r.name.length == 0)
            return CommandResult(false, "", "Project name is required");
        if (r.sourceLanguage.length == 0)
            return CommandResult(false, "", "Source language is required");
        if (r.targetLanguages.length == 0)
            return CommandResult(false, "", "At least one target language is required");

        TranslationProject p;
        p.initEntity(r.tenantId);
        p.name = r.name;
        p.description = r.description;
        p.sourceLanguage = r.sourceLanguage;
        p.targetLanguages = r.targetLanguages;
        p.status = ProjectStatus.draft;

        try { p.projectType = r.projectType.to!ProjectType; }
        catch (Exception) { p.projectType = ProjectType.api; }

        try { p.provider = r.provider.to!TranslationProvider; }
        catch (Exception) { p.provider = TranslationProvider.machineMt; }

        p.repositoryUrl = r.repositoryUrl;
        p.baseBranch = r.baseBranch;
        p.abapSystemId = r.abapSystemId;

        repo.save(p);
        return CommandResult(true, p.id.value, "");
    }

    TranslationProject[] listProjects(TenantId tenantId) {
        return repo.find(tenantId);
    }

    TranslationProject getProject(TenantId tenantId, TranslationProjectId id) {
        return repo.findById(tenantId, id);
    }

    CommandResult updateProject(UpdateTranslationProjectRequest r) {
        auto existing = repo.find(r.tenantId, r.projectId);
        if (existing.isNull)
            return CommandResult(false, "", "Translation project not found");

        if (r.name.length > 0)   existing.name = r.name;
        if (r.description.length > 0) existing.description = r.description;
        if (r.targetLanguages.length > 0) existing.targetLanguages = r.targetLanguages;
        if (r.repositoryUrl.length > 0) existing.repositoryUrl = r.repositoryUrl;
        if (r.baseBranch.length > 0) existing.baseBranch = r.baseBranch;

        if (r.status.length > 0) {
            try { existing.status = r.status.to!ProjectStatus; }
            catch (Exception) {}
        }
        if (r.provider.length > 0) {
            try { existing.provider = r.provider.to!TranslationProvider; }
            catch (Exception) {}
        }

        repo.update(existing);
        return CommandResult(true, existing.id.value, "");
    }

    CommandResult deleteProject(TenantId tenantId, TranslationProjectId id) {
        auto existing = repo.findById(tenantId, id);
        if (existing.isNull)
            return CommandResult(false, "", "Translation project not found");

        repo.remove(existing);
        return CommandResult(true, existing.id.value, "");
    }
}
