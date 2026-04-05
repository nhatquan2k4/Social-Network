import 'package:flutter/material.dart';
import 'package:frontend/domain/entities/post_entity.dart';
import 'package:frontend/core/l10n/l10n.dart';

enum PostOptionAction { addToFavorites, aboutAccount, hidePost, report }

enum PostReportReason {
  spam,
  harassment,
  falseInfo,
  hateSpeech,
  violence,
  other,
}

String reportReasonLabel(PostReportReason reason, dynamic l10n) {
  switch (reason) {
    case PostReportReason.spam:
      return l10n.postReportReasonSpam;
    case PostReportReason.harassment:
      return l10n.postReportReasonHarassment;
    case PostReportReason.falseInfo:
      return l10n.postReportReasonFalseInfo;
    case PostReportReason.hateSpeech:
      return l10n.postReportReasonHateSpeech;
    case PostReportReason.violence:
      return l10n.postReportReasonViolence;
    case PostReportReason.other:
      return l10n.postReportReasonOther;
  }
}

Future<PostOptionAction?> showPostOptionsSheet(
  BuildContext context,
  PostEntity post,
) {
  final l10n = context.l10n;

  return showModalBottomSheet<PostOptionAction>(
    context: context,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withOpacity(0.18),
    isScrollControlled: false,
    builder: (sheetContext) {
      return SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: const Color(0xFFF2F2F4),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 8),
                Container(
                  width: 34,
                  height: 3,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD2D2D6),
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
                const SizedBox(height: 10),
                _buildGroup(
                  children: [
                    _buildTile(
                      icon: Icons.star_border,
                      label: l10n.postOptionAddToFavorites,
                      onTap: () => Navigator.pop(
                        sheetContext,
                        PostOptionAction.addToFavorites,
                      ),
                    ),
                    _buildTile(
                      icon: Icons.person_search_outlined,
                      label: l10n.postOptionAboutThisAccount,
                      onTap: () => Navigator.pop(
                        sheetContext,
                        PostOptionAction.aboutAccount,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                _buildGroup(
                  children: [
                    _buildTile(
                      icon: Icons.visibility_off_outlined,
                      label: l10n.postOptionHidePost,
                      onTap: () => Navigator.pop(
                        sheetContext,
                        PostOptionAction.hidePost,
                      ),
                    ),
                    _buildTile(
                      icon: Icons.report_gmailerrorred_outlined,
                      label: l10n.postOptionReport,
                      labelColor: const Color(0xFFE53935),
                      iconColor: const Color(0xFFE53935),
                      onTap: () =>
                          Navigator.pop(sheetContext, PostOptionAction.report),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        ),
      );
    },
  );
}

Widget _buildGroup({required List<Widget> children}) {
  return Container(
    margin: const EdgeInsets.symmetric(horizontal: 8),
    decoration: BoxDecoration(
      color: const Color(0xFFE5E5E8),
      borderRadius: BorderRadius.circular(14),
    ),
    child: Column(children: children),
  );
}

Widget _buildTile({
  required IconData icon,
  required String label,
  Color labelColor = const Color(0xFF111111),
  Color iconColor = const Color(0xFF111111),
  required VoidCallback onTap,
}) {
  return InkWell(
    borderRadius: BorderRadius.circular(14),
    onTap: onTap,
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Icon(icon, size: 17, color: iconColor),
          const SizedBox(width: 7),
          Text(
            label,
            style: TextStyle(
              fontSize: 22 / 1.8,
              color: labelColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    ),
  );
}

Future<PostReportReason?> showReportReasonSheet(BuildContext context) async {
  final l10n = context.l10n;
  PostReportReason? selectedReason;

  return showModalBottomSheet<PostReportReason>(
    context: context,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withOpacity(0.18),
    isScrollControlled: false,
    builder: (sheetContext) {
      return StatefulBuilder(
        builder: (context, setSheetState) {
          return SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: const Color(0xFFF2F2F4),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    Center(
                      child: Container(
                        width: 34,
                        height: 3,
                        decoration: BoxDecoration(
                          color: const Color(0xFFD2D2D6),
                          borderRadius: BorderRadius.circular(99),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        l10n.postReportTitle,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF111111),
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        l10n.postReportSelectReason,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF66666B),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    ...PostReportReason.values.map((reason) {
                      final isSelected = selectedReason == reason;

                      return InkWell(
                        onTap: () => setSheetState(() {
                          selectedReason = reason;
                        }),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          child: Row(
                            children: [
                              Icon(
                                isSelected
                                    ? Icons.radio_button_checked
                                    : Icons.radio_button_unchecked,
                                size: 20,
                                color: isSelected
                                    ? const Color(0xFF1689F6)
                                    : const Color(0xFF96969B),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                reportReasonLabel(reason, l10n),
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF1A1A1F),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                    const SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                      child: Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Navigator.pop(sheetContext),
                              style: OutlinedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Text(l10n.cancel),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: selectedReason == null
                                  ? null
                                  : () => Navigator.pop(
                                      sheetContext,
                                      selectedReason,
                                    ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFE53935),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Text(l10n.postReportSubmit),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );
    },
  );
}
