/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data_attribute_recommendation.domain.enumerations;

import uim.platform.data_attribute_recommendation;

mixin(ShowModule!());

@safe:

enum DatasetStatus {
  draft,
  ready,
  processing,
  completed,
  failed
}
DatasetStatus toDatasetStatus(string value) {
  mixin(EnumSwitch("DatasetStatus", "draft"));
}
DatasetStatus[] toDatasetStatuses(string[] values) {
  return values.map!(toDatasetStatus).array;
}
string toString(DatasetStatus status) {
  return status.to!string;
}
string[] toStrings(DatasetStatus[] statuses) {
  return statuses.map!toString.array;
}
/// 
unittest {
  mixin(ShowTest!("DatasetStatus"));

  assert(DatasetStatus.draft.to!string == "draft");
  assert(DatasetStatus.ready.to!string == "ready");
  assert(DatasetStatus.processing.to!string == "processing");
  assert(DatasetStatus.completed.to!string == "completed");
  assert(DatasetStatus.failed.to!string == "failed");

  assert("draft".to!DatasetStatus == DatasetStatus.draft);
  assert("ready".to!DatasetStatus == DatasetStatus.ready);
  assert("processing".to!DatasetStatus == DatasetStatus.processing);
  assert("completed".to!DatasetStatus == DatasetStatus.completed);
  assert("failed".to!DatasetStatus == DatasetStatus.failed);

  assert("draft".toDatasetStatus == DatasetStatus.draft);
  assert("ready".toDatasetStatus == DatasetStatus.ready);
  assert("processing".toDatasetStatus == DatasetStatus.processing);
  assert("completed".toDatasetStatus == DatasetStatus.completed);
  assert("failed".toDatasetStatus == DatasetStatus.failed);
  
  assert("noexists".toDatasetStatus == DatasetStatus.draft); // Default case
  assert("".toDatasetStatus == DatasetStatus.draft); // Default case

  assert(DatasetStatus.draft.toString == "draft");
  assert(DatasetStatus.ready.toString == "ready");
  assert(DatasetStatus.processing.toString == "processing");
  assert(DatasetStatus.completed.toString == "completed");
  assert(DatasetStatus.failed.toString == "failed");

  assert(["draft", "ready", "processing", "completed", "failed"].toDatasetStatuses ==
         [DatasetStatus.draft, DatasetStatus.ready, DatasetStatus.processing, DatasetStatus.completed, DatasetStatus.failed]);
  assert(toStrings([DatasetStatus.draft, DatasetStatus.ready, DatasetStatus.processing, DatasetStatus.completed, DatasetStatus.failed]) ==
         ["draft", "ready", "processing", "completed", "failed"]);
}

enum DataType {
  product,
  material,
  customer,
  supplier,
  custom
}

DataType toDataType(string value) {
  mixin(EnumSwitch("DataType", "custom"));
}

DataType[] toDataTypes(string[] values) {
  return values.map!(toDataType).array;
}

string toString(DataType dataType) {
  return dataType.to!string;
}

string[] toStrings(DataType[] dataTypes) {
  return dataTypes.map!toString.array;
}

/// 
unittest {
  mixin(ShowTest!("DataType"));

  assert(DataType.product.to!string == "product");
  assert(DataType.material.to!string == "material");
  assert(DataType.customer.to!string == "customer");
  assert(DataType.supplier.to!string == "supplier");
  assert(DataType.custom.to!string == "custom");

  assert("product".to!DataType == DataType.product);
  assert("material".to!DataType == DataType.material);
  assert("customer".to!DataType == DataType.customer);
  assert("supplier".to!DataType == DataType.supplier);
  assert("custom".to!DataType == DataType.custom);

  assert("product".toDataType == DataType.product);
  assert("material".toDataType == DataType.material);
  assert("customer".toDataType == DataType.customer);
  assert("supplier".toDataType == DataType.supplier);
  assert("custom".toDataType == DataType.custom);

  assert("noexists".toDataType == DataType.custom); // Default case
  assert("".toDataType == DataType.custom); // Default case

  assert(DataType.product.toString == "product");
  assert(DataType.material.toString == "material");
  assert(DataType.customer.toString == "customer");
  assert(DataType.supplier.toString == "supplier");
  assert(DataType.custom.toString == "custom");

  assert(["product", "material", "customer", "supplier", "custom"].toDataTypes ==
         [DataType.product, DataType.material, DataType.customer, DataType.supplier, DataType.custom]);
  assert(toStrings([DataType.product, DataType.material, DataType.customer, DataType.supplier, DataType.custom]) ==
         ["product", "material", "customer", "supplier", "custom"]);
}


