module uim.platform.service.application.dto;

import uim.platform.service;

mixin(ShowModule!());
@safe:
struct CommandResult {
  bool success;
  string id;
  string error;

  bool isSuccess() const {
    return success;
  }

  bool failure() const {
    return !success;
  }

}
///
unittest {
  import std.stdio;

  CommandResult r1 = CommandResult(true, "123", "");
  assert(r1.isSuccess);
  assert(!r1.failure);
  assert(r1.id == "123");
  assert(r1.error == "");

  CommandResult r2 = CommandResult(false, "", "Something went wrong");
  assert(!r2.isSuccess);
  assert(r2.failure);
  assert(r2.id == "");
  assert(r2.error == "Something went wrong");
}
