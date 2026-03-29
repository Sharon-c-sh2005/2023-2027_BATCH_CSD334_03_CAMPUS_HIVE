import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import '../projects/models/project_model.dart';
import 'chat_service.dart';
import 'models/message_model.dart';
//import 'group_info_page.dart';
import '../projects/screens/project_detail_page.dart';
import '../projects/services/project_service.dart';


class ChatPage extends StatefulWidget {
  final Project project;
  final String currentUserId;

  const ChatPage({
    super.key,
    required this.project,
    required this.currentUserId,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final ChatService _chatService = ChatService();
  final TextEditingController _msgCtrl = TextEditingController();
  final ScrollController _scrollCtrl = ScrollController();
  final ImagePicker _picker = ImagePicker();
  bool _isSending = false;
  Map<String, String> _senderNames = {};

  static const _primary =  Color(0xFF1A1A2E);
  static const _bg = Color(0xFFF0F2F5);

  @override
  void initState() {
    super.initState();
    _chatService.markAsSeen(
      projectId: widget.project.id!,
      userId: widget.currentUserId,
    );
    _loadSenderNames();
  }

  @override
  void dispose() {
    _msgCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  // LOAD SENDER NAMES FROM FIRESTORE
  Future<void> _loadSenderNames() async {
    final Map<String, String> fetched = {};
    for (final uid in widget.project.members) {
      try {
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .get();
        final raw = doc.data()?['displayName'] ?? '';
        fetched[uid] = raw.isEmpty ? uid : _capitalize(raw);
      } catch (_) {
        fetched[uid] = uid;
      }
    }
    if (mounted) setState(() => _senderNames = fetched);
  }

  String _capitalize(String text) {
    if (text.isEmpty) return text;
    return text.split(' ').map((w) {
      if (w.isEmpty) return w;
      return w[0].toUpperCase() + w.substring(1).toLowerCase();
    }).join(' ');
  }

  String _getSenderName(String uid) {
    final name = _senderNames[uid] ?? uid;
    return name[0].toUpperCase() + name.substring(1);
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage() async {
    final text = _msgCtrl.text.trim();
    if (text.isEmpty) return;
    setState(() => _isSending = true);
    _msgCtrl.clear();
    await _chatService.sendMessage(
      projectId: widget.project.id!,
      senderId: widget.currentUserId,
      text: text,
    );
    setState(() => _isSending = false);
    _scrollToBottom();
  }

  Future<void> _pickAndSendImage() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );
    if (image == null) return;
    await _chatService.sendImage(
      projectId: widget.project.id!,
      senderId: widget.currentUserId,
      imageFile: image,
    );
    _scrollToBottom();
  }

  String _formatTime(Timestamp timestamp) {
    final date = timestamp.toDate();
    final hour = date.hour.toString().padLeft(2, '0');
    final min = date.minute.toString().padLeft(2, '0');
    return '$hour:$min';
  }

  bool _shouldShowDate(List<Message> messages, int index) {
    if (index == 0) return true;
    final current = messages[index].timestamp.toDate();
    final previous = messages[index - 1].timestamp.toDate();
    return current.day != previous.day ||
        current.month != previous.month ||
        current.year != previous.year;
  }

  // ACTIVITY PANEL — same logic as ProjectDetailPage
void _openProjectPanel(BuildContext context, Project project, bool isOwner) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) {
      return DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.92,
        builder: (context, controller) {
          return Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              children: [
                const SizedBox(height: 12),
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade400,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  "Project Panel",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 12),
               const Divider(height: 1),
                Expanded(
                  child: StreamBuilder<Project>(
                    stream: ProjectService().streamProject(project.id!),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      final liveProject = snapshot.data!;
                      return ListView(
                        controller: controller,
                        padding: const EdgeInsets.all(16),
                        children: [
                          const Text(
                            "Activity",
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 10),
                          liveProject.activities.isEmpty
                              ? Container(
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade900,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    "No activity yet",
                                    style: TextStyle(color: Colors.grey.shade500),
                                  ),
                                )
                              : Column(
                                  children: liveProject.activities.reversed.map((a) {
                                    return Container(
                                      margin: const EdgeInsets.only(bottom: 10),
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade50,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(color: Colors.grey.shade200),
                                      ),
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const CircleAvatar(
                                            radius: 14,
                                            backgroundColor:Color(0xFF1A1A2E),
                                            child: Icon(Icons.bolt, size: 14, color: Colors.white),
                                          ),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  a.message,
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                    
                                                  ),
                                                ),
                                                const SizedBox(height: 3),
                                                Text(
                                                  _formatActivityTime(a.timestamp),
                                                  style: TextStyle(
                                                    fontSize: 10,
                                                    color: Colors.grey.shade500,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }).toList(),
                                ),
                          if (isOwner) ...[
                            const SizedBox(height: 24),
                           const Divider(height: 1),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                const Text(
                                  "Pending Requests",
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                if (liveProject.pendingRequests.isNotEmpty)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Colors.red,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      '${liveProject.pendingRequests.length}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            liveProject.pendingRequests.isEmpty
                                ? Container(
                                    padding: const EdgeInsets.all(14),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade900,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      "No pending requests",
                                      style: TextStyle(color: Colors.grey.shade500),
                                    ),
                                  )
                                : Column(
                                    children: liveProject.pendingRequests.map((userId) {
                                      return Container(
                                        margin: const EdgeInsets.only(bottom: 10),
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(14),
                                          boxShadow: [
  BoxShadow(
    color: Colors.black.withOpacity(0.06),
    blurRadius: 6,
    offset: Offset(0, 2),
  ),
],
                                         
                                        ),
                                        child: Column(
                                          children: [
                                            FutureBuilder<DocumentSnapshot>(
                                              future: FirebaseFirestore.instance
                                                  .collection('users')
                                                  .doc(userId)
                                                  .get(),
                                              builder: (context, snap) {
                                                String name = userId;
                                                if (snap.hasData && snap.data!.exists) {
                                                  final raw = (snap.data!.data() as Map<String, dynamic>)['displayName'] ?? '';
                                                  if (raw.isNotEmpty) name = _capitalize(raw);
                                                }
                                                return Row(
                                                  children: [
                                                    CircleAvatar(
                                                      radius: 18,
                                                      backgroundColor: Colors.orange.shade900,
                                                      child: Text(
                                                        name[0].toUpperCase(),
                                                        style: const TextStyle(
                                                          fontWeight: FontWeight.bold,
                                                          color: Colors.orange,
                                                        ),
                                                      ),
                                                    ),
                                                    const SizedBox(width: 10),
                                                    Expanded(
                                                      child: Column(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                          Text(
                                                            name,
                                                            style: const TextStyle(
                                                              fontSize: 13,
                                                              fontWeight: FontWeight.w600,
                                                              color: Color(0xFF1A1A2E),
                                                            
                                                            ),
                                                          ),
                                                          Text(
                                                            "Wants to join",
                                                            style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                );
                                              },
                                            ),
                                            const SizedBox(height: 10),
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: GestureDetector(
                                                    onTap: () async {
                                                      await ProjectService().acceptJoinRequest(
                                                        projectId: liveProject.id!,
                                                        userId: userId,
                                                      );
                                                    },
                                                    child: Container(
                                                      height: 34,
                                                      decoration: BoxDecoration(
                                                        color: Colors.black,
                                                        borderRadius: BorderRadius.circular(8),
                                                      ),
                                                      child: const Row(
                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                        children: [
                                                          Icon(Icons.check, color: Colors.white, size: 13),
                                                          SizedBox(width: 4),
                                                          Text("Accept", style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                                Expanded(
                                                  child: GestureDetector(
                                                    onTap: () async {
                                                      await ProjectService().declineJoinRequest(
                                                        projectId: liveProject.id!,
                                                        userId: userId,
                                                      );
                                                    },
                                                    child: Container(
                                                      height: 34,
                                                      decoration: BoxDecoration(
                                                        color: Colors.transparent,
                                                        borderRadius: BorderRadius.circular(8),
                                                        border: Border.all(color: Colors.red.shade300),
                                                      ),
                                                      child: Row(
                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                        children: [
                                                          Icon(Icons.close, color: Colors.red.shade400, size: 13),
                                                          const SizedBox(width: 4),
                                                          Text("Decline", style: TextStyle(color: Colors.red.shade400, fontSize: 12, fontWeight: FontWeight.w600)),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      );
                                    }).toList(),
                                  ),
                          ],
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      );
    },
  );
}

String _formatActivityTime(Timestamp timestamp) {
  final date = timestamp.toDate();
  final now = DateTime.now();
  final diff = now.difference(date);
  if (diff.inMinutes < 1) return "Just now";
  if (diff.inMinutes < 60) return "${diff.inMinutes} min ago";
  if (diff.inHours < 24) return "${diff.inHours} hr ago";
  return "${date.day}/${date.month}/${date.year}";
}

  String _formatDate(Timestamp timestamp) {
    final date = timestamp.toDate();
    final now = DateTime.now();
    if (date.day == now.day &&
        date.month == now.month &&
        date.year == now.year) return 'Today';
    final yesterday = now.subtract(const Duration(days: 1));
    if (date.day == yesterday.day &&
        date.month == yesterday.month &&
        date.year == yesterday.year) return 'Yesterday';
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1A1A2E),
        elevation: 0,
        titleSpacing: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: GestureDetector(
              onTap: () => Navigator.push(
  context,
  MaterialPageRoute(
    builder: (_) => ProjectDetailPage(
      projectId: widget.project.id!,
      currentUserId: widget.currentUserId,
    ),
  ),
),

         /* onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => GroupInfoPage(
                project: widget.project,
                currentUserId: widget.currentUserId,
              ),
            ),
          ),*/
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.asset(
                  widget.project.coverImage.isNotEmpty
                      ? widget.project.coverImage
                      : 'assets/covers/cover1.png',
                  width: 36,
                  height: 36,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: 36,
                    height: 36,
                    color: _primary.withOpacity(0.1),
                    child: const Icon(Icons.group,
                        color: _primary, size: 18),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.project.title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1A1A2E),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      '${widget.project.members.length} members · tap for info',
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF8F8F8F),
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
       /* actions: [
          IconButton(
            icon: const Icon(Icons.info_outline, size: 20),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => GroupInfoPage(
                  project: widget.project,
                  currentUserId: widget.currentUserId,
                ),
              ),
            ),
          ),
        ],*/
        actions: [
  StreamBuilder<Project>(
    stream: ProjectService().streamProject(widget.project.id!),
    builder: (context, snapshot) {
      final liveProject = snapshot.data ?? widget.project;
      final isOwner = liveProject.ownerId == widget.currentUserId;
      final pendingCount = liveProject.pendingRequests.length;

      return Stack(
        children: [
          IconButton(
            icon: const Icon(Icons.view_list_rounded, size: 22),
            onPressed: () => _openProjectPanel(context, liveProject, isOwner),
          ),
          if (isOwner && pendingCount > 0)
            Positioned(
              right: 6,
              top: 6,
              child: Container(
                width: 14,
                height: 14,
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '$pendingCount',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
        ],
      );
    },
  ),
],

        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: Colors.grey.shade200),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<Message>>(
              stream: _chatService.streamMessages(widget.project.id!),
              builder: (context, snapshot) {
                if (snapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Center(
                      child: CircularProgressIndicator());
                }
                final messages = snapshot.data ?? [];
                if (messages.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.chat_bubble_outline,
                            size: 48, color: Colors.grey.shade300),
                        const SizedBox(height: 12),
                        Text('No messages yet',
                            style: TextStyle(
                                color: Colors.grey.shade400,
                                fontSize: 14)),
                        const SizedBox(height: 4),
                        Text('Say hello to your team!',
                            style: TextStyle(
                                color: Colors.grey.shade400,
                                fontSize: 12)),
                      ],
                    ),
                  );
                }
                _scrollToBottom();
                return ListView.builder(
                  controller: _scrollCtrl,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 16),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final isMe =
                        message.senderId == widget.currentUserId;
                    final showDate =
                        _shouldShowDate(messages, index);
                    final isLastInGroup =
                        index == messages.length - 1 ||
                            messages[index + 1].senderId !=
                                message.senderId;

                    return Column(
                      children: [
                        if (showDate)
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 12),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade200,
                                borderRadius:
                                    BorderRadius.circular(12),
                              ),
                              child: Text(
                                _formatDate(message.timestamp),
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey.shade600,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        Padding(
                          padding: EdgeInsets.only(
                            bottom: isLastInGroup ? 8 : 2,
                            left: isMe ? 48 : 0,
                            right: isMe ? 0 : 48,
                          ),
                          child: Row(
                            mainAxisAlignment: isMe
                                ? MainAxisAlignment.end
                                : MainAxisAlignment.start,
                            crossAxisAlignment:
                                CrossAxisAlignment.end,
                            children: [
                              if (!isMe && isLastInGroup)
                                Container(
                                  width: 28,
                                  height: 28,
                                  margin: const EdgeInsets.only(
                                      right: 6, bottom: 2),
                                  decoration: BoxDecoration(
                                    color:
                                        _primary.withOpacity(0.15),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: Text(
                                      _getSenderName(
                                              message.senderId)[0]
                                          .toUpperCase(),
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: _primary,
                                      ),
                                    ),
                                  ),
                                )
                              else if (!isMe)
                                const SizedBox(width: 34),
                              Flexible(
                                child: Column(
                                  crossAxisAlignment: isMe
                                      ? CrossAxisAlignment.end
                                      : CrossAxisAlignment.start,
                                  children: [
                                    // IMAGE MESSAGE
                                    if (message.type == 'image' &&
                                        message.imageUrl != null)
                                      ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(12),
                                        child:Image.network(
  message.imageUrl!,
  width: 200,
  fit: BoxFit.cover,
  loadingBuilder: (context, child, progress) {
    if (progress == null) return child;
    return Container(
      width: 200,
      height: 150,
      color: Colors.grey.shade200,
      child: const Center(
        child: CircularProgressIndicator(
          color: _primary,
        ),
      ),
    );
  },
  errorBuilder: (context, error, stackTrace) {
    return Container(
      width: 200,
      height: 60,
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.broken_image_outlined,
              color: Colors.grey.shade400, size: 18),
          const SizedBox(width: 6),
          Text(
            "Image unavailable",
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  },
),
                                      )
                                    // TEXT MESSAGE
                                    else
                                      Container(
                                        padding:
                                            const EdgeInsets.symmetric(
                                                horizontal: 12,
                                                vertical: 8),
                                        decoration: BoxDecoration(
                                          color: isMe
                                              ? _primary
                                              : Colors.white,
                                          borderRadius:
                                              BorderRadius.only(
                                            topLeft:
                                                const Radius.circular(
                                                    16),
                                            topRight:
                                                const Radius.circular(
                                                    16),
                                            bottomLeft:
                                                Radius.circular(
                                                    isMe ? 16 : 4),
                                            bottomRight:
                                                Radius.circular(
                                                    isMe ? 4 : 16),
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black
                                                  .withOpacity(0.05),
                                              blurRadius: 4,
                                              offset:
                                                  const Offset(0, 1),
                                            ),
                                          ],
                                        ),
                                        child: Text(
                                          message.text,
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: isMe
                                                ? Colors.white
                                                : const Color(
                                                    0xFF1A1A2E),
                                            height: 1.4,
                                          ),
                                        ),
                                      ),
                                    const SizedBox(height: 2),
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          _formatTime(
                                              message.timestamp),
                                          style: TextStyle(
                                            fontSize: 9,
                                            color:
                                                Colors.grey.shade400,
                                          ),
                                        ),
                                        if (isMe) ...[
                                          const SizedBox(width: 3),
                                          Icon(
                                            message.seenBy.length > 1
                                                ? Icons.done_all
                                                : Icons.done,
                                            size: 12,
                                            color: message.seenBy
                                                        .length >
                                                    1
                                                ? _primary
                                                : Colors.grey.shade400,
                                          ),
                                        ],
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ),

          // INPUT BAR
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: _bg,
                        borderRadius: BorderRadius.circular(24),
                        border:
                            Border.all(color: Colors.grey.shade200),
                      ),
                      child: TextField(
                        controller: _msgCtrl,
                        maxLines: null,
                        keyboardType: TextInputType.multiline,
                        textCapitalization:
                            TextCapitalization.sentences,
                        style: const TextStyle(fontSize: 14),
                        decoration: InputDecoration(
                          hintText: 'Message...',
                          hintStyle: TextStyle(
                              color: Colors.grey.shade400,
                              fontSize: 13),
                          border: InputBorder.none,
                          contentPadding:
                              const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 10),
                        ),
                        onSubmitted: (_) => _sendMessage(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),

                  // IMAGE BUTTON
                  IconButton(
                    onPressed: _pickAndSendImage,
                    icon: const Icon(
                      Icons.image_outlined,
                      color: _primary,
                      size: 22,
                    ),
                  ),

                  // SEND BUTTON
                  GestureDetector(
                    onTap: _isSending ? null : _sendMessage,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: _primary,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: _primary.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.send_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}