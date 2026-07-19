/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.buildcode.domain.enumerations;

import uim.platform.buildcode;

mixin(ShowModule!());

@safe:


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
ProjektType toProjectType(string value) {
  mixin(EnumSwitch("ProjectType", "ProjectType.other"));
}
ProjectType[] toProjectType(string[] values) {
  return values.map!(v => v.toProjectType).array;
}
string toString(ProjectType value) {
  return value.to!string();
}
string[] toStrings(ProjectType[] values) {
  return values.map!(v => v.toString).array;
}
/// 
unittest {
  mixin(ShowTest!("ProjectType"));

  assert("cap".toProjectType == ProjectType.cap);
  assert("fiori".toProjectType == ProjectType.fiori);
  assert("sapui5".toProjectType == ProjectType.sapui5);
  assert("mobile".toProjectType == ProjectType.mobile);
  assert("java".toProjectType == ProjectType.java);
  assert("nodejs".toProjectType == ProjectType.nodejs);
  assert("other".toProjectType == ProjectType.other);
  assert("unknown".toProjectType == ProjectType.other);

  assert(ProjectType.cap.toString == "cap");
  assert(ProjectType.fiori.toString == "fiori");
  assert(ProjectType.sapui5.toString == "sapui5");
  assert(ProjectType.mobile.toString == "mobile");
  assert(ProjectType.java.toString == "java");
  assert(ProjectType.nodejs.toString == "nodejs");
  assert(ProjectType.other.toString == "other");

  assert(["cap", "fiori"].toProjectType == [ProjectType.cap, ProjectType.fiori]);
  assert([ProjectType.cap, ProjectType.fiori].toString == ["cap", "fiori"]);
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
TechStack toTechStack(string value) {
  mixin(EnumSwitch("TechStack", "TechStack.other"));
}
TechStack[] toTechStack(string[] values) {
  return values.map!(v => v.toTechStack).array;
}
string toString(TechStack value) {
  return value.to!string();
}
string[] toStrings(TechStack[] values) {
  return values.map!(v => v.toString()).array;
}
///
unittest {
  mixin(ShowTest!("TechStack"));

  assert("cap-java".toTechStack == TechStack.capJava);
  assert("cap-nodejs".toTechStack == TechStack.capNodejs);
  assert("sapui5".toTechStack == TechStack.sapui5);
  assert("fiori-elements".toTechStack == TechStack.fiori);
  assert("mobile-services".toTechStack == TechStack.mobile);
  assert("spring-boot".toTechStack == TechStack.springBoot);
  assert("nodejs".toTechStack == TechStack.nodejs);
  assert("other".toTechStack == TechStack.other);
  assert("unknown".toTechStack == TechStack.other);

  assert(TechStack.capJava.toString == "cap-java");
  assert(TechStack.capNodejs.toString == "cap-nodejs");
  assert(TechStack.sapui5.toString == "sapui5");
  assert(TechStack.fiori.toString == "fiori-elements");
  assert(TechStack.mobile.toString == "mobile-services");
  assert(TechStack.springBoot.toString == "spring-boot");
  assert(TechStack.nodejs.toString == "nodejs");
  assert(TechStack.other.toString == "other");  

  assert(["cap-java", "sapui5"].toTechStack == [TechStack.capJava, TechStack.sapui5]);
  assert([TechStack.capJava, TechStack.sapui5].toString == ["cap-java", "sapui5"]);
} 

/// Status of a project
enum ProjectStatus : string {
  active    = "active",
  inactive  = "inactive",
  archived  = "archived"
}
ProjectStatus toProjectStatus(string value) {
  mixin(EnumSwitch("ProjectStatus", "ProjectStatus.inactive"));
}
ProjectStatus[] toProjectStatus(string[] values) {
  return values.map!(v => v.toProjectStatus).array;
}
string toString(ProjectStatus value) {
  return value.to!string();
}
string[] toStrings(ProjectStatus[] values) {
  return values.map!(v => v.toString()).array;
}
///
unittest {
  mixin(ShowTest!("ProjectStatus"));

  assert("active".toProjectStatus == ProjectStatus.active);
  assert("inactive".toProjectStatus == ProjectStatus.inactive);
  assert("archived".toProjectStatus == ProjectStatus.archived);
  assert("unknown".toProjectStatus == ProjectStatus.inactive); // default

  assert(ProjectStatus.active.toString == "active");
  assert(ProjectStatus.inactive.toString == "inactive");
  assert(ProjectStatus.archived.toString == "archived");  

  assert(["active", "archived"].toProjectStatus == [ProjectStatus.active, ProjectStatus.archived]);
  assert([ProjectStatus.active, ProjectStatus.archived].toString == ["active", "archived"]);
} 

/// Status of a dev space
enum DevSpaceStatus : string {
  starting   = "starting",
  running    = "running",
  stopped    = "stopped",
  stopping   = "stopping",
  error_     = "error" 
}
DevSpaceStatus toDevSpaceStatus(string value) {
  mixin(EnumSwitch("DevSpaceStatus", "DevSpaceStatus.stopped"));
}
DevSpaceStatus[] toDevSpaceStatus(string[] values) {
  return values.map!(v => v.toDevSpaceStatus).array;
}
string toString(DevSpaceStatus value) {
  return cast(string)value;
}
string[] toStrings(DevSpaceStatus[] values) {
  return values.map!(v => v.toString()).array;
}
///
unittest {
  mixin(ShowTest!("DevSpaceStatus"));

  assert("starting".toDevSpaceStatus == DevSpaceStatus.starting);
  assert("running".toDevSpaceStatus == DevSpaceStatus.running);
  assert("stopped".toDevSpaceStatus == DevSpaceStatus.stopped);
  assert("stopping".toDevSpaceStatus == DevSpaceStatus.stopping);
  assert("error".toDevSpaceStatus == DevSpaceStatus.error_);
  assert("unknown".toDevSpaceStatus == DevSpaceStatus.stopped); // default  

  assert(DevSpaceStatus.starting.toString == "starting");
  assert(DevSpaceStatus.running.toString == "running");
  assert(DevSpaceStatus.stopped.toString == "stopped");
  assert(DevSpaceStatus.stopping.toString == "stopping");
  assert(DevSpaceStatus.error_.toString == "error");

  assert(["starting", "stopped"].toDevSpaceStatus == [DevSpaceStatus.starting, DevSpaceStatus.stopped]);
  assert([DevSpaceStatus.starting, DevSpaceStatus.stopped].toString == ["starting", "stopped"]);
} 

/// Stage of a CI/CD pipeline
enum PipelineStage : string {
  build   = "build",
  test    = "test",
  deploy  = "deploy",
  full    = "full"
}
PipelineStage toPipelineStage(string value) {
  mixin(EnumSwitch("PipelineStage", "PipelineStage.build"));
}
PipelineStage[] toPipelineStage(string[] values) {
  return values.map!(v => v.toPipelineStage).array;
}
string toString(PipelineStage value) {
  return value.to!string();
}
string[] toStrings(PipelineStage[] values) {
  return values.map!(v => v.toString()).array;
}
///
unittest {
  mixin(ShowTest!("PipelineStage"));

  assert("build".toPipelineStage == PipelineStage.build);
  assert("test".toPipelineStage == PipelineStage.test);
  assert("deploy".toPipelineStage == PipelineStage.deploy);
  assert("full".toPipelineStage == PipelineStage.full);
  assert("unknown".toPipelineStage == PipelineStage.build); // default

  assert(PipelineStage.build.toString == "build");
  assert(PipelineStage.test.toString == "test");
  assert(PipelineStage.deploy.toString == "deploy");
  assert(PipelineStage.full.toString == "full");  

  assert(["build", "deploy"].toPipelineStage == [PipelineStage.build, PipelineStage.deploy]);
  assert([PipelineStage.build, PipelineStage.deploy].toString == ["build", "deploy"]);
}

/// Status of a pipeline run or build job
enum JobStatus : string {
  queued     = "queued",
  running    = "running",
  succeeded  = "succeeded",
  failed     = "failed",
  cancelled  = "cancelled"
}
JobStatus toJobStatus(string value) {
  mixin(EnumSwitch("JobStatus", "JobStatus.queued"));
}
JobStatus[] toJobStatus(string[] values) {
  return values.map!(v => v.toJobStatus).array;
}
string toString(JobStatus value) {
  return value.to!string();
}
string[] toStrings(JobStatus[] values) {
  return values.map!(v => v.toString()).array;
}
///
unittest {
  mixin(ShowTest!("JobStatus"));

  assert("queued".toJobStatus == JobStatus.queued);
  assert("running".toJobStatus == JobStatus.running);
  assert("succeeded".toJobStatus == JobStatus.succeeded);
  assert("failed".toJobStatus == JobStatus.failed);
  assert("cancelled".toJobStatus == JobStatus.cancelled);
  assert("unknown".toJobStatus == JobStatus.queued); // default

  assert(JobStatus.queued.toString == "queued");
  assert(JobStatus.running.toString == "running");
  assert(JobStatus.succeeded.toString == "succeeded");
  assert(JobStatus.failed.toString == "failed");
  assert(JobStatus.cancelled.toString == "cancelled");

  assert(["queued", "failed"].toJobStatus == [JobStatus.queued, JobStatus.failed]);
  assert([JobStatus.queued, JobStatus.failed].toString == ["queued", "failed"]);
}

/// Target environment for deployments
enum DeploymentEnvironment : string {
  cloudFoundry = "cloud-foundry",
  kyma         = "kyma",
  abapCloud    = "abap-cloud",
  neo          = "neo",
  other        = "other"
}
DeploymentEnvironment toDeploymentEnvironment(string value) {
  mixin(EnumSwitch("DeploymentEnvironment", "DeploymentEnvironment.other"));
}
DeploymentEnvironment[] toDeploymentEnvironment(string[] values) {
  return values.map!(v => v.toDeploymentEnvironment).array;
}
string toString(DeploymentEnvironment value) {
  return value.to!string();
}
string[] toStrings(DeploymentEnvironment[] values) {
  return values.map!(v => v.toString()).array;
}
///
unittest {
  mixin(ShowTest!("DeploymentEnvironment"));

  assert("cloud-foundry".toDeploymentEnvironment == DeploymentEnvironment.cloudFoundry);
  assert("kyma".toDeploymentEnvironment == DeploymentEnvironment.kyma);
  assert("abap-cloud".toDeploymentEnvironment == DeploymentEnvironment.abapCloud);
  assert("neo".toDeploymentEnvironment == DeploymentEnvironment.neo);
  assert("other".toDeploymentEnvironment == DeploymentEnvironment.other);
  assert("unknown".toDeploymentEnvironment == DeploymentEnvironment.other); 

  assert(DeploymentEnvironment.cloudFoundry.toString == "cloud-foundry");
  assert(DeploymentEnvironment.kyma.toString == "kyma");
  assert(DeploymentEnvironment.abapCloud.toString == "abap-cloud");
  assert(DeploymentEnvironment.neo.toString == "neo");
  assert(DeploymentEnvironment.other.toString == "other");

  assert(["cloud-foundry", "kyma"].toDeploymentEnvironment == [DeploymentEnvironment.cloudFoundry, DeploymentEnvironment.kyma]);
  assert([DeploymentEnvironment.cloudFoundry, DeploymentEnvironment.kyma].toString == ["cloud-foundry", "kyma"]);
}

/// Status of a deployment
enum DeploymentStatus : string {
  pending    = "pending",
  deploying  = "deploying",
  succeeded  = "succeeded",
  failed     = "failed",
  rolling_back = "rolling-back"
}
DeploymentStatus toDeploymentStatus(string value) {
  mixin(EnumSwitch("DeploymentStatus", "DeploymentStatus.pending"));
}
DeploymentStatus[] toDeploymentStatus(string[] values) {
  return values.map!(v => v.toDeploymentStatus).array;
}
string toString(DeploymentStatus value) {
  return value.to!string();
}
string[] toStrings(DeploymentStatus[] values) {
  return values.map!(v => v.toString()).array;
}
///
unittest {
  mixin(ShowTest!("DeploymentStatus"));

  assert("pending".toDeploymentStatus == DeploymentStatus.pending);
  assert("deploying".toDeploymentStatus == DeploymentStatus.deploying);
  assert("succeeded".toDeploymentStatus == DeploymentStatus.succeeded);
  assert("failed".toDeploymentStatus == DeploymentStatus.failed);
  assert("rolling-back".toDeploymentStatus == DeploymentStatus.rolling_back);
  assert("unknown".toDeploymentStatus == DeploymentStatus.pending); // default

  assert(DeploymentStatus.pending.toString == "pending");
  assert(DeploymentStatus.deploying.toString == "deploying");
  assert(DeploymentStatus.succeeded.toString == "succeeded");
  assert(DeploymentStatus.failed.toString == "failed");
  assert(DeploymentStatus.rolling_back.toString == "rolling-back"); 

  assert(["pending", "succeeded"].toDeploymentStatus == [DeploymentStatus.pending, DeploymentStatus.succeeded]);
  assert([DeploymentStatus.pending, DeploymentStatus.succeeded].toString == ["pending", "succeeded"]);
}

/// Status of an AI code generation request
enum AIRequestStatus : string {
  pending    = "pending",
  processing = "processing",
  completed  = "completed",
  failed     = "failed"
}
AIRequestStatus toAIRequestStatus(string value) {
  mixin(EnumSwitch("AIRequestStatus", "AIRequestStatus.pending"));
}
AIRequestStatus[] toAIRequestStatus(string[] values) {
  return values.map!(v => v.toAIRequestStatus).array;
}
string toString(AIRequestStatus value) {
  return value.to!string();
}
string[] toStrings(AIRequestStatus[] values) {
  return values.map!(v => v.toString()).array;
}
///
unittest {
  mixin(ShowTest!("AIRequestStatus"));

  assert("pending".toAIRequestStatus == AIRequestStatus.pending);
  assert("processing".toAIRequestStatus == AIRequestStatus.processing);
  assert("completed".toAIRequestStatus == AIRequestStatus.completed);
  assert("failed".toAIRequestStatus == AIRequestStatus.failed);
  assert("unknown".toAIRequestStatus == AIRequestStatus.pending); // default  

  assert(AIRequestStatus.pending.toString == "pending");
  assert(AIRequestStatus.processing.toString == "processing");
  assert(AIRequestStatus.completed.toString == "completed");
  assert(AIRequestStatus.failed.toString == "failed");  

  assert(["pending", "completed"].toAIRequestStatus == [AIRequestStatus.pending, AIRequestStatus.completed]);
  assert([AIRequestStatus.pending, AIRequestStatus.completed].toString == ["pending", "completed"]);
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
AIGenerationType toAIGenerationType(string value) {
  mixin(EnumSwitch("AIGenerationType", "AIGenerationType.codeFragment"));
}
AIGenerationType[] toAIGenerationType(string[] values) {
  return values.map!(v => v.toAIGenerationType).array;
}
string toString(AIGenerationType value) {
  return value.to!string();
}
string[] toStrings(AIGenerationType[] values) {
  return values.map!(v => v.toString()).array;
}
///
unittest {
  mixin(ShowTest!("AIGenerationType"));

  assert("data-model".toAIGenerationType == AIGenerationType.dataModel);
  assert("service".toAIGenerationType == AIGenerationType.service);
  assert("sample-data".toAIGenerationType == AIGenerationType.sampleData);
  assert("ui-page".toAIGenerationType == AIGenerationType.uitPage);
  assert("code-fragment".toAIGenerationType == AIGenerationType.codeFragment);
  assert("full-app".toAIGenerationType == AIGenerationType.fullApp);
  assert("unknown".toAIGenerationType == AIGenerationType.codeFragment); // default

  assert(AIGenerationType.dataModel.toString == "data-model");
  assert(AIGenerationType.service.toString == "service");
  assert(AIGenerationType.sampleData.toString == "sample-data");
  assert(AIGenerationType.uitPage.toString == "ui-page");
  assert(AIGenerationType.codeFragment.toString == "code-fragment");
  assert(AIGenerationType.fullApp.toString == "full-app");

  assert(["data-model", "service"].toAIGenerationType == [AIGenerationType.dataModel, AIGenerationType.service]);
  assert([AIGenerationType.dataModel, AIGenerationType.service].toString == ["data-model", "service"]);
}

/// State of a service binding
enum BindingStatus : string {
  active    = "active",
  inactive_ = "inactive",
  error_    = "error"
}
BindingStatus toBindingStatus(string value) {
  mixin(EnumSwitch("BindingStatus", "BindingStatus.inactive_"));
}
BindingStatus[] toBindingStatus(string[] values) {
  return values.map!(v => v.toBindingStatus).array;
}
string toString(BindingStatus value) {
  return value.to!string();
}
string[] toStrings(BindingStatus[] values) {
  return values.map!(v => v.toString()).array;
}
///
unittest {
  mixin(ShowTest!("BindingStatus"));

  assert("active".toBindingStatus == BindingStatus.active);
  assert("inactive".toBindingStatus == BindingStatus.inactive_);
  assert("error".toBindingStatus == BindingStatus.error_);
  assert("unknown".toBindingStatus == BindingStatus.inactive_); // default  

  assert(BindingStatus.active.toString == "active");
  assert(BindingStatus.inactive_.toString == "inactive");
  assert(BindingStatus.error_.toString == "error"); 

  assert(["active", "inactive"].toBindingStatus == [BindingStatus.active, BindingStatus.inactive_]);
  assert([BindingStatus.active, BindingStatus.inactive_].toString == ["active", "inactive"]);
}
