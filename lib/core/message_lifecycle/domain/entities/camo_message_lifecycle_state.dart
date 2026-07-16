enum CamoMessageLifecycleState { active, consumed, revoked, deleted }

extension CamoMessageLifecycleStateContract on CamoMessageLifecycleState {
  bool get isTerminal => this != CamoMessageLifecycleState.active;
}
