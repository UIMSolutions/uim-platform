/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.translation.domain.entities.translation_job;

import uim.platform.translation;

// mixin(ShowModule!());

@safe:

/// An asynchronous translation job — tracks the status of a document or bulk text
/// translation request submitted through the async API.
struct TranslationJob {
    mixin TenantEntity!(TranslationJobId);

    JobType jobType;
    /// BCP-47 source language tag
    string sourceLanguage;
    /// BCP-47 target language tag
    string targetLanguage;
    TranslationProvider provider;
    JobStatus status;
    /// Input content (text) or document reference
    string inputContent;
    /// Translated output content
    string outputContent;
    /// Error description (set when status == failed)
    string errorMessage;
    /// MIME type of the input/output document
    string contentType;
    /// Quality score 0-100 (set on completion)
    int qualityScore;
    /// Unix timestamp (ms) when the job completed
    long completedAt;

    Json toJson() const {
        return entityToJson
            .set("jobType", jobType.to!string)
            .set("sourceLanguage", sourceLanguage)
            .set("targetLanguage", targetLanguage)
            .set("provider", provider.to!string)
            .set("status", status.to!string)
            .set("contentType", contentType)
            .set("qualityScore", qualityScore)
            .set("completedAt", completedAt)
            .set("errorMessage", errorMessage);
    }
}
