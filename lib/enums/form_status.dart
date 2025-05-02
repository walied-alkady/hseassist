enum FormStatus{
initial,
inProgress,
success,
failure,
canceled,
valide,
inValid,
imagePreview
}
/// Useful extensions on [FormStatus]
extension FormStatusX on FormStatus {
  /// Indicates whether the form has not yet been submitted.
  bool get isInitial => this == FormStatus.initial;

  /// Indicates whether the form is in the process of being submitted.
  bool get isInProgress => this == FormStatus.inProgress;

  /// Indicates whether the form has been submitted successfully.
  bool get isSuccess => this == FormStatus.success;

  /// Indicates whether the form submission failed.
  bool get isFailure => this == FormStatus.failure;

  /// Indicates whether the form submission has been canceled.
  bool get isCanceled => this == FormStatus.canceled;

  /// Indicates whether the form is either in progress or has been submitted
  /// successfully.
  ///
  /// This is useful for showing a loading indicator or disabling the submit
  /// button to prevent duplicate submissions.
  bool get isInProgressOrSuccess => isInProgress || isSuccess;

  /// Indicates whether the form is valid.
  bool get isValide => this == FormStatus.valide;
    /// Indicates whether the form is invalid.
  bool get isInValide => this == FormStatus.inValid;
}