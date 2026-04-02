module domain.types;

// --- Type aliases ---
alias DatasetId = string;
alias DataRecordId = string;
alias ModelConfigId = string;
alias TrainingJobId = string;
alias DeploymentId = string;
alias InferenceRequestId = string;
alias InferenceResultId = string;
alias TenantId = string;
alias UserId = string;

// --- Enums ---

enum DatasetStatus
{
  draft,
  ready,
  processing,
  completed,
  failed
}

enum DataType
{
  product,
  material,
  customer,
  supplier,
  custom
}

enum RecordStatus
{
  pending,
  validated,
  rejected
}

enum ModelType
{
  classification,
  regression,
  recommendation
}

enum ModelConfigStatus
{
  draft,
  ready,
  training,
  trained,
  failed
}

enum JobStatus
{
  queued,
  running,
  completed,
  failed,
  cancelled
}

enum DeploymentStatus
{
  deploying,
  active,
  inactive,
  failed
}

enum InferenceStatus
{
  pending,
  processing,
  completed,
  failed
}
