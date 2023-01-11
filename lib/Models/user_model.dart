import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String name;
  final String email;
  final String? photoUrl;
  final String? eid;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.photoUrl,
    this.eid,
  });

  factory UserModel.fromDocument(DocumentSnapshot doc) {
    return UserModel(
      id: doc.id,
      name: doc['name'],
      email: doc['email'],
      photoUrl: doc['photoUrl'],
      eid: doc['eid'],
    );
  }
}
