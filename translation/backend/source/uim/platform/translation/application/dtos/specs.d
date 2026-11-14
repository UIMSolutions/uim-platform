/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.translation.application.dtos.specs;

import uim.platform.translation;

mixin(ShowModule!());

@safe:

// ── Translation projects ─────────────────────────────────────────────────────

struct ProjectSpec {
  string name;
  string description;
  ProjectType projectType = ProjectType.api;
  string sourceLanguage = "en";
  string[] targetLanguages;
  TranslationProvider provider = TranslationProvider.machineMt;
  string domainName;
  string repositoryUrl;
  string baseBranch;
  string abapSystemId;
}

alias CreateProjectRequest = CreateRootRequest!ProjectSpec;
alias UpdateProjectRequest = UpdateRequest!(TranslationProjectId, ProjectSpec);

// ── Project texts (parent = project) ─────────────────────────────────────────

struct ProjectTextSpec {
  string name; /// text key
  string sourceText;
  TextType textType = TextType.uiText;
  int maxLength;
  string context;
}

alias CreateProjectTextRequest = CreateRequest!(TranslationProjectId, ProjectTextSpec);
alias UpdateProjectTextRequest = UpdateRequest!(ProjectTextId, ProjectTextSpec);

// ── Glossary ─────────────────────────────────────────────────────────────────

struct GlossaryEntrySpec {
  string sourceLanguage;
  string targetLanguage;
  string sourceTerm;
  string targetTerm;
  string domainName;
  string context;
  bool mandatory;
  bool caseSensitive;
}

alias CreateGlossaryEntryRequest = CreateRootRequest!GlossaryEntrySpec;
alias UpdateGlossaryEntryRequest = UpdateRequest!(GlossaryEntryId, GlossaryEntrySpec);

// ── Asynchronous jobs ────────────────────────────────────────────────────────

struct JobSpec {
  JobType jobType = JobType.document;
  TranslationProjectId projectId; /// jobType software (id or name)
  string sourceLanguage; /// software: "" = project source language
  string targetLanguage; /// software: "" = every target language
  TranslationProvider provider = TranslationProvider.machineMt;
  string domainName;
  string contentType = "text/plain";
  string content;
}

alias SubmitJobRequest = CreateRootRequest!JobSpec;
alias UpdateJobRequest = UpdateRequest!(TranslationJobId, JobSpec);
