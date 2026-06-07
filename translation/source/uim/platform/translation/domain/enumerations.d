/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.translation.domain.enumerations;

import uim.platform.translation;

// mixin(ShowModule!());

@safe:

/// Type of a translation project source
enum ProjectType {
    file,
    git,
    abap,
    api,
}

/// Lifecycle status of a translation project
enum ProjectStatus {
    draft,
    active,
    inProgress,
    completed,
    archived,
}

/// Translation engine / provider
enum TranslationProvider {
    /// SAP multilingual text repository (verified translations)
    mltr,
    /// SAP neural machine translation
    machineMt,
    /// Company-specific multilingual text repository
    companyMltr,
    /// Large Language Model (generative AI hub)
    llm,
}

/// Status of an async translation job
enum JobStatus {
    pending,
    processing,
    completed,
    failed,
    cancelled,
}

/// Kind of translation job
enum JobType {
    software,
    document,
    text,
}

/// Quality rating for a translation result
enum QualityLevel {
    excellent,
    good,
    adequate,
    poor,
    unknown,
}
