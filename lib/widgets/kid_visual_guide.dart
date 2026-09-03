import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/progress_provider.dart';
import '../theme/app_theme.dart';
import 'kid_button.dart';

/// 教學步驟的示意插圖類型（以 UI mock 呈現，無需額外圖片資源）
enum GuideIllustrationType {
  none,
  optionSelect,
  confirmButton,
  stars,
  progressSteps,
  vocabCard,
  ttsButton,
  readingContent,
  tapReveal,
  dailyReview,
  gradeSelector,
  subjectGrid,
  gameCard,
  lessonFlow,
}

/// 單一步驟的圖文教學內容
class KidGuideStep {
  final String emoji;
  final IconData? icon;
  final Color color;
  final String title;
  final String description;
  final String? tip;
  final GuideIllustrationType illustration;

  const KidGuideStep({
    required this.emoji,
    this.icon,
    required this.color,
    required this.title,
    required this.description,
    this.tip,
    this.illustration = GuideIllustrationType.none,
  });
}

/// 教學 intro 頁的漸層標題區
class KidGuideIntroHeader extends StatelessWidget {
  final String emoji;
  final String title;
  final String subtitle;
  final Color color;

  const KidGuideIntroHeader({
    super.key,
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color, color.withValues(alpha: 0.7)],
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 48)),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 14,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

/// 單一教學步驟卡片（適合 intro 頁面列表）
class KidGuideStepCard extends StatelessWidget {
  final KidGuideStep step;
  final int? stepNumber;

  const KidGuideStepCard({
    super.key,
    required this.step,
    this.stepNumber,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: step.color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [step.color, step.color.withValues(alpha: 0.7)],
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                alignment: Alignment.center,
                child: Text(step.emoji, style: const TextStyle(fontSize: 24)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (stepNumber != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 2),
                        child: Text(
                          '步驟 $stepNumber',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: step.color,
                          ),
                        ),
                      ),
                    Text(
                      step.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      step.description,
                      style: TextStyle(
                        fontSize: 13,
                        height: 1.45,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (step.illustration != GuideIllustrationType.none) ...[
            const SizedBox(height: 12),
            _GuideIllustrationWidget(type: step.illustration, color: step.color),
          ],
          if (step.tip != null) ...[
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFE3F2FD),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.touch_app, color: Color(0xFF1976D2), size: 18),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      step.tip!,
                      style: const TextStyle(
                        fontSize: 12,
                        height: 1.4,
                        color: Color(0xFF1565C0),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// 教學步驟列表（intro 頁面用）
class KidGuideStepsList extends StatelessWidget {
  final List<KidGuideStep> steps;

  const KidGuideStepsList({super.key, required this.steps});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < steps.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: KidGuideStepCard(step: steps[i], stepNumber: i + 1),
          ),
      ],
    );
  }
}

