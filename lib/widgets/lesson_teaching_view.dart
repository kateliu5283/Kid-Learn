import 'package:flutter/material.dart';
import '../models/lesson_block.dart';
import '../services/lesson_content_parser.dart';
import '../models/lesson.dart';

/// 以圖文卡片呈現單元教學內容（課文、範例、步驟、注音等）。
class LessonTeachingView extends StatelessWidget {
  final Lesson lesson;
  final Color accent;
  final bool compact;
  /// 僅顯示前 N 個區塊（首頁預覽用）；null 表示全部。
  final int? maxBlocks;
  final bool showSectionLabels;

  const LessonTeachingView({
    super.key,
    required this.lesson,
    required this.accent,
    this.compact = false,
    this.maxBlocks,
    this.showSectionLabels = true,
  });

  static const _sectionIntro = {
    LessonBlockKind.intro,
    LessonBlockKind.heading,
    LessonBlockKind.paragraph,
  };
  static const _sectionFocus = {
    LessonBlockKind.bullet,
    LessonBlockKind.phonics,
    LessonBlockKind.example,
    LessonBlockKind.compare,
  };
  static const _sectionDo = {LessonBlockKind.step};
  static const _sectionThink = {LessonBlockKind.tip};

  @override
  Widget build(BuildContext context) {
    final allBlocks = LessonContentParser.blocksFor(lesson);
    if (allBlocks.isEmpty) {
      return _ParagraphCard(
        text: lesson.summary.isNotEmpty ? lesson.summary : lesson.content,
        accent: accent,
      );
    }

    final blocks = maxBlocks != null && maxBlocks! < allBlocks.length
        ? allBlocks.sublist(0, maxBlocks!)
        : allBlocks;

    if (!showSectionLabels) {
      return _buildFlat(blocks);
    }

    final sections = _groupSections(blocks);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final section in sections) ...[
          _SectionHeader(label: section.label, icon: section.icon, color: accent),
          SizedBox(height: compact ? 8 : 10),
          _buildFlat(section.blocks),
          SizedBox(height: compact ? 14 : 18),
        ],
        if (maxBlocks != null && allBlocks.length > maxBlocks!)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              '還有 ${allBlocks.length - maxBlocks!} 段內容，點「開始學習」看完整課文',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
          ),
      ],
    );
  }

  Widget _buildFlat(List<LessonBlock> blocks) {
    final widgets = <Widget>[];
    var i = 0;
    while (i < blocks.length) {
      if (blocks[i].kind == LessonBlockKind.phonics) {
        final group = <LessonBlock>[];
        while (i < blocks.length && blocks[i].kind == LessonBlockKind.phonics) {
          group.add(blocks[i]);
          i++;
        }
        widgets.add(_PhonicsGridCard(blocks: group, accent: accent, compact: compact));
        continue;
      }
      widgets.add(_BlockCard(block: blocks[i], accent: accent, compact: compact));
      if (i < blocks.length - 1) {
        widgets.add(SizedBox(height: compact ? 8 : 12));
      }
      i++;
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: widgets,
    );
  }

  List<_TeachingSection> _groupSections(List<LessonBlock> blocks) {
    final intro = <LessonBlock>[];
    final focus = <LessonBlock>[];
    final doing = <LessonBlock>[];
    final think = <LessonBlock>[];

    for (final b in blocks) {
      if (_sectionIntro.contains(b.kind)) {
        intro.add(b);
      } else if (_sectionFocus.contains(b.kind)) {
        focus.add(b);
      } else if (_sectionDo.contains(b.kind)) {
        doing.add(b);
      } else if (_sectionThink.contains(b.kind)) {
        think.add(b);
      } else {
        focus.add(b);
      }
    }

    final out = <_TeachingSection>[];
    if (intro.isNotEmpty) {
      out.add(_TeachingSection('認識這一課', Icons.auto_stories_rounded, intro));
    }
    if (focus.isNotEmpty) {
      out.add(_TeachingSection('重點整理', Icons.star_rounded, focus));
    }
    if (doing.isNotEmpty) {
      out.add(_TeachingSection('跟著做', Icons.pan_tool_alt_rounded, doing));
    }
    if (think.isNotEmpty) {
      out.add(_TeachingSection('想一想', Icons.lightbulb_rounded, think));
    }
    if (out.isEmpty) {
      out.add(_TeachingSection('課文內容', Icons.menu_book_rounded, blocks));
    }
    return out;
  }
}

class _TeachingSection {
  final String label;
  final IconData icon;
  final List<LessonBlock> blocks;
  const _TeachingSection(this.label, this.icon, this.blocks);
}

class _SectionHeader extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;

  const _SectionHeader({
    required this.label,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: color, size: compactIconSize(context)),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w900,
            color: color,
          ),
        ),
      ],
    );
  }

  double compactIconSize(BuildContext context) => 20;
}

class _BlockCard extends StatelessWidget {
  final LessonBlock block;
  final Color accent;
  final bool compact;

  const _BlockCard({
    required this.block,
    required this.accent,
    required this.compact,
  });

