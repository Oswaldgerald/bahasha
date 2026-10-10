class AuthMember {
  const AuthMember({
    required this.id,
    required this.fullName,
    required this.approvalStatus,
  });

  final String id;
  final String fullName;
  final String approvalStatus;

  factory AuthMember.fromJson(Map<String, dynamic> json) {
    return AuthMember(
      id: json['id']?.toString() ?? '',
      fullName: json['full_name']?.toString() ?? '',
      approvalStatus: json['approval_status']?.toString() ?? '',
    );
  }
}

class AuthSession {
  const AuthSession({
    required this.accessToken,
    required this.refreshToken,
    required this.member,
  });

  final String accessToken;
  final String refreshToken;
  final AuthMember member;

  factory AuthSession.fromTokenResponse(Map<String, dynamic> json) {
    final accessToken = json['access_token']?.toString() ?? '';
    final refreshToken = json['refresh_token']?.toString() ?? '';
    final memberJson = json['member'];
    if (accessToken.isEmpty ||
        refreshToken.isEmpty ||
        memberJson is! Map<String, dynamic>) {
      throw const FormatException('The authentication response is incomplete.');
    }
    return AuthSession(
      accessToken: accessToken,
      refreshToken: refreshToken,
      member: AuthMember.fromJson(memberJson),
    );
  }
}
