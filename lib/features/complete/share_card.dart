import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text.dart';
import '../../core/ui/transport_icon.dart';
import '../../core/utils/duration_format.dart';
import '../../data/models/transport_type.dart';

/// 공유 카드에 필요한 한 여정의 정보.
class ShareCardData {
  const ShareCardData({
    required this.originName,
    required this.destName,
    required this.destCity,
    required this.transportIndex,
    required this.durationSeconds,
    required this.date,
    this.collectibleEmoji,
    this.collectibleName,
    this.collectibleCategory,
  });

  final String originName;
  final String destName;
  final String destCity;
  final int transportIndex;
  final int durationSeconds;
  final DateTime date;
  final String? collectibleEmoji;
  final String? collectibleName;
  final String? collectibleCategory;
}

/// 도착 인증 공유 시트(미리보기 + 이미지 공유).
Future<void> showJourneyShareSheet(
    BuildContext context, ShareCardData data) async {
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) => _ShareSheet(data: data),
  );
}

class _ShareSheet extends StatefulWidget {
  const _ShareSheet({required this.data});
  final ShareCardData data;

  @override
  State<_ShareSheet> createState() => _ShareSheetState();
}

class _ShareSheetState extends State<_ShareSheet> {
  final _boundaryKey = GlobalKey();
  bool _busy = false;

  Future<void> _share() async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      await WidgetsBinding.instance.endOfFrame;
      final boundary = _boundaryKey.currentContext!.findRenderObject()
          as RenderRepaintBoundary;
      final image = await boundary.toImage(pixelRatio: 3);
      final bytes =
          (await image.toByteData(format: ui.ImageByteFormat.png))!
              .buffer
              .asUint8List();
      final dir = await getTemporaryDirectory();
      final file = await File('${dir.path}/jibchunghaeng_share.png')
          .writeAsBytes(bytes);
      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path, mimeType: 'image/png')],
          text: '집중행 — ${widget.data.destName}에 도착했어요! 🚆',
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('공유에 실패했어요: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.line,
                borderRadius: BorderRadius.circular(99),
              ),
            ),
            const SizedBox(height: 18),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: RepaintBoundary(
                key: _boundaryKey,
                child: JourneyShareCard(data: widget.data),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                ),
                onPressed: _busy ? null : _share,
                icon: _busy
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.ios_share_rounded, size: 18),
                label: Text(_busy ? '준비 중…' : '이미지로 공유'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 공유용 「도착 승차권」 카드 — 노을빛 헤더 + 도착 도장 + 컬렉션 + 통계.
class JourneyShareCard extends StatelessWidget {
  const JourneyShareCard({super.key, required this.data});
  final ShareCardData data;

  static const _cream = Color(0xFFFFF7E9);

  @override
  Widget build(BuildContext context) {
    final transport = TransportType.values[data.transportIndex];
    final dateStr = DateFormat('yyyy.MM.dd').format(data.date);
    final hasItem = data.collectibleName != null;

    return Container(
      width: 320,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.line2),
        boxShadow: AppColors.cardShadow,
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 노을빛 헤더.
              Container(
                height: 138,
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF243049), Color(0xFF3C4663), Color(0xFF9A6B53)],
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text('집중행',
                            style: AppText.display(size: 18, color: _cream)),
                        const Spacer(),
                        Text('승차권 · BOARDING',
                            style: AppText.label(
                                size: 9, color: const Color(0xB3FFF7E9))),
                      ],
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        Flexible(
                          child: Text(data.originName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppText.display(size: 17, color: _cream)),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Icon(transportIcon(transport),
                              size: 16, color: const Color(0xE6FFF7E9)),
                        ),
                        Flexible(
                          child: Text(data.destName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.end,
                              style: AppText.display(size: 17, color: _cream)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                  ],
                ),
              ),
              // 본문(종이).
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 52, 20, 18),
                child: Column(
                  children: [
                    if (hasItem) _CollectibleChip(data: data),
                    if (hasItem) const SizedBox(height: 16),
                    const _Perforation(),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: _Stat(
                              label: '집중 시간',
                              value: formatDurationKo(data.durationSeconds)),
                        ),
                        Expanded(
                          child: _Stat(label: '도착 날짜', value: dateStr),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Text('集中行 · 오늘도 좋은 여정 되세요',
                        style: AppText.label(size: 9)),
                  ],
                ),
              ),
            ],
          ),
          // 헤더와 본문 경계에 찍히는 도착 도장.
          Positioned(
            top: 92,
            left: 0,
            right: 0,
            child: Center(child: _ShareStamp(city: data.destCity)),
          ),
        ],
      ),
    );
  }
}

class _ShareStamp extends StatelessWidget {
  const _ShareStamp({required this.city});
  final String city;

  @override
  Widget build(BuildContext context) {
    const ink = AppColors.danchung;
    return Transform.rotate(
      angle: -0.12,
      child: Container(
        width: 92,
        height: 92,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.surface,
          shape: BoxShape.circle,
          border: Border.all(color: ink.withValues(alpha: 0.85), width: 2.5),
          boxShadow: AppColors.cardShadow,
        ),
        child: Container(
          margin: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: ink.withValues(alpha: 0.45), width: 1),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('도착', style: AppText.label(size: 8, color: ink)),
              const SizedBox(height: 1),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(city,
                      maxLines: 1, style: AppText.display(size: 20, color: ink)),
                ),
              ),
              const SizedBox(height: 2),
              Text('ARRIVED',
                  style: AppText.number(size: 7, color: ink, letterSpacing: 1)),
            ],
          ),
        ),
      ),
    );
  }
}

class _CollectibleChip extends StatelessWidget {
  const _CollectibleChip({required this.data});
  final ShareCardData data;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.celadon.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.celadon.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          Text(data.collectibleEmoji ?? '🎁',
              style: const TextStyle(fontSize: 30)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${data.destCity} · ${data.collectibleCategory ?? ''}',
                    style: AppText.label(size: 9, color: const Color(0xFF3F6450))),
                const SizedBox(height: 3),
                Text(data.collectibleName ?? '',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppText.display(size: 16)),
              ],
            ),
          ),
          const Icon(Icons.workspace_premium_outlined,
              size: 18, color: AppColors.celadon),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppText.label(size: 10)),
        const SizedBox(height: 4),
        Text(value, style: AppText.number(size: 17)),
      ],
    );
  }
}

/// 좌우 천공 + 절취 점선(공유 카드 폭 320 기준).
class _Perforation extends StatelessWidget {
  const _Perforation();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 16,
      width: double.infinity,
      child: CustomPaint(painter: _PerfPainter()),
    );
  }
}

class _PerfPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cy = size.height / 2;
    const r = 8.0;
    final notch = Paint()..color = AppColors.background;
    final rim = Paint()
      ..color = AppColors.line
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    // 카드 안쪽 패딩(20)을 고려해 가장자리까지 닿도록 음수 위치에 천공.
    for (final cx in [-20.0, size.width + 20.0]) {
      canvas.drawCircle(Offset(cx, cy), r, notch);
      canvas.drawCircle(Offset(cx, cy), r, rim);
    }
    final dash = Paint()
      ..color = AppColors.line2
      ..strokeWidth = 1.2
      ..strokeCap = StrokeCap.round;
    var x = 0.0;
    while (x < size.width) {
      canvas.drawLine(Offset(x, cy), Offset(x + 4, cy), dash);
      x += 10;
    }
  }

  @override
  bool shouldRepaint(_PerfPainter oldDelegate) => false;
}
