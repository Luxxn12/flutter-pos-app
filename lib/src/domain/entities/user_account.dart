class UserAccount {
  final String id;
  final String name;
  final String email;
  final String role;
  final DateTime? createdAt;

  const UserAccount({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.createdAt,
  });

  factory UserAccount.fromMap(Map<String, dynamic> map) {
    return UserAccount(
      id: map['id'] as String,
      name: (map['name'] as String?) ?? '-',
      email: (map['email'] as String?) ?? '-',
      role: (map['role'] as String?) ?? 'cashier',
      createdAt: map['created_at'] == null
          ? null
          : DateTime.tryParse(map['created_at'].toString()),
    );
  }
}
