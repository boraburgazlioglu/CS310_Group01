import 'package:cloud_firestore/cloud_firestore.dart';

class BandModel {
  final String id;
  final String name;
  final String description;
  final String joinCode;
  final String createdBy;
  final List<String> members;
  final Map<String, String> memberNames;
  final bool isDeleted;
  final DateTime? createdAt;

  BandModel({
    required this.id,
    required this.name,
    required this.description,
    required this.joinCode,
    required this.createdBy,
    required this.members,
    required this.memberNames,
    required this.isDeleted,
    this.createdAt,
  });

  int get memberCount => members.length;

  factory BandModel.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> doc,
      ) {
    final data = doc.data() ?? {};

    final rawNames = data['memberNames'];
    final names = rawNames is Map
        ? rawNames.map(
          (key, value) => MapEntry(key.toString(), value.toString()),
    )
        : <String, String>{};

    return BandModel(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      joinCode: data['joinCode'] ?? '',
      createdBy: data['createdBy'] ?? '',
      members: List<String>.from(data['members'] ?? []),
      memberNames: names,
      isDeleted: data['isDeleted'] ?? false,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }
}