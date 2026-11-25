/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Driven port that calls the action endpoint of a job (HTTP client
/// adapter in infrastructure/clients; a recording fake in tests).
module uim.platform.job_scheduling.ports.gateways.invoker;

import uim.platform.job_scheduling;

mixin(ShowModule!());

@safe:

struct InvocationRequest {
  string url;
  JobHttpMethod method = JobHttpMethod.post;
  string body; /// JSON text ("" = no body)
  string[string] headers; /// x-sap-job-id, x-sap-job-schedule-id, x-sap-job-run-id, …
  int timeoutSeconds = 30;
}

struct InvocationResult {
  bool reached; /// false: connection refused, timeout, DNS, TLS, blocked host, …
  int status; /// HTTP status (0 if not reached)
  string message; /// reason phrase, start of the response body or the error

  bool succeeded() const {
    return reached && status >= 200 && status < 300;
  }

  bool accepted() const {
    return reached && status == 202;
  }
}

interface IJobInvoker {
  /// Never throws: failures are reported in the result.
  InvocationResult invoke(InvocationRequest request);
}
