module uim.platform.service.application.dto;

@safe:
struct CommandResult {
  bool success;
  string id;
  string error;

  bool isSuccess() const {
    return success;
  }

  bool isFailure() const {
    return !success;
  }

}