/// 行內提示卡（適合放在畫面頂部，引導操作）
class KidInlineHintCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String description;
  final VoidCallback? onDismiss;
  final VoidCallback? onLearnMore;

  const KidInlineHintCard({
    super.key,
    required this.icon,
    required this.color,
    required this.title,
    required this.description,
    this.onDismiss,
    this.onLearnMore,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: color,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 13,
                        height: 1.45,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
              ),
              if (onDismiss != null)
                IconButton(
                  icon: Icon(Icons.close, size: 20, color: Colors.grey.shade500),
                  onPressed: onDismiss,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                ),
            ],
          ),
          if (onLearnMore != null) ...[
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: onLearnMore,
                icon: Icon(Icons.play_circle_outline, size: 18, color: color),
                label: Text(
                  '看圖文教學',
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// 橫向步驟流程圖（適合課程 4 步驟等）
class KidVisualFlowPanel extends StatelessWidget {
  final String title;
  final List<KidGuideStep> steps;
  final VoidCallback? onTapHelp;

  const KidVisualFlowPanel({
    super.key,
    required this.title,
    required this.steps,
    this.onTapHelp,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF3EFFF),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.primaryColor.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.lightbulb_rounded,
                  color: AppTheme.primaryColor, size: 20),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ),
              if (onTapHelp != null)
                TextButton(
                  onPressed: onTapHelp,
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text(
                    '詳細教學',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 108,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: steps.length,
              separatorBuilder: (_, __) => Padding(
                padding: const EdgeInsets.only(top: 28),
                child: Icon(Icons.arrow_forward_rounded,
                    size: 16, color: Colors.grey.shade400),
              ),
              itemBuilder: (context, i) {
                final s = steps[i];
                return SizedBox(
                  width: 88,
                  child: Column(
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [s.color, s.color.withValues(alpha: 0.7)],
                          ),
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: s.color.withValues(alpha: 0.25),
                              blurRadius: 6,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        alignment: Alignment.center,
                        child: Text(s.emoji, style: const TextStyle(fontSize: 26)),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        s.title,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          height: 1.2,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// 多頁圖文教學（底部彈出或全螢幕）
class KidVisualGuideSheet extends StatefulWidget {
  final String title;
  final List<KidGuideStep> steps;
  final String finishLabel;
  final VoidCallback onFinish;

  const KidVisualGuideSheet({
    super.key,
    required this.title,
    required this.steps,
    this.finishLabel = '知道了！',
    required this.onFinish,
  });

  @override
  State<KidVisualGuideSheet> createState() => _KidVisualGuideSheetState();
}

class _KidVisualGuideSheetState extends State<KidVisualGuideSheet> {
  late final PageController _pageCtrl;
  int _page = 0;

  @override
  void initState() {
    super.initState();
    _pageCtrl = PageController();
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLast = _page == widget.steps.length - 1;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.88,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 10),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 12, 0),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      widget.onFinish();
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            ),
            Flexible(
              child: PageView.builder(
                controller: _pageCtrl,
                itemCount: widget.steps.length,
                onPageChanged: (i) => setState(() => _page = i),
                itemBuilder: (context, i) => _buildStepPage(widget.steps[i], i),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      widget.steps.length,
                      (i) => AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        width: _page == i ? 20 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _page == i
                              ? AppTheme.primaryColor
                              : Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      if (_page > 0)
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              _pageCtrl.previousPage(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeOut,
                              );
                            },
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                            ),
                            child: const Text('上一頁'),
                          ),
                        ),
                      if (_page > 0) const SizedBox(width: 12),
                      Expanded(
                        flex: _page > 0 ? 1 : 1,
                        child: KidButton(
                          label: isLast ? widget.finishLabel : '下一頁',
                          icon: isLast
                              ? Icons.check_circle_rounded
                              : Icons.arrow_forward_rounded,
                          color: AppTheme.primaryColor,
                          expanded: true,
                          onPressed: () {
                            if (isLast) {
                              widget.onFinish();
                              Navigator.of(context).pop();
                            } else {
                              _pageCtrl.nextPage(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeOut,
                              );
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepPage(KidGuideStep step, int index) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [step.color, step.color.withValues(alpha: 0.65)],
              ),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              children: [
                Text(step.emoji, style: const TextStyle(fontSize: 64)),
                if (step.icon != null) ...[
                  const SizedBox(height: 8),
                  Icon(step.icon, color: Colors.white70, size: 28),
                ],
              ],
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: step.color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '第 ${index + 1} 步 · 共 ${widget.steps.length} 步',
              style: TextStyle(
                color: step.color,
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            step.title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            step.description,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              height: 1.55,
              color: Colors.grey.shade700,
            ),
          ),
          if (step.tip != null) ...[
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFE3F2FD),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFF90CAF9)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.touch_app,
                      color: Color(0xFF1976D2), size: 22),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      step.tip!,
                      style: const TextStyle(
                        fontSize: 14,
                        height: 1.45,
                        color: Color(0xFF1565C0),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          _GuideIllustrationWidget(type: step.illustration, color: step.color),
        ],
      ),
    );
  }
}

/// 共用示意插圖元件
class _GuideIllustrationWidget extends StatelessWidget {
  final GuideIllustrationType type;
  final Color color;

  const _GuideIllustrationWidget({required this.type, required this.color});

