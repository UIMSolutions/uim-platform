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
ProjectStatus[] toProjectStatuses(string[] values) {
    return values.map!(v => toProjectStatus(v)).array;
}
string toString(ProjectStatus value) {
    return value.to!string;
}
string[] toStrings(ProjectStatus[] values) {
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
TranslationProvider[] toTranslationProviders(string[] values) {
    return values.map!(toTranslationProvider).array;
}
string toString(TranslationProvider value) {
    return value.to!string;
}
string[] toStrings(TranslationProvider[] values) {
    return values.map!toString.array;
}
///
unittest {
    mixin(ShowTest!"TranslationProvider");

    assert("mltr".toTranslationProvider == TranslationProvider.mltr);
    assert("machineMt".toTranslationProvider == TranslationProvider.machineMt);
    assert("companyMltr".toTranslationProvider == TranslationProvider.companyMltr);
    assert("llm".toTranslationProvider == TranslationProvider.llm);

    assert("".toTranslationProvider == TranslationProvider.mltr);
    assert("invalid".toTranslationProvider == TranslationProvider.mltr);

    assert(TranslationProvider.mltr.toString == "mltr");
    assert(TranslationProvider.machineMt.toString == "machineMt");
    assert(TranslationProvider.companyMltr.toString == "companyMltr");
    assert(TranslationProvider.llm.toString == "llm");

    assert(toTranslationProviders(["mltr", "llm", "invalid"]) == [TranslationProvider.mltr, TranslationProvider.llm, TranslationProvider.mltr]);
    assert(toStrings([TranslationProvider.mltr, TranslationProvider.companyMltr]) == ["mltr", "companyMltr"]);
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
JobStatus[] toJobStatuses(string[] values) {
    return values.map!(toJobStatus).array;
}
string toString(JobStatus value) {
    return value.to!string;
}
string[] toStrings(JobStatus[] values) {
    return values.map!toString.array;
}
/// 
unittest {
    mixin(ShowTest!"JobStatus");

    assert("pending".toJobStatus == JobStatus.pending);
    assert("processing".toJobStatus == JobStatus.processing);
    assert("completed".toJobStatus == JobStatus.completed);
    assert("failed".toJobStatus == JobStatus.failed);
    assert("cancelled".toJobStatus == JobStatus.cancelled);
    
    assert("".toJobStatus == JobStatus.pending);
    assert("invalid".toJobStatus == JobStatus.pending);

    assert(JobStatus.pending.toString == "pending");
    assert(JobStatus.processing.toString == "processing");
    assert(JobStatus.completed.toString == "completed");
    assert(JobStatus.failed.toString == "failed");
    assert(JobStatus.cancelled.toString == "cancelled");

    assert(["pending", "completed", "invalid"].toJobStatuses == [JobStatus.pending, JobStatus.completed, JobStatus.pending]);
    assert([JobStatus.pending, JobStatus.cancelled].toStrings == ["pending", "cancelled"]);
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
JobType[] toJobTypes(string[] values) {
    return values.map!(toJobType).array;
}
string toString(JobType value) {
    return value.to!string;
}
string[] toStrings(JobType[] values) {
    return values.map!toString.array;
}
///
unittest {
    mixin(ShowTest!"JobType");

    assert("software".toJobType == JobType.software);
    assert("document".toJ.obType == JobType.document);
    assert("text".toJobType == JobType.text);
    
    assert("".toJobType == JobType.software);
    assert("invalid".toJobType == JobType.software);

    assert(JobType.software.toString == "software");
    assert(JobType.document.toString == "document");
    assert(JobType.text.toString == "text");

    assert(["software", "text", "invalid"].toJobTypes == [JobType.software, JobType.text, JobType.software]);
    assert([JobType.software, JobType.document].toStrings == ["software", "document"]);
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
QualityLevel[] toQualityLevels(string[] values) {
    return values.map!(toQualityLevel).array;
}
string toString(QualityLevel value) {
    return value.to!string;
}
string[] toStrings(QualityLevel[] values) {
    return values.map!toString.array;
}   
///
unittest {
    mixin(ShowTest!"QualityLevel");

    assert("excellent".toQualityLevel == QualityLevel.excellent);
    assert("good".toQualityLevel == QualityLevel.good);
    assert("adequate".toQualityLevel == QualityLevel.adequate);
    assert("poor".toQualityLevel == QualityLevel.poor);
    assert("unknown".toQualityLevel == QualityLevel.unknown);
    
    assert("".toQualityLevel == QualityLevel.unknown);
    assert("invalid".toQualityLevel == QualityLevel.unknown);

    assert(QualityLevel.excellent.toString == "excellent");
    assert(QualityLevel.good.toString == "good");
    assert(QualityLevel.adequate.toString == "adequate");
    assert(QualityLevel.poor.toString == "poor");
    assert(QualityLevel.unknown.toString == "unknown");

    assert(["excellent", "poor", "invalid"].toQualityLevels == [QualityLevel.excellent, QualityLevel.poor, QualityLevel.unknown]);
    assert([QualityLevel.excellent, QualityLevel.good].toStrings == ["excellent", "good"]);
}