enum RecordStatus {
  pending,
  validated,
  rejected
}
RecordStatus toRecordStatus(string value) {
  mixin(EnumSwitch("RecordStatus", "pending"));
}

RecordStatus[] toRecordStatuses(string[] values)
  => values.map!(toRecordStatus).array;

string toString(RecordStatus status)
  => status.to!string;

string[] toStrings(RecordStatus[] statuses)
  => statuses.map!toString.array;

/// 
unittest {
  mixin(ShowTest!("RecordStatus"));

  assert(RecordStatus.pending.to!string == "pending");
  assert(RecordStatus.validated.to!string == "validated");
  assert(RecordStatus.rejected.to!string == "rejected");

  assert("pending".to!RecordStatus == RecordStatus.pending);
  assert("validated".to!RecordStatus == RecordStatus.validated);
  assert("rejected".to!RecordStatus == RecordStatus.rejected);

  assert("pending".toRecordStatus == RecordStatus.pending);
  assert("validated".toRecordStatus == RecordStatus.validated);
  assert("rejected".toRecordStatus == RecordStatus.rejected);

  assert("noexists".toRecordStatus == RecordStatus.pending); // Default case
  assert("".toRecordStatus == RecordStatus.pending); // Default case

  assert(RecordStatus.pending.toString == "pending");
  assert(RecordStatus.validated.toString == "validated");
  assert(RecordStatus.rejected.toString == "rejected");

  assert(["pending", "validated", "rejected"].toRecordStatuses ==
         [RecordStatus.pending, RecordStatus.validated, RecordStatus.rejected]);
  assert(toStrings([RecordStatus.pending, RecordStatus.validated, RecordStatus.rejected]) ==
         ["pending", "validated", "rejected"]);
}

enum ModelType {
  classification,
  regression,
  recommendation
}

ModelType toModelType(string value) {
  mixin(EnumSwitch("ModelType", "classification"));
}

ModelType[] toModelTypes(string[] values)
  => values.map!(toModelType).array;

string toString(ModelType value)
  => value.to!string;

string[] toStrings(ModelType[] values)
  => values.map!toString.array;

///
unittest {
  mixin(ShowTest!("ModelType"));

  assert("classification".toModelType == ModelType.classification);
  assert("regression".toModelType == ModelType.regression);
  assert("recommendation".toModelType == ModelType.recommendation);

  assert("".toModelType == ModelType.classification);
  assert("unknown".toModelType == ModelType.classification);

  assert(ModelType.classification.toString == "classification");
  assert(ModelType.regression.toString == "regression");
  assert(ModelType.recommendation.toString == "recommendation");

  assert(["classification", "recommendation"].toModelTypes == [
      ModelType.classification, ModelType.recommendation
    ]);
  assert([ModelType.classification, ModelType.recommendation].toStrings == [
      "classification", "recommendation"
    ]);
}

enum ModelConfigStatus {
  draft,
  ready,
  training,
  trained,
  failed
}
ModelConfigStatus toModelConfigStatus(string value) {
  mixin(EnumSwitch("ModelConfigStatus", "draft"));
}

ModelConfigStatus[] toModelConfigStatuses(string[] values)
  => values.map!(toModelConfigStatus).array;

string toString(ModelConfigStatus value)
  => value.to!string;

string[] toStrings(ModelConfigStatus[] values)
  => values.map!toString.array;

