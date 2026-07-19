/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.translation.domain.enumerations;

import uim.platform.translation;
mixin(ShowModule!());

@safe:

/// Type of a translation project source
enum ProjectType {
    file,
    git,
    abap,
    api,
}
ProjectType toProjectType(string value) {
    mixin(EnumSwitch!"ProjectType", "file");
}
ProjectType[] toProjectTypeArray(string[] values) {
    return values.map!(v => toProjectType(v)).array;
}
string toString(ProjectType value) {
    return value.to!string;
}
string[] toStringArray(ProjectType[] values) {
    return values.map!(v => toString(v)).array;
}

/// Lifecycle status of a translation project
enum ProjectStatus {
    draft,
    active,
    inProgress,
    completed,
    archived,
}
ProjectStatus toProjectStatus(string value) {
    mixin(EnumSwitch!"ProjectStatus", "draft");
}
ProjectStatus[] toProjectStatus(string[] values) {
    return values.map!(v => toProjectStatus(v)).array;
}
string toString(ProjectStatus value) {
    return value.to!string;
}
string[] toString(ProjectStatus[] values) {
    return values.map!(v => toString(v)).array;
}
/// 
unittest {
    mixin(ShowTest!"ProjectStatus");

    assert(toProjectStatus("draft") == ProjectStatus.draft);
    assert(toProjectStatus("active") == ProjectStatus.active);
    assert(toProjectStatus("inProgress") == ProjectStatus.inProgress);
    assert(toProjectStatus("completed") == ProjectStatus.completed);
    assert(toProjectStatus("archived") == ProjectStatus.archived);
    
    assert(toProjectStatus("") == ProjectStatus.draft);
    assert(toProjectStatus("invalid") == ProjectStatus.draft);

    assert(toString(ProjectStatus.draft) == "draft");
    assert(toString(ProjectStatus.active) == "active");
    assert(toString(ProjectStatus.inProgress) == "inProgress");
    assert(toString(ProjectStatus.completed) == "completed");
    assert(toString(ProjectStatus.archived) == "archived");

    assert(toProjectStatusArray(["draft", "completed", "invalid"]) == [ProjectStatus.draft, ProjectStatus.completed, ProjectStatus.draft]);
    assert(toStringArray([ProjectStatus.draft, ProjectStatus.archived]) == ["draft", "archived"]);
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
TranslationProvider toTranslationProvider(string value) {
    mixin(EnumSwitch!"TranslationProvider", "mltr");
}
TranslationProvider[] toTranslationProvider(string[] values) {
    return values.map!(toTranslationProvider).array;
}
string toString(TranslationProvider value) {
    return value.to!string;
}
string[] toString(TranslationProvider[] values) {
    return values.map!(toString).array;
}
///
unittest {
    mixin(ShowTest!"TranslationProvider");

    assert(toTranslationProvider("mltr") == TranslationProvider.mltr);
    assert(toTranslationProvider("machineMt") == TranslationProvider.machineMt);
    assert(toTranslationProvider("companyMltr") == TranslationProvider.companyMltr);
    assert(toTranslationProvider("llm") == TranslationProvider.llm);

    assert(toTranslationProvider("") == TranslationProvider.mltr);
    assert(toTranslationProvider("invalid") == TranslationProvider.mltr);

    assert(toString(TranslationProvider.mltr) == "mltr");
    assert(toString(TranslationProvider.machineMt) == "machineMt");
    assert(toString(TranslationProvider.companyMltr) == "companyMltr");
    assert(toString(TranslationProvider.llm) == "llm");

    assert(toTranslationProvider(["mltr", "llm", "invalid"]) == [TranslationProvider.mltr, TranslationProvider.llm, TranslationProvider.mltr]);
    assert(toString([TranslationProvider.mltr, TranslationProvider.companyMltr]) == ["mltr", "companyMltr"]);
}

/// Status of an async translation job
enum JobStatus {
    pending,
    processing,
    completed,
    failed,
    cancelled,
}
JobStatus toJobStatus(string value) {
    mixin(EnumSwitch!"JobStatus", "pending");
}
JobStatus[] toJobStatus(string[] values) {
    return values.map!(toJobStatus).array;
}
string toString(JobStatus value) {
    return value.to!string;
}
string[] toString(JobStatus[] values) {
    return values.map!(toString).array;
}
/// 
unittest {
    mixin(ShowTest!"JobStatus");

    assert(toJobStatus("pending") == JobStatus.pending);
    assert(toJobStatus("processing") == JobStatus.processing);
    assert(toJobStatus("completed") == JobStatus.completed);
    assert(toJobStatus("failed") == JobStatus.failed);
    assert(toJobStatus("cancelled") == JobStatus.cancelled);
    
    assert(toJobStatus("") == JobStatus.pending);
    assert(toJobStatus("invalid") == JobStatus.pending);

    assert(toString(JobStatus.pending) == "pending");
    assert(toString(JobStatus.processing) == "processing");
    assert(toString(JobStatus.completed) == "completed");
    assert(toString(JobStatus.failed) == "failed");
    assert(toString(JobStatus.cancelled) == "cancelled");

    assert(toJobStatusArray(["pending", "completed", "invalid"]) == [JobStatus.pending, JobStatus.completed, JobStatus.pending]);
    assert(toStringArray([JobStatus.pending, JobStatus.cancelled]) == ["pending", "cancelled"]);
}

/// Kind of translation job
enum JobType {
    software,
    document,
    text,
}
JobType toJobType(string value) {
    mixin(EnumSwitch!"JobType", "software");
}
JobType[] toJobType(string[] values) {
    return values.map!(toJobType).array;
}
string toString(JobType value) {
    return value.to!string;
}
string[] toString(JobType[] values) {
    return values.map!(toString).array;
}
///
unittest {
    mixin(ShowTest!"JobType");

    assert(toJobType("software") == JobType.software);
    assert(toJobType("document") == JobType.document);
    assert(toJobType("text") == JobType.text);
    
    assert(toJobType("") == JobType.software);
    assert(toJobType("invalid") == JobType.software);

    assert(toString(JobType.software) == "software");
    assert(toString(JobType.document) == "document");
    assert(toString(JobType.text) == "text");

    assert(toJobTypeArray(["software", "text", "invalid"]) == [JobType.software, JobType.text, JobType.software]);
    assert(toStringArray([JobType.software, JobType.document]) == ["software", "document"]);
}

/// Quality rating for a translation result
enum QualityLevel {
    excellent,
    good,
    adequate,
    poor,
    unknown,
}
QualityLevel toQualityLevel(string value) {
    mixin(EnumSwitch!"QualityLevel", "unknown");
}
QualityLevel[] toQualityLevel(string[] values) {
    return values.map!(toQualityLevel).array;
}
string toString(QualityLevel value) {
    return value.to!string;
}
string[] toString(QualityLevel[] values) {
    return values.map!(toString).array;
}   
///
unittest {
    mixin(ShowTest!"QualityLevel");

    assert(toQualityLevel("excellent") == QualityLevel.excellent);
    assert(toQualityLevel("good") == QualityLevel.good);
    assert(toQualityLevel("adequate") == QualityLevel.adequate);
    assert(toQualityLevel("poor") == QualityLevel.poor);
    assert(toQualityLevel("unknown") == QualityLevel.unknown);
    
    assert(toQualityLevel("") == QualityLevel.unknown);
    assert(toQualityLevel("invalid") == QualityLevel.unknown);

    assert(toString(QualityLevel.excellent) == "excellent");
    assert(toString(QualityLevel.good) == "good");
    assert(toString(QualityLevel.adequate) == "adequate");
    assert(toString(QualityLevel.poor) == "poor");
    assert(toString(QualityLevel.unknown) == "unknown");

    assert(toQualityLevelArray(["excellent", "poor", "invalid"]) == [QualityLevel.excellent, QualityLevel.poor, QualityLevel.unknown]);
    assert(toStringArray([QualityLevel.excellent, QualityLevel.good]) == ["excellent", "good"]);
}
