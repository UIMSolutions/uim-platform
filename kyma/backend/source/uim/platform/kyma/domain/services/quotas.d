/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.kyma.domain.services.quotas;

import uim.platform.kyma;

mixin(ShowModule!());

@safe:

/// Validate a request/limit pair of CPU and memory quantities.
void validateResources(string context, string cpuRequest, string cpuLimit,
    string memoryRequest, string memoryLimit) {
  auto cpuReq = parseCpuMillis(cpuRequest), cpuLim = parseCpuMillis(cpuLimit);
  auto memReq = parseMemoryBytes(memoryRequest), memLim = parseMemoryBytes(memoryLimit);

  validate(cpuReq != quantityInvalid, context ~ ": invalid CPU request '" ~ cpuRequest ~ "' (e.g. 100m, 0.5, 1)");
  validate(cpuLim != quantityInvalid, context ~ ": invalid CPU limit '" ~ cpuLimit ~ "'");
  validate(memReq != quantityInvalid, context ~ ": invalid memory request '" ~ memoryRequest ~ "' (e.g. 128Mi, 1Gi)");
  validate(memLim != quantityInvalid, context ~ ": invalid memory limit '" ~ memoryLimit ~ "'");
  if (cpuReq >= 0 && cpuLim >= 0)
    validate(cpuReq <= cpuLim, context ~ ": CPU request must not exceed the CPU limit");
  if (memReq >= 0 && memLim >= 0)
    validate(memReq <= memLim, context ~ ": memory request must not exceed the memory limit");
}

///
unittest {
  validateResources("x", "100m", "500m", "64Mi", "128Mi");
  validateResources("x", "", "", "", "");
  bool failed;
  try validateResources("x", "1", "500m", "", "");
  catch (KymaValidationException) failed = true;
  assert(failed);
}
