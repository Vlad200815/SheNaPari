enum SessionStatus {
  /// The stored session has not been read yet (app start).
  unknown,

  unauthenticated,

  /// Signed in, but the profile is not filled in yet
  /// (`isNewUser = true` in docs/api-contract.md §5).
  needsProfile,

  authenticated,
}
