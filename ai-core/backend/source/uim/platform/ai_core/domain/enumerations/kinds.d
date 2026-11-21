/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Classifications.
module uim.platform.ai_core.domain.enumerations.kinds;

import uim.platform.ai_core;

mixin(ShowModule!());

@safe:

/// Kind of an artifact (AI API values).
enum ArtifactKind : string {
  model = "model",
  dataset = "dataset",
  resultset = "resultset",
  other = "other"
}

/// Executables are either batch workflows (→ executions) or serving
/// templates (→ deployments).
enum ExecutableType : string {
  workflow = "workflow",
  serving = "serving"
}

/// Storage technology of an object store secret.
enum ObjectStoreType : string {
  s3 = "S3",
  gcs = "GCS",
  azure = "AZURE",
  webhdfs = "WEBHDFS"
}
