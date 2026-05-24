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

  mixin DomainId;
}
struct WorkspaceId {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin DomainId;
}

struct ScenarioId {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin DomainId;
}

struct ConfigurationId {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin DomainId;
}

struct ExecutionId {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin DomainId;
}

struct DeploymentId {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin DomainId;
}

struct ModelId {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin DomainId;
}

struct DatasetId {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin DomainId;
}

struct PromptId {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin DomainId;
}

struct PromptCollectionId {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin DomainId;
}

struct ResourceGroupId {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin DomainId;
}

struct UsageStatisticId {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin DomainId;
}
