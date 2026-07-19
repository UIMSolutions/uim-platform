/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.translation.domain.entities.translation_project;

import uim.platform.translation;
mixin(ShowModule!());

@safe:

/// A software translation project — organises source files, Git repos, or ABAP extensions
/// for translation into one or more target languages.
struct TranslationProject {
    mixin TenantEntity!(TranslationProjectId);

    string name;
    string description;
    ProjectType projectType;
    /// BCP-47 language tag, e.g. "en"
    string sourceLanguage;
    /// BCP-47 language tags, e.g. ["de", "fr", "es"]
    string[] targetLanguages;
    ProjectStatus status;
    TranslationProvider provider;
    /// URL of a Git repository (used when projectType == git)
    string repositoryUrl;
    /// Branch name for Git projects
    string baseBranch;
    /// ABAP system or package identifier (used when projectType == abap)
    string abapSystemId;

    Json toJson() const {
        import std.algorithm : map;
        import std.array : array;

        auto langs = Json.emptyArray;
        foreach (l; targetLanguages)
            langs ~= Json(l);

        return entityToJson
            .set("name", name)
            .set("description", description)
            .set("projectType", projectType.to!string)
            .set("sourceLanguage", sourceLanguage)
            .set("targetLanguages", langs)
            .set("status", status.to!string)
            .set("provider", provider.to!string)
            .set("repositoryUrl", repositoryUrl)
            .set("baseBranch", baseBranch)
            .set("abapSystemId", abapSystemId);
    }
}
