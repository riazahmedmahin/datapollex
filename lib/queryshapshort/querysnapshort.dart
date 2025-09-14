import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';


class MockQuerySnapshot implements QuerySnapshot {
  final List<QueryDocumentSnapshot> _docs;

  MockQuerySnapshot(this._docs);

  @override
  List<QueryDocumentSnapshot> get docs => _docs;

  @override
  List<DocumentChange> get docChanges => [];

  @override
  SnapshotMetadata get metadata => MockSnapshotMetadata();

  @override
  int get size => _docs.length;
}

class MockSnapshotMetadata implements SnapshotMetadata {
  @override
  bool get hasPendingWrites => false;

  @override
  bool get isFromCache => false;
}