  @override
  Widget build(BuildContext context) {
    switch (type) {
      case GuideIllustrationType.none:
        return const SizedBox.shrink();
      case GuideIllustrationType.optionSelect:
        return _mockOptionRow('A', '點一下選這個答案', selected: true, color: color);
      case GuideIllustrationType.confirmButton:
        return KidButton(
          label: '確認答案',
          icon: Icons.check,
          color: color,
          expanded: true,
          onPressed: () {},
        );
      case GuideIllustrationType.stars:
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            3,
            (_) => const Padding(
              padding: EdgeInsets.symmetric(horizontal: 4),
              child: Icon(Icons.star_rounded, color: Colors.amber, size: 36),
            ),
          ),
        );
      case GuideIllustrationType.progressSteps:
        return Row(
          children: [
            _miniStepBar(color, active: true),
            const SizedBox(width: 6),
            _miniStepBar(color, active: true),
            const SizedBox(width: 6),
            _miniStepBar(color, active: false),
          ],
        );
      case GuideIllustrationType.vocabCard:
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: color.withValues(alpha: 0.3)),
          ),
          child: const Row(
            children: [
              SizedBox(
                width: 44,
                height: 44,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                  child: Center(
                    child: Text('字', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
                  ),
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('字的意思', style: TextStyle(fontWeight: FontWeight.w700)),
                    Text('例：用這個字造句', style: TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
              ),
            ],
          ),
        );
      case GuideIllustrationType.ttsButton:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.volume_up_rounded, color: color, size: 28),
              const SizedBox(width: 8),
              Text('按喇叭聽朗讀', style: TextStyle(color: color, fontWeight: FontWeight.w700)),
            ],
          ),
        );
      case GuideIllustrationType.readingContent:
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('課程內容', style: TextStyle(fontWeight: FontWeight.w800, color: color)),
              const SizedBox(height: 6),
              Text(
                '慢慢讀完這段文字，不懂可以按喇叭再聽一次。',
                style: TextStyle(fontSize: 13, height: 1.5, color: Colors.grey.shade700),
              ),
            ],
          ),
        );
      case GuideIllustrationType.tapReveal:
        return Column(
          children: [
            _mockOptionRow('B', '點選後馬上顯示對錯', selected: true, color: color),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.info_outline, size: 16, color: Colors.grey.shade600),
                const SizedBox(width: 4),
                Text('複習不用按「確認」，點選即揭曉', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
              ],
            ),
          ],
        );
      case GuideIllustrationType.dailyReview:
        return Row(
          children: [
            _miniSubjectChip('國', const Color(0xFFE57373)),
            const SizedBox(width: 6),
            _miniSubjectChip('數', const Color(0xFF64B5F6)),
            const SizedBox(width: 6),
            _miniSubjectChip('英', const Color(0xFF81C784)),
            const SizedBox(width: 6),
            const Icon(Icons.shuffle, color: Colors.grey, size: 20),
            const SizedBox(width: 4),
            Text('10 題', style: TextStyle(fontWeight: FontWeight.w800, color: color)),
          ],
        );
      case GuideIllustrationType.gradeSelector:
        return Row(
          children: [
            _gradeChip('1', false),
            const SizedBox(width: 6),
            _gradeChip('2', true),
            const SizedBox(width: 6),
            _gradeChip('3', false),
          ],
        );
      case GuideIllustrationType.subjectGrid:
        return Row(
          children: [
            _miniSubjectChip('國', const Color(0xFFE57373)),
            const SizedBox(width: 8),
            _miniSubjectChip('數', const Color(0xFF64B5F6)),
            const SizedBox(width: 8),
            _miniSubjectChip('自', const Color(0xFFBA68C8)),
          ],
        );
      case GuideIllustrationType.gameCard:
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [color, color.withValues(alpha: 0.7)]),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Row(
            children: [
              Text('🃏', style: TextStyle(fontSize: 28)),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  '點卡片進入遊戲',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
                ),
              ),
              Icon(Icons.play_circle_fill, color: Colors.white, size: 32),
            ],
          ),
        );
      case GuideIllustrationType.lessonFlow:
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _flowDot('👀', color),
            Icon(Icons.arrow_forward, size: 14, color: Colors.grey.shade400),
            _flowDot('📖', color),
            Icon(Icons.arrow_forward, size: 14, color: Colors.grey.shade400),
            _flowDot('✏️', color),
            Icon(Icons.arrow_forward, size: 14, color: Colors.grey.shade400),
            _flowDot('🔄', color),
          ],
        );
    }
  }

  Widget _miniStepBar(Color color, {required bool active}) {
    return Expanded(
      child: Container(
        height: 6,
        decoration: BoxDecoration(
          color: active ? color : color.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(3),
        ),
      ),
    );
  }

  Widget _miniSubjectChip(String label, Color chipColor) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: chipColor.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: chipColor.withValues(alpha: 0.4)),
      ),
      alignment: Alignment.center,
      child: Text(label, style: TextStyle(color: chipColor, fontWeight: FontWeight.w900)),
    );
  }

  Widget _gradeChip(String grade, bool selected) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: selected ? color : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: selected ? color : Colors.grey.shade300),
      ),
      child: Text(
        '$grade 年級',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: selected ? Colors.white : Colors.black87,
        ),
      ),
    );
  }

  Widget _flowDot(String emoji, Color dotColor) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: dotColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
      ),
      alignment: Alignment.center,
      child: Text(emoji, style: const TextStyle(fontSize: 18)),
    );
  }

  Widget _mockOptionRow(String letter, String text, {bool selected = false, required Color color}) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: selected ? color.withValues(alpha: 0.08) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: selected ? color : Colors.grey.shade300,
          width: 2,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: selected ? color : Colors.grey.shade400,
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: Text(
              letter,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: selected ? color : Colors.black87,
              ),
            ),
          ),
          if (selected)
            Icon(Icons.touch_app, color: color, size: 22),
        ],
      ),
    );
  }
}

