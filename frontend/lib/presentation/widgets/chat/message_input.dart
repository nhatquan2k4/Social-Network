import 'package:flutter/material.dart';

class MessageInput extends StatefulWidget {
  final TextEditingController controller;
  final bool isSending;
  final Function(String) onSend;

  const MessageInput({
    super.key,
    required this.controller,
    required this.isSending,
    required this.onSend,
  });

  @override
  State<MessageInput> createState() => _MessageInputState();
}

class _MessageInputState extends State<MessageInput> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTextChanged);
  }

  @override
  void didUpdateWidget(covariant MessageInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_onTextChanged);
      widget.controller.addListener(_onTextChanged);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    super.dispose();
  }

  void _onTextChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  void _handleSend() {
    final message = widget.controller.text.trim();
    if (message.isNotEmpty && !widget.isSending) {
      widget.onSend(message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final iconColor = widget.isSending
        ? const Color(0xFFB1B1B7)
        : const Color(0xFF1C1D22);

    return Container(
      padding: const EdgeInsets.fromLTRB(8, 6, 8, 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F2F4),
        border: const Border(top: BorderSide(color: Color(0xFFD4D4D8))),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Container(
              width: 33,
              height: 33,
              decoration: BoxDecoration(
                color: const Color(0xFFD9D9DE),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.camera_alt_outlined, size: 19),
                onPressed: widget.isSending
                    ? null
                    : () {
                        // TODO: Implement camera action
                      },
                color: iconColor,
                splashRadius: 18,
                padding: EdgeInsets.zero,
              ),
            ),
            const SizedBox(width: 8),

            Expanded(
              child: Container(
                height: 38,
                padding: const EdgeInsets.only(left: 10, right: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFE7E7EB),
                  borderRadius: BorderRadius.circular(19),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: widget.controller,
                        enabled: !widget.isSending,
                        maxLines: 1,
                        textCapitalization: TextCapitalization.sentences,
                        decoration: const InputDecoration(
                          hintText: 'Nhắn tin...',
                          hintStyle: TextStyle(
                            color: Color(0xFF8F8F95),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                          border: InputBorder.none,
                          isDense: true,
                        ),
                        onSubmitted: (value) => _handleSend(),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.mic_none, size: 22),
                      onPressed: widget.isSending
                          ? null
                          : () {
                              // TODO: Implement voice action
                            },
                      splashRadius: 16,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                        minWidth: 27,
                        minHeight: 27,
                      ),
                      color: iconColor,
                    ),
                    IconButton(
                      icon: const Icon(Icons.image_outlined, size: 21),
                      onPressed: widget.isSending
                          ? null
                          : () {
                              // TODO: Implement image action
                            },
                      splashRadius: 16,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                        minWidth: 27,
                        minHeight: 27,
                      ),
                      color: iconColor,
                    ),
                    IconButton(
                      icon: const Icon(Icons.link_rounded, size: 21),
                      onPressed: widget.isSending
                          ? null
                          : () {
                              // TODO: Implement link action
                            },
                      splashRadius: 16,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                        minWidth: 27,
                        minHeight: 27,
                      ),
                      color: iconColor,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
