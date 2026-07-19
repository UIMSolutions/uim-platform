/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.translation.application.dto;

import uim.platform.translation;

mixin(ShowModule!());

@safe:

// --- Translation Project ---

struct CreateTranslationProjectRequest {
    TenantId tenantId;
    string name;
    string description;
    string projectType;
    string sourceLanguage;
    string[] targetLanguages;
    string provider;
    string repositoryUrl;
    string baseBranch;
    string abapSystemId;
}

struct UpdateTranslationProjectRequest {
    TenantId tenantId;
    TranslationProjectId projectId;
    string name;
    string description;
    string[] targetLanguages;
    string provider;
    string repositoryUrl;
    string baseBranch;
    string status;
}

// --- Glossary Entry ---

struct CreateGlossaryEntryRequest {
    TenantId tenantId;
    GlossaryEntryId entryId;

    string sourceLanguage;
    string targetLanguage;
    string sourceTerm;
    string targetTerm;
    string domainName;
    string context;
    bool mandatory;
}

struct UpdateGlossaryEntryRequest {
    TenantId tenantId;
    GlossaryEntryId entryId;
    string targetTerm;
    string domainName;
    string context;
    bool mandatory;
}

// --- Software Translation ---

struct TranslateTextRequest {
    TenantId tenantId;
    /// BCP-47 source language tag
    string sourceLanguage;
    /// BCP-47 target language tag
    string targetLanguage;
    /// Texts to translate
    string[] texts;
    /// Translation domain (e.g. "IT", "HR")
    string domainName;
    /// Text type (e.g. "uiText", "documentation")
    string textType;
    /// Preferred translation provider
    string provider;
}

// --- Document Translation (sync) ---

struct TranslateDocumentRequest {
    TenantId tenantId;
    string sourceLanguage;
    string targetLanguage;
    string provider;
    /// Document content as text
    string content;
    /// MIME type, e.g. "text/plain", "application/json"
    string contentType;
}

// --- Document Translation (async) ---

struct SubmitTranslationJobRequest {
    TenantId tenantId;
    JobType jobType;

    string sourceLanguage;
    string targetLanguage;
    string provider;
    string content;
    string contentType;
}
