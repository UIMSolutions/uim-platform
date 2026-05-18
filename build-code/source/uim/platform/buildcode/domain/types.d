/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.buildcode.domain.types;

import uim.platform.buildcode;
import std.conv : to;

mixin(ShowModule!());

@safe:

// ── ID types ─────────────────────────────────────────────────────────────────

struct ProjectId {
  string value;
  this(string v) { value = v; }
  mixin DomainId;
}

struct DevSpaceId {
  string value;
  this(string v) { value = v; }
  mixin DomainId;
}

struct TemplateId {
  string value;
  this(string v) { value = v; }
  mixin DomainId;
}

struct PipelineId {
  string value;
  this(string v) { value = v; }
  mixin DomainId;
}

struct BuildJobId {
  string value;
  this(string v) { value = v; }
  mixin DomainId;
}

struct DeploymentId {
  string value;
  this(string v) { value = v; }
  mixin DomainId;
}

struct AIRequestId {
  string value;
  this(string v) { value = v; }
  mixin DomainId;
}

struct ServiceBindingId {
  string value;
  this(string v) { value = v; }
  mixin DomainId;
}

// ── Enumerations ─────────────────────────────────────────────────────────────

/// Type of project / dev-space template
enum ProjectType : string {
  cap      = "cap",
  fiori    = "fiori",
  sapui5   = "sapui5",
  mobile   = "mobile",
  java     = "java",
  nodejs   = "nodejs",
  other    = "other"
}

/// Runtime framework within a project
enum TechStack : string {
  capJava   = "cap-java",
  capNodejs = "cap-nodejs",
  sapui5    = "sapui5",
  fiori     = "fiori-elements",
  mobile    = "mobile-services",
  springBoot = "spring-boot",
  nodejs    = "nodejs",
  other     = "other"
}

/// Status of a project
enum ProjectStatus : string {
  active    = "active",
  inactive  = "inactive",
  archived  = "archived"
}

/// Status of a dev space
enum DevSpaceStatus : string {
  starting   = "starting",
  running    = "running",
  stopped    = "stopped",
  stopping   = "stopping",
  error_     = "error"
}

/// Stage of a CI/CD pipeline
enum PipelineStage : string {
  build   = "build",
  test    = "test",
  deploy  = "deploy",
  full    = "full"
}

/// Status of a pipeline run or build job
enum JobStatus : string {
  queued     = "queued",
  running    = "running",
  succeeded  = "succeeded",
  failed     = "failed",
  cancelled  = "cancelled"
}

/// Target environment for deployments
enum DeploymentEnvironment : string {
  cloudFoundry = "cloud-foundry",
  kyma         = "kyma",
  abapCloud    = "abap-cloud",
  neo          = "neo",
  other        = "other"
}

/// Status of a deployment
enum DeploymentStatus : string {
  pending    = "pending",
  deploying  = "deploying",
  succeeded  = "succeeded",
  failed     = "failed",
  rolling_back = "rolling-back"
}

/// Status of an AI code generation request
enum AIRequestStatus : string {
  pending    = "pending",
  processing = "processing",
  completed  = "completed",
  failed     = "failed"
}

/// Type of AI generation request
enum AIGenerationType : string {
  dataModel    = "data-model",
  service      = "service",
  sampleData   = "sample-data",
  uitPage      = "ui-page",
  codeFragment = "code-fragment",
  fullApp      = "full-app"
}

/// State of a service binding
enum BindingStatus : string {
  active    = "active",
  inactive_ = "inactive",
  error_    = "error"
}
