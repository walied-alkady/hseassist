enum HazardStatus{
initial,
eliminated, // hazard is physically removed
substituted, // hazard is replaced 
engineeringControlled, // isolate the hazard from people
adminControlled, // change the way people work
ppe, // personal protective equipment
}

extension HazardStatusX on HazardStatus {
  /// Indicates whether the form has not yet been submitted.
  bool get isInitial => this == HazardStatus.initial;

  bool get isEliminated => this == HazardStatus.eliminated;

  bool get isSubstituted => this == HazardStatus.substituted;

  bool get isEngineeringControlled => this == HazardStatus.engineeringControlled;

  bool get isAdminControlled => this == HazardStatus.adminControlled;

  bool get isPPE => this == HazardStatus.ppe;


  bool get isControlled => isEngineeringControlled || isAdminControlled;

}