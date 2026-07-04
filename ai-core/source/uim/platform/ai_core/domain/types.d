/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.ai_core.domain.types;

import uim.platform.ai_core;

mixin(ShowModule!()); 

@safe:
// ID aliases
struct ScenarioId {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin IdTemplate;
}

struct ExecutableId {
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

struct ArtifactId {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin IdTemplate;
}

struct ResourceGroupId  {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin IdTemplate;
}
struct MetricId  {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin IdTemplate;
}

struct DockerRegistrySecretId  {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin IdTemplate;
}
struct ObjectStoreSecretId  {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin IdTemplate;
}

struct ScheduleId {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin IdTemplate;
}