  @override
  Widget build(BuildContext context) {
    switch (block.kind) {
      case LessonBlockKind.intro:
        return _IntroCard(text: block.text, accent: accent, compact: compact);
      case LessonBlockKind.heading:
        return _HeadingLabel(text: block.text, accent: accent);
      case LessonBlockKind.paragraph:
        return _ParagraphCard(text: block.text, accent: accent, compact: compact);
      case LessonBlockKind.bullet:
        return _BulletCard(block: block, accent: accent, compact: compact);
      case LessonBlockKind.example:
        return _ExampleCard(block: block, accent: accent, compact: compact);
      case LessonBlockKind.step:
        return _StepCard(block: block, accent: accent, compact: compact);
      case LessonBlockKind.tip:
        return _TipCard(text: block.text, accent: accent, compact: compact);
      case LessonBlockKind.compare:
        return _CompareCard(text: block.text, accent: accent, compact: compact);
      case LessonBlockKind.phonics:
        return _PhonicsGridCard(blocks: [block], accent: accent, compact: compact);
    }
  }
}

class _IntroCard extends StatelessWidget {
  final String text;
  final Color accent;
  final bool compact;

  const _IntroCard({
    required this.text,
    required this.accent,
    required this.compact,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(compact ? 14 : 18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [accent.withValues(alpha: 0.15), accent.withValues(alpha: 0.05)],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: accent.withValues(alpha: 0.35)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.auto_stories_rounded, color: accent, size: compact ? 24 : 28),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: compact ? 15 : 17,
                height: 1.55,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeadingLabel extends StatelessWidget {
  final String text;
  final Color accent;

  const _HeadingLabel({required this.text, required this.accent});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 4, bottom: 2),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 20,
            decoration: BoxDecoration(
              color: accent,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w900,
              color: accent,
            ),
          ),
        ],
      ),
    );
  }
}

class _ParagraphCard extends StatelessWidget {
  final String text;
  final Color accent;
  final bool compact;

  const _ParagraphCard({
    required this.text,
    required this.accent,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(compact ? 12 : 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Text(
        text,
        style: TextStyle(fontSize: compact ? 14 : 16, height: 1.75),
      ),
    );
  }
}

class _BulletCard extends StatelessWidget {
  final LessonBlock block;
  final Color accent;
  final bool compact;

  const _BulletCard({
    required this.block,
    required this.accent,
    required this.compact,
  });

  @override
  Widget build(BuildContext context) {
    final hasLeading = block.leading != null && block.leading!.isNotEmpty;
    return Container(
      padding: EdgeInsets.all(compact ? 12 : 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: accent.withValues(alpha: 0.25)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (hasLeading)
            Container(
              width: compact ? 40 : 48,
              height: compact ? 40 : 48,
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.center,
              child: Text(
                block.leading!,
                style: TextStyle(fontSize: compact ? 20 : 24),
              ),
            )
          else
            Icon(Icons.check_circle_rounded, color: accent, size: 22),
          SizedBox(width: hasLeading ? 12 : 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (block.title != null)
                  Text(
                    block.title!,
                    style: TextStyle(
                      fontSize: compact ? 15 : 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                Text(
                  block.text,
                  style: TextStyle(
                    fontSize: compact ? 13 : 14,
                    height: 1.5,
                    color: Colors.grey.shade800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ExampleCard extends StatelessWidget {
  final LessonBlock block;
  final Color accent;
  final bool compact;

  const _ExampleCard({
    required this.block,
    required this.accent,
    required this.compact,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(compact ? 12 : 16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFFE082)),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.center,
              child: Text(
                block.leading ?? '',
                style: TextStyle(fontSize: compact ? 18 : 22, height: 1.3),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Icon(Icons.arrow_forward_rounded, color: accent, size: 28),
          ),
          Expanded(
            flex: 3,
            child: Text(
              block.text,
              style: TextStyle(
                fontSize: compact ? 14 : 15,
                fontWeight: FontWeight.w700,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StepCard extends StatelessWidget {
  final LessonBlock block;
  final Color accent;
  final bool compact;

  const _StepCard({
    required this.block,
    required this.accent,
    required this.compact,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(compact ? 12 : 14),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: accent.withValues(alpha: 0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: accent,
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: Text(
              block.leading ?? '•',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              block.text,
              style: TextStyle(
                fontSize: compact ? 14 : 15,
                height: 1.55,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TipCard extends StatelessWidget {
  final String text;
  final Color accent;
  final bool compact;

  const _TipCard({
    required this.text,
    required this.accent,
    required this.compact,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(compact ? 12 : 14),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5E9),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFA5D6A7)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.lightbulb_rounded, color: Color(0xFF43A047), size: 22),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: compact ? 13 : 14,
                height: 1.5,
                color: const Color(0xFF2E7D32),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CompareCard extends StatelessWidget {
  final String text;
  final Color accent;
  final bool compact;

  const _CompareCard({
    required this.text,
    required this.accent,
    required this.compact,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(compact ? 12 : 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            accent.withValues(alpha: 0.12),
            accent.withValues(alpha: 0.04),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: accent.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.compare_arrows_rounded, color: accent, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: compact ? 14 : 15,
                fontWeight: FontWeight.w700,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PhonicsGridCard extends StatelessWidget {
  final List<LessonBlock> blocks;
  final Color accent;
  final bool compact;

  const _PhonicsGridCard({
    required this.blocks,
    required this.accent,
    required this.compact,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(compact ? 12 : 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: accent.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.spellcheck_rounded, color: accent, size: 20),
              const SizedBox(width: 6),
              Text(
                '注音與例字',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: accent,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: blocks.map((b) {
              return Container(
                width: compact ? 72 : 80,
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: accent.withValues(alpha: 0.2)),
                ),
                child: Column(
                  children: [
                    Text(
                      b.leading ?? '',
                      style: TextStyle(
                        fontSize: compact ? 20 : 22,
                        fontWeight: FontWeight.w900,
                        color: accent,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      b.text,
                      style: TextStyle(
                        fontSize: compact ? 16 : 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
