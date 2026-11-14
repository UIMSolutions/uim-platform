/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.translation.domain.enumerations.jobs;

import uim.platform.translation;

mixin(ShowModule!());

@safe:

/// Kind of asynchronous translation job.
enum JobType {
  text, /// one text block
  document, /// a document (content + contentType)
  software, /// all texts of a translation project
}

/// Lifecycle of an asynchronous translation job.
enum JobStatus {
  pending,
  processing,
  completed,
  failed,
  cancelled,
}
