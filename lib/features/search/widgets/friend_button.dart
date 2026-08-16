import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/search_provider.dart';

class FriendButton extends ConsumerStatefulWidget {
  final String targetUserId;
  final String initialStatus;

  const FriendButton({
    super.key,
    required this.targetUserId,
    required this.initialStatus,
  });

  @override
  ConsumerState<FriendButton> createState() => _FriendButtonState();
}

class _FriendButtonState extends ConsumerState<FriendButton> {
  bool _isLoading = false;

  void _handleTap() async {
    if (widget.initialStatus != 'none' && widget.initialStatus != 'request_sent') return; // Can only tap to request

    setState(() => _isLoading = true);
    try {
      await ref.read(searchControllerProvider.notifier).sendFriendRequest(widget.targetUserId);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    String text;
    Color bgColor;
    Color textColor;

    switch (widget.initialStatus) {
      case 'friends':
        text = 'Friends';
        bgColor = const Color(0xFF1DB954); // Green brand color
        textColor = Colors.white;
        break;
      case 'request_sent':
        text = 'Request Sent';
        bgColor = Colors.grey[800]!;
        textColor = Colors.white;
        break;
      case 'requested':
        text = 'Requested';
        bgColor = Colors.grey[800]!;
        textColor = Colors.white;
        break;
      case 'none':
      default:
        text = 'Add Friend';
        bgColor = const Color(0xFFF5C542); // Scrollify gold
        textColor = Colors.black;
        break;
    }

    final bool isDisabled = widget.initialStatus != 'none' || _isLoading;

    return InkWell(
      onTap: isDisabled ? null : _handleTap,
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 36,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: isDisabled && widget.initialStatus == 'none' ? bgColor.withOpacity(0.5) : bgColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            if (!isDisabled)
              BoxShadow(
                color: bgColor.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        alignment: Alignment.center,
        child: _isLoading
            ? SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(textColor),
                ),
              )
            : Text(
                text,
                style: TextStyle(
                  color: textColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
      ),
    );
  }
}