/// 顯示圖文教學並標記已看過
Future<void> showKidVisualGuide(
  BuildContext context, {
  required String title,
  required List<KidGuideStep> steps,
  String finishLabel = '知道了！',
  String? guideId,
}) async {
  if (!context.mounted) return;
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => KidVisualGuideSheet(
      title: title,
      steps: steps,
      finishLabel: finishLabel,
      onFinish: () {
        if (guideId != null) {
          ctx.read<ProgressProvider>().markTutorialSeen(guideId);
        }
      },
    ),
  );
}

/// 若尚未看過則顯示教學
Future<void> showKidGuideIfNeeded(
  BuildContext context, {
  required String guideId,
  required String title,
  required List<KidGuideStep> steps,
  String finishLabel = '知道了！',
}) async {
  final progress = context.read<ProgressProvider>();
  if (progress.hasSeenTutorial(guideId)) return;
  if (!context.mounted) return;
  await showKidVisualGuide(
    context,
    title: title,
    steps: steps,
    finishLabel: finishLabel,
    guideId: guideId,
  );
}

// ── 預設教學內容 ──

const kHomeGuideSteps = [
  KidGuideStep(
    emoji: '👋',
    color: AppTheme.primaryColor,
    title: '歡迎來到小學堂！',
    description: '這是你的學習首頁。每天來這裡，看看今天要學什麼、玩什麼。',
    tip: '點左上角的頭像，可以切換不同小朋友喔！',
  ),
  KidGuideStep(
    emoji: '✨',
    color: Color(0xFF7C4DFF),
    title: '每日複習',
    description: '紫色卡片是「每日複習」。會從學過的課程中出 10 題，幫你把知識記更牢。',
    tip: '建議每天固定時間做一次複習。',
  ),
  KidGuideStep(
    emoji: '📋',
    color: Color(0xFF42A5F5),
    title: '今日任務',
    description: '這裡會推薦一課給你。點右邊的播放按鈕 ▶，就能開始學習！',
    tip: '完成任務可以獲得星星 ⭐',
  ),
  KidGuideStep(
    emoji: '🎮',
    color: Color(0xFFFFA726),
    title: '小遊戲',
    description: '記憶翻牌、數學快閃、單字雨……用遊戲的方式練習，邊玩邊學更有趣！',
    tip: '往左滑可以看到更多遊戲。',
  ),
  KidGuideStep(
    emoji: '📚',
    color: Color(0xFF66BB6A),
    title: '選擇學科',
    description: '點選國語、數學等科目，進入該科的課程列表，依自己的進度學習。',
    tip: '圓圈進度條顯示這一科完成了多少。',
  ),
];

