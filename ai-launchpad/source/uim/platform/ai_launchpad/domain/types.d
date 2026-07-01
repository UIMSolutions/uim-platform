/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.ai_launchpad.domain.types;

import uim.platform.ai_launchpad;

mixin(ShowModule!());

@safe:

// ID aliases

struct ArtifactId {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin IdTemplate;
}
struct WorkspaceId {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin IdTemplate;
}

struct ScenarioId {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin IdTemplate;
}

struct ConfigurationId {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin IdTemplate;
}

struct ExecutionId {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin IdTemplate;
}

struct DeploymentId {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin IdTemplate;
}

struct ModelId {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin IdTemplate;
}

struct DatasetId {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin IdTemplate;
}

struct PromptId {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin IdTemplate;
}

struct PromptCollectionId {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin IdTemplate;
}

struct ResourceGroupId {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin IdTemplate;
}

struct UsageStatisticId {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin IdTemplate;
}