///
unittest {
  mixin(ShowTest!("ModelConfigStatus"));

  assert("draft".toModelConfigStatus == ModelConfigStatus.draft);
  assert("ready".toModelConfigStatus == ModelConfigStatus.ready);
  assert("training".toModelConfigStatus == ModelConfigStatus.training);
  assert("trained".toModelConfigStatus == ModelConfigStatus.trained);
  assert("failed".toModelConfigStatus == ModelConfigStatus.failed);

  assert("".toModelConfigStatus == ModelConfigStatus.draft);
  assert("unknown".toModelConfigStatus == ModelConfigStatus.draft);

  assert(ModelConfigStatus.draft.toString == "draft");
  assert(ModelConfigStatus.ready.toString == "ready");
  assert(ModelConfigStatus.training.toString == "training");
  assert(ModelConfigStatus.trained.toString == "trained");
  assert(ModelConfigStatus.failed.toString == "failed");

  assert(["draft", "ready", "training", "trained", "failed"].toModelConfigStatuses ==
         [ModelConfigStatus.draft, ModelConfigStatus.ready, ModelConfigStatus.training, ModelConfigStatus.trained, ModelConfigStatus.failed]);
  assert(toStrings([ModelConfigStatus.draft, ModelConfigStatus.ready, ModelConfigStatus.training, ModelConfigStatus.trained, ModelConfigStatus.failed]) ==
         ["draft", "ready", "training", "trained", "failed"]);
}

enum JobStatus {
  queued,
  running,
  completed,
  failed,
  cancelled
}

JobStatus toJobStatus(string value) {
 mixin(EnumSwitch("JobStatus", "queued"));
}

JobStatus[] toJobStatuses(string[] values)
  => values.map!(toJobStatus).array;

string toString(JobStatus value)
  => value.to!string;

string[] toStrings(JobStatus[] values)
  => values.map!toString.array;

/// 
unittest {
  mixin(ShowTest!("JobStatus"));

  assert(JobStatus.queued.to!string == "queued");
  assert(JobStatus.running.to!string == "running");
  assert(JobStatus.completed.to!string == "completed");
  assert(JobStatus.failed.to!string == "failed");
  assert(JobStatus.cancelled.to!string == "cancelled");

  assert("queued".to!JobStatus == JobStatus.queued);
  assert("running".to!JobStatus == JobStatus.running);
  assert("completed".to!JobStatus == JobStatus.completed);
  assert("failed".to!JobStatus == JobStatus.failed);
  assert("cancelled".to!JobStatus == JobStatus.cancelled);

  assert("queued".toJobStatus == JobStatus.queued);
  assert("running".toJobStatus == JobStatus.running);
  assert("completed".toJobStatus == JobStatus.completed);
  assert("failed".toJobStatus == JobStatus.failed);
  assert("cancelled".toJobStatus == JobStatus.cancelled);

  assert("noexists".toJobStatus == JobStatus.queued); // Default case
  assert("".toJobStatus == JobStatus.queued); // Default case

  assert(JobStatus.queued.toString == "queued");
  assert(JobStatus.running.toString == "running");
  assert(JobStatus.completed.toString == "completed");
  assert(JobStatus.failed.toString == "failed");
  assert(JobStatus.cancelled.toString == "cancelled");

  assert(["queued", "running", "completed", "failed", "cancelled"].toJobStatuses ==
         [JobStatus.queued, JobStatus.running, JobStatus.completed, JobStatus.failed, JobStatus.cancelled]);
  assert(toStrings([JobStatus.queued, JobStatus.running, JobStatus.completed, JobStatus.failed, JobStatus.cancelled]) ==
         ["queued", "running", "completed", "failed", "cancelled"]);
}

enum DeploymentStatus {
  deploying,
  active,
  inactive,
  failed
}

DeploymentStatus toDeploymentStatus(string value) {
  mixin(EnumSwitch("DeploymentStatus", "deploying"));
}

DeploymentStatus[] toDeploymentStatuses(string[] values)
  => values.map!(toDeploymentStatus).array;

string toString(DeploymentStatus value)
  => value.to!string;

