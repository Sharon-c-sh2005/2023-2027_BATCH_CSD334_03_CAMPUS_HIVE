                                                                                                                                                      enum VoteType { up, down }

class Vote {
  final String id;
  final String userId;
  final String itemId;
  final VoteType type;

  Vote({
    required this.id,
    required this.userId,
    required this.itemId,
    required this.type,
  });

  factory Vote.fromMap(Map<String, dynamic> data, String id) {
    return Vote(
      id: id,
      userId: data['userId'] ?? '',
      itemId: data['itemId'] ?? '',
      type: data['type'] == 'up' ? VoteType.up : VoteType.down,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'itemId': itemId,
      'type': type == VoteType.up ? 'up' : 'down',
    };
  }
}