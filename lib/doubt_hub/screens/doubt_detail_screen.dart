import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/doubt.dart';
import '../models/reply.dart';
import '../providers/doubts_provider.dart';
import '../utils/colors.dart';
import '../utils/helpers.dart';
import '../widgets/avatar_widget.dart';
import '../widgets/vote_buttons.dart';
import '../widgets/reply_card.dart';
import '../widgets/empty_state.dart';

class DoubtDetailScreen extends StatefulWidget {
  final String doubtId;
  const DoubtDetailScreen({super.key, required this.doubtId});

  @override
  State<DoubtDetailScreen> createState() => _DoubtDetailScreenState();
}

class _DoubtDetailScreenState extends State<DoubtDetailScreen> {
  final TextEditingController _replyController = TextEditingController();
  bool _sending = false;

  @override
  void dispose() {
    _replyController.dispose();
    super.dispose();
  }

  Future<void> _sendReply() async {
    final text = _replyController.text.trim();
    if (text.isEmpty) return;
    setState(() => _sending = true);
    HapticFeedback.mediumImpact();
    try {
      final provider = context.read<DoubtsProvider>();
      await provider.addReply(
        doubtId: widget.doubtId,
        body: text,
      );
      _replyController.clear();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Reply posted successfully!'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to post reply: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  void _handleDelete(BuildContext context, String authorId, String currentUserId) {
    // Only allow delete if current user is the author
    if (authorId != currentUserId) return;

    final provider = context.read<DoubtsProvider>();
    final screenContext = context;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Doubt'),
        content: const Text(
          'This will mark this doubt as deleted. Continue?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await provider.deleteDoubt(widget.doubtId);
              if (mounted) {
                Navigator.pop(screenContext);
              }
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DoubtsProvider>();
    final currentUserId = provider.userId;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('doubts')
            .doc(widget.doubtId)
            .snapshots(),
        builder: (context, doubtSnap) {
          if (!doubtSnap.hasData) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          if (!doubtSnap.data!.exists) {
            return Scaffold(
              appBar: AppBar(
                backgroundColor: AppColors.surface,
                title: Text('Doubt',
                    style: GoogleFonts.inter(
                        fontWeight: FontWeight.w600,
                        color: AppColors.text)),
              ),
              body: const EmptyState(
                icon: Icons.error_outline,
                title: 'Doubt not found',
                subtitle: 'This doubt may have been deleted.',
              ),
            );
          }

          final doubt = Doubt.fromFirestore(doubtSnap.data!);

          if (doubt.isDeleted) {
            return Scaffold(
              appBar: AppBar(
                backgroundColor: AppColors.surface,
                title: Text('Doubt',
                    style: GoogleFonts.inter(
                        fontWeight: FontWeight.w600,
                        color: AppColors.text)),
              ),
              body: const EmptyState(
                icon: Icons.error_outline,
                title: 'Doubt not found',
                subtitle: 'This doubt may have been deleted.',
              ),
            );
          }

          final currentVote = provider.getVote(widget.doubtId);
          final isAuthor = doubt.authorId == currentUserId;

          return Scaffold(
            backgroundColor: AppColors.background,
            appBar: AppBar(
              backgroundColor: AppColors.surface,
              surfaceTintColor: Colors.transparent,
              elevation: 0,
              title: Text(
                'Doubt',
                style: GoogleFonts.inter(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: AppColors.text,
                ),
              ),
              actions: [
                // Only show delete button if current user is the author
                if (isAuthor)
                  IconButton(
                    onPressed: () => _handleDelete(
                        context, doubt.authorId, currentUserId),
                    icon: const Icon(Icons.more_horiz,
                        color: AppColors.textTertiary),
                  ),
              ],
            ),
            body: Column(
              children: [
                Expanded(
                  child: StreamBuilder<List<Reply>>(
                    stream: provider.getRepliesStream(widget.doubtId),
                    builder: (context, snapshot) {
                      final replies = snapshot.data ?? [];
                      return CustomScrollView(
                        slivers: [
                          SliverToBoxAdapter(
                            child: Container(
                              color: AppColors.surface,
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  // Author header
                                  Row(
                                    children: [
                                      AvatarWidget.fromHex(
                                        name: doubt.authorName,
                                        hexColor: doubt.authorAvatar,
                                        size: 40,
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              doubt.authorName,
                                              style: GoogleFonts.inter(
                                                fontSize: 15,
                                                fontWeight:
                                                    FontWeight.w600,
                                                color: AppColors.text,
                                              ),
                                            ),
                                            Text(
                                              formatTimeAgo(
                                                  doubt.createdAt),
                                              style: GoogleFonts.inter(
                                                fontSize: 12,
                                                color:
                                                    AppColors.textTertiary,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 14),

                                  // Title
                                  Text(
                                    doubt.title,
                                    style: GoogleFonts.inter(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.text,
                                      height: 1.3,
                                    ),
                                  ),
                                  const SizedBox(height: 10),

                                  // Body
                                  Text(
                                    doubt.body,
                                    style: GoogleFonts.inter(
                                      fontSize: 15,
                                      color: AppColors.textSecondary,
                                      height: 1.5,
                                    ),
                                  ),

                                  // Tags
                                  if (doubt.tags.isNotEmpty) ...[
                                    const SizedBox(height: 14),
                                    Wrap(
                                      spacing: 6,
                                      runSpacing: 6,
                                      children:
                                          doubt.tags.map((tag) {
                                        return Container(
                                          padding:
                                              const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: AppColors.accentLight,
                                            borderRadius:
                                                BorderRadius.circular(
                                                    10),
                                          ),
                                          child: Text(
                                            tag,
                                            style: GoogleFonts.inter(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500,
                                              color: AppColors.accent,
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  ],

                                  // Votes + reply count
                                  const SizedBox(height: 16),
                                  Container(
                                    padding: const EdgeInsets.only(
                                        top: 14),
                                    decoration: BoxDecoration(
                                      border: Border(
                                        top: BorderSide(
                                          color: AppColors.borderLight,
                                          width: 0.5,
                                        ),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        VoteButtons(
                                          upvotes: doubt.upvotes,
                                          downvotes: doubt.downvotes,
                                          currentVote: currentVote,
                                          onVote: (type) =>
                                              provider.voteOnDoubt(
                                                  doubt.id, type),
                                        ),
                                        Row(
                                          children: [
                                            const Icon(
                                              Icons.chat_bubble_outline,
                                              size: 15,
                                              color: AppColors.textTertiary,
                                            ),
                                            const SizedBox(width: 5),
                                            Text(
                                              '${replies.length} replies',
                                              style: GoogleFonts.inter(
                                                fontSize: 13,
                                                fontWeight: FontWeight.w500,
                                                color:
                                                    AppColors.textTertiary,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),

                                  // Replies heading
                                  const SizedBox(height: 20),
                                  Container(
                                    padding: const EdgeInsets.only(
                                        top: 14),
                                    decoration: BoxDecoration(
                                      border: Border(
                                        top: BorderSide(
                                          color: AppColors.borderLight,
                                          width: 0.5,
                                        ),
                                      ),
                                    ),
                                    child: Text(
                                      'Replies',
                                      style: GoogleFonts.inter(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.text,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // Replies list
                          if (replies.isEmpty)
                            const SliverToBoxAdapter(
                              child: EmptyState(
                                icon: Icons.chat_bubble_outline,
                                title: 'No replies yet',
                                subtitle:
                                    'Be the first to share your thoughts!',
                              ),
                            )
                          else
                            SliverList(
                              delegate: SliverChildBuilderDelegate(
                                (context, index) {
                                  final reply = replies[index];
                                  return ReplyCard(
                                    reply: reply,
                                    currentVote:
                                        provider.getVote(reply.id),
                                    onVote: (type) =>
                                        provider.voteOnReply(
                                      replyId: reply.id,
                                      doubtId: widget.doubtId,
                                      voteType: type,
                                    ),
                                    isNested:
                                        reply.parentReplyId != null,
                                  );
                                },
                                childCount: replies.length,
                              ),
                            ),

                          const SliverToBoxAdapter(
                              child: SizedBox(height: 20)),
                        ],
                      );
                    },
                  ),
                ),

                // Reply input bar
                Container(
                  padding: EdgeInsets.only(
                    left: 16,
                    right: 16,
                    top: 10,
                    bottom:
                        MediaQuery.of(context).padding.bottom + 12,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    border: Border(
                      top: BorderSide(
                          color: AppColors.border, width: 0.5),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppColors.background,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: TextField(
                            controller: _replyController,
                            maxLines: 4,
                            minLines: 1,
                            maxLength: 500,
                            style: GoogleFonts.inter(
                              fontSize: 15,
                              color: AppColors.text,
                            ),
                            decoration: InputDecoration(
                              hintText: 'Write a reply...',
                              hintStyle: GoogleFonts.inter(
                                fontSize: 15,
                                color: AppColors.textTertiary,
                              ),
                              border: InputBorder.none,
                              contentPadding:
                                  const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 10,
                              ),
                              counterText: '',
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      GestureDetector(
                        onTap: _sending ? null : _sendReply,
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.send,
                            size: 18,
                            color: _sending
                                ? Colors.white.withValues(alpha: 0.4)
                                : Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}