const kBottomNavGuideSteps = [
  KidGuideStep(
    emoji: '🏠',
    color: AppTheme.primaryColor,
    title: '首頁',
    description: '看今日推薦、每日複習，還有學習進度總覽。',
  ),
  KidGuideStep(
    emoji: '🎓',
    color: Color(0xFF42A5F5),
    title: '學科',
    description: '六大學習領域都在這裡，可以瀏覽所有課程單元。',
  ),
  KidGuideStep(
    emoji: '🕹️',
    color: Color(0xFFFFA726),
    title: '遊戲',
    description: '趣味小遊戲專區，用不同方式複習所學內容。',
  ),
  KidGuideStep(
    emoji: '🏆',
    color: Color(0xFFFFB300),
    title: '成就',
    description: '看看你獲得了幾顆星星、哪些徽章，還有連續打卡紀錄！',
  ),
  KidGuideStep(
    emoji: '👨‍👩‍👧',
    color: Color(0xFFEF5350),
    title: '家長',
    description: '這一頁是給爸媽看的，可以了解孩子的學習進度。（小朋友也可以請爸媽幫忙看喔）',
  ),
];

const kLessonFlowGuideSteps = [
  KidGuideStep(
    emoji: '👀',
    color: Color(0xFF42A5F5),
    title: 'STEP 1 · 預習',
    description: '先看學習目標、重點和關鍵字詞，對這一課有初步認識。',
    tip: '預習不用背，先「認識」就好！',
    illustration: GuideIllustrationType.progressSteps,
  ),
  KidGuideStep(
    emoji: '📖',
    color: Color(0xFF66BB6A),
    title: 'STEP 2 · 學習',
    description: '閱讀課程內容，可以按喇叭 🔊 聽語音朗讀。',
    tip: '讀完記得按「我讀完了」進入下一步。',
    illustration: GuideIllustrationType.ttsButton,
  ),
  KidGuideStep(
    emoji: '✏️',
    color: Color(0xFFFFA726),
    title: 'STEP 3 · 測驗',
    description: '做題目檢驗學習成果。答對越多，星星越多！',
    tip: '答錯沒關係，會顯示解說幫助你理解。',
    illustration: GuideIllustrationType.optionSelect,
  ),
  KidGuideStep(
    emoji: '🔄',
    color: Color(0xFFEF5350),
    title: 'STEP 4 · 複習',
    description: '回顧重點，再做混合題挑戰，把知識記更牢固。',
    tip: '建議完成測驗後再來複習，效果最好。',
    illustration: GuideIllustrationType.tapReveal,
  ),
];

const kQuizGuideSteps = [
  KidGuideStep(
    emoji: '👆',
    color: Color(0xFF42A5F5),
    title: '選一個答案',
    description: '仔細讀題目，點一下你覺得正確的選項（A、B、C、D）。',
    tip: '選中的選項會變色，表示已選取。',
    illustration: GuideIllustrationType.optionSelect,
  ),
  KidGuideStep(
    emoji: '✅',
    color: Color(0xFF66BB6A),
    title: '按「確認答案」',
    description: '選好答案後，按下方的大按鈕確認。馬上就知道對不對！',
    tip: '綠色代表答對，紅色代表答錯。',
    illustration: GuideIllustrationType.confirmButton,
  ),
  KidGuideStep(
    emoji: '💡',
    color: Color(0xFFFFB300),
    title: '看解說',
    description: '答完後會出現黃色解說框，幫你了解為什麼這樣答。',
    tip: '答錯時更要仔細看解說喔！',
    illustration: GuideIllustrationType.readingContent,
  ),
  KidGuideStep(
    emoji: '➡️',
    color: Color(0xFFFFA726),
    title: '下一題',
    description: '看完解說後，按「下一題」繼續。全部答完可以看成績和星星！',
    tip: '上方進度條顯示還剩幾題。',
    illustration: GuideIllustrationType.stars,
  ),
];