string[] toStrings(DeploymentStatus[] values)
  => values.map!toString.array;

/// 
unittest {
  mixin(ShowTest!("DeploymentStatus"));

  assert(DeploymentStatus.deploying.to!string == "deploying");
  assert(DeploymentStatus.active.to!string == "active");
  assert(DeploymentStatus.inactive.to!string == "inactive");
  assert(DeploymentStatus.failed.to!string == "failed");

  assert("deploying".to!DeploymentStatus == DeploymentStatus.deploying);
  assert("active".to!DeploymentStatus == DeploymentStatus.active);
  assert("inactive".to!DeploymentStatus == DeploymentStatus.inactive);
  assert("failed".to!DeploymentStatus == DeploymentStatus.failed);

  assert("deploying".toDeploymentStatus == DeploymentStatus.deploying);
  assert("active".toDeploymentStatus == DeploymentStatus.active);
  assert("inactive".toDeploymentStatus == DeploymentStatus.inactive);
  assert("failed".toDeploymentStatus == DeploymentStatus.failed);

  assert("noexists".toDeploymentStatus == DeploymentStatus.deploying); // Default case
  assert("".toDeploymentStatus == DeploymentStatus.deploying); // Default case

  assert(DeploymentStatus.deploying.toString == "deploying");
  assert(DeploymentStatus.active.toString == "active");
  assert(DeploymentStatus.inactive.toString == "inactive");
  assert(DeploymentStatus.failed.toString == "failed");

  assert(["deploying", "active", "inactive", "failed"].toDeploymentStatuses ==
         [DeploymentStatus.deploying, DeploymentStatus.active, DeploymentStatus.inactive, DeploymentStatus.failed]);
  assert(toStrings([DeploymentStatus.deploying, DeploymentStatus.active, DeploymentStatus.inactive, DeploymentStatus.failed]) ==
         ["deploying", "active", "inactive", "failed"]);
}

enum InferenceStatus {
  pending,
  processing,
  completed,
  failed
}

InferenceStatus toInferenceStatus(string value) {
  mixin(EnumSwitch("InferenceStatus", "pending"));
}

InferenceStatus[] toInferenceStatuses(string[] values)
  => values.map!(toInferenceStatus).array;

string toString(InferenceStatus value)
  => value.to!string;

string[] toStrings(InferenceStatus[] values)
  => values.map!toString.array;

///
unittest {
  mixin(ShowTest!("InferenceStatus"));

  assert(InferenceStatus.pending.to!string == "pending");
  assert(InferenceStatus.processing.to!string == "processing");
  assert(InferenceStatus.completed.to!string == "completed");
  assert(InferenceStatus.failed.to!string == "failed");

  assert("pending".to!InferenceStatus == InferenceStatus.pending);
  assert("processing".to!InferenceStatus == InferenceStatus.processing);
  assert("completed".to!InferenceStatus == InferenceStatus.completed);
  assert("failed".to!InferenceStatus == InferenceStatus.failed);

  assert("pending".toInferenceStatus == InferenceStatus.pending);
  assert("processing".toInferenceStatus == InferenceStatus.processing);
  assert("completed".toInferenceStatus == InferenceStatus.completed);
  assert("failed".toInferenceStatus == InferenceStatus.failed);

  assert("noexists".toInferenceStatus == InferenceStatus.pending); // Default case
  assert("".toInferenceStatus == InferenceStatus.pending); // Default case

  assert(InferenceStatus.pending.toString == "pending");
  assert(InferenceStatus.processing.toString == "processing");
  assert(InferenceStatus.completed.toString == "completed");
  assert(InferenceStatus.failed.toString == "failed");

  assert(["pending", "processing", "completed", "failed"].toInferenceStatuses ==
         [InferenceStatus.pending, InferenceStatus.processing, InferenceStatus.completed, InferenceStatus.failed]);
  assert(toStrings([InferenceStatus.pending, InferenceStatus.processing, InferenceStatus.completed, InferenceStatus.failed]) ==
         ["pending", "processing", "completed", "failed"]);
}