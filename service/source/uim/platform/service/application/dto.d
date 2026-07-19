module uim.platform.service.application.dto;

import uim.platform.service;
mixin(ShowModule!());
@safe:
/// CommandResult represents the result of a command execution.
struct CommandResult {
  /// Indicates whether the command was successful.
  bool success;
  /// The ID of the resource affected by the command, if applicable.
  string id;
  /// A message providing additional information about the command result.
  string message;
  /// An optional error code associated with the command result.
  size_t code;
  ///
  this(bool success, string id = "", string message = "", size_t code = 0) {
    this.success = success;
    this.id = id;
    this.message = message;
    this.code = code;
  }

  bool isSuccess() const {
    return success;
  }

  bool hasError() const {
    return !success && message.length > 0;
  }

  string errorMessage() const {
    return hasError() ? message : "";
  }

  Json toJson() const {
    return Json.emptyObject
        .set("success", success)
        .set("id", id)
        .set("message", message)
        .set("code", code);
  }
}
///
unittest {
  mixin(ShowTest!("CommandResult"));

  CommandResult r1 = CommandResult(true, "123", "");
  assert(r1.isSuccess());
  assert(!r1.hasError());
  assert(r1.id == "123");
  assert(r1.message == "");

  CommandResult r2 = CommandResult(false, "", "Something went wrong");
  assert(!r2.isSuccess());
  assert(r2.hasError());
  assert(r2.id == "");
  assert(r2.message == "Something went wrong");

  CommandResult r3 = CommandResult(false, "", "Error occurred", 404);
  assert(!r3.isSuccess());
  assert(r3.hasError());
  assert(r3.id == "");
  assert(r3.message == "Error occurred");
  assert(r3.code == 404);
}