const kLessonListGuideSteps = [
  KidGuideStep(
    emoji: '📅',
    color: Color(0xFF42A5F5),
    title: '篩選學期',
    description: '上方可以選「上學期」或「下學期」，找到對應的課程單元。',
    tip: '再按一次可以取消篩選，顯示全部。',
    illustration: GuideIllustrationType.gradeSelector,
  ),
  KidGuideStep(
    emoji: '⭐',
    color: Color(0xFFFFB300),
    title: '星星代表成績',
    description: '每完成一課的測驗，會依答對率獲得 1～3 顆星。',
    tip: '三顆星代表超棒！可以再挑戰複習。',
    illustration: GuideIllustrationType.stars,
  ),
  KidGuideStep(
    emoji: '▶️',
    color: Color(0xFF66BB6A),
    title: '點課程開始',
    description: '點任一課程，進入「預習→學習→測驗→複習」四步驟流程。',
    tip: '建議從第一課依序學習。',
    illustration: GuideIllustrationType.lessonFlow,
  ),
];

const kPreviewGuideSteps = [
  KidGuideStep(
    emoji: '🎯',
    color: Color(0xFF42A5F5),
    title: '先看學習目標',
    description: '第一頁會告訴你這一課要學什麼，不用背下來，先認識就好！',
    tip: '上方彩色進度條顯示你目前在第幾步。',
    illustration: GuideIllustrationType.progressSteps,
  ),
  KidGuideStep(
    emoji: '💡',
    color: Color(0xFFFFB300),
    title: '重點搶先看',
    description: '第二頁列出這一課最重要的知識，帶著這些重點去學習會更輕鬆。',
    tip: '看到 ⭐ 的就是重點喔！',
    illustration: GuideIllustrationType.readingContent,
  ),
  KidGuideStep(
    emoji: '📖',
    color: Color(0xFF66BB6A),
    title: '認識關鍵字詞',
    description: '如果有字詞卡，左邊是大字、右邊是意思和例句，先熟悉這些字。',
    tip: '不確定發音？進入「學習」步驟可以聽語音朗讀。',
    illustration: GuideIllustrationType.vocabCard,
  ),
  KidGuideStep(
    emoji: '▶️',
    color: Color(0xFF7C4DFF),
    title: '按「開始學習」',
    description: '看完所有預習步驟後，按下方大按鈕進入正式課程內容。',
    tip: '可以按「上一步」回去再看一次。',
    illustration: GuideIllustrationType.lessonFlow,
  ),
];

const kStudyGuideSteps = [
  KidGuideStep(
    emoji: '📖',
    color: Color(0xFF66BB6A),
    title: '慢慢讀課程內容',
    description: '這一頁是完整的課文，用手指滑動可以看完所有內容。',
    tip: '讀不懂的地方可以多看幾次，不用急！',
    illustration: GuideIllustrationType.readingContent,
  ),
  KidGuideStep(
    emoji: '🔊',
    color: Color(0xFF42A5F5),
    title: '按喇叭聽朗讀',
    description: '右上角有喇叭按鈕，按一下會用語音把課文念出來，幫助聽懂。',
    tip: '再按一次可以停止朗讀。',
    illustration: GuideIllustrationType.ttsButton,
  ),
  KidGuideStep(
    emoji: '✅',
    color: Color(0xFFFFA726),
    title: '讀完進測驗',
    description: '確定讀完後，按「接下來：測驗」做題目，檢查你學到了多少！',
    tip: '建議至少讀完一遍再測驗，分數會更好。',
    illustration: GuideIllustrationType.confirmButton,
  ),
];

const kReviewGuideSteps = [
  KidGuideStep(
    emoji: '📝',
    color: Color(0xFFEF5350),
    title: '先看重點回顧',
    description: '開始答題前，會先列出這一課的重點和字詞，幫你喚醒記憶。',
    tip: '可以花一點時間再看一遍重點。',
    illustration: GuideIllustrationType.readingContent,
  ),
  KidGuideStep(
    emoji: '👆',
    color: Color(0xFF42A5F5),
    title: '點選答案就揭曉',
    description: '複習模式和測驗不同：點一下選項，馬上就知道對不對，不用按確認！',
    tip: '綠色＝答對，紅色＝答錯。',
    illustration: GuideIllustrationType.tapReveal,
  ),
  KidGuideStep(
    emoji: '💡',
    color: Color(0xFFFFB300),
    title: '看解說再下一題',
    description: '答完會顯示黃色解說框，看完後按「下一題」繼續。',
    tip: '複習題目可能來自不同單元，考驗綜合理解。',
    illustration: GuideIllustrationType.readingContent,
  ),
  KidGuideStep(
    emoji: '⭐',
    color: Color(0xFFFFA726),
    title: '完成拿星星',
    description: '全部答完會顯示成績和星星，複習也是學習的重要一步！',
    tip: '答錯的題目可以回去課程再讀一次。',
    illustration: GuideIllustrationType.stars,
  ),
];

const kDailyReviewGuideSteps = [
  KidGuideStep(
    emoji: '✨',
    color: Color(0xFF7C4DFF),
    title: '每天練 10 題',
    description: '每日複習會從學過的課程和題庫中，隨機抽出 10 題綜合練習。',
    tip: '建議每天固定時間做一次。',
    illustration: GuideIllustrationType.dailyReview,
  ),
  KidGuideStep(
    emoji: '🎲',
    color: Color(0xFFFFA726),
    title: '選綜合或單科',
    description: '「綜合複習」混合所有科目；也可以選單一學科專心練習。',
    tip: '至少完成幾課後，綜合複習才會有題目。',
    illustration: GuideIllustrationType.subjectGrid,
  ),
  KidGuideStep(
    emoji: '👆',
    color: Color(0xFF42A5F5),
    title: '點選即揭曉',
    description: '和複習模式一樣，點一下答案就知道對錯，看完解說按下一題。',
    tip: '上方進度條顯示第幾題。',
    illustration: GuideIllustrationType.tapReveal,
  ),
];

const kSubjectsGuideSteps = [
  KidGuideStep(
    emoji: '🎓',
    color: Color(0xFF42A5F5),
    title: '選擇你的年級',
    description: '上方可以切換 1～6 年級，課程內容會跟著改變。',
    tip: '年級設定會保存在你的小朋友帳號裡。',
    illustration: GuideIllustrationType.gradeSelector,
  ),
  KidGuideStep(
    emoji: '📚',
    color: Color(0xFF66BB6A),
    title: '六大學習領域',
    description: '國語、數學、英語、自然、社會、綜合活動，點選科目進入課程列表。',
    tip: '圓圈進度條顯示這一科完成了多少。',
    illustration: GuideIllustrationType.subjectGrid,
  ),
  KidGuideStep(
    emoji: '▶️',
    color: Color(0xFF7C4DFF),
    title: '開始學習',
    description: '進入課程列表後，選一課開始「預習→學習→測驗→複習」。',
    tip: '建議依序完成，知識會更扎實。',
    illustration: GuideIllustrationType.lessonFlow,
  ),
];

const kGamesGuideSteps = [
  KidGuideStep(
    emoji: '🎮',
    color: Color(0xFFFFA726),
    title: '邊玩邊學',
    description: '這裡有小遊戲和練習，用有趣的方式複習所學內容。',
    tip: '玩遊戲也是學習的一種喔！',
    illustration: GuideIllustrationType.gameCard,
  ),
  KidGuideStep(
    emoji: '🃏',
    color: Color(0xFF7C4DFF),
    title: '記憶翻牌',
    description: '找出相同的一對卡片，訓練記憶力和字詞／數字認識。',
    tip: '翻錯了沒關係，再試一次！',
    illustration: GuideIllustrationType.gameCard,
  ),
  KidGuideStep(
    emoji: '⚡',
    color: Color(0xFFFFB300),
    title: '數學快閃',
    description: '60 秒限時答題，看你能算多少題，越答越厲害！',
    tip: '難度會依年級自動調整。',
    illustration: GuideIllustrationType.gameCard,
  ),
  KidGuideStep(
    emoji: '✍️',
    color: Color(0xFFEF5350),
    title: '手寫與複習',
    description: '還有國字手寫練習和每日複習，點卡片就能進入。',
    tip: '手寫可以用手指在螢幕上描字。',
    illustration: GuideIllustrationType.gameCard,
  ),
];
