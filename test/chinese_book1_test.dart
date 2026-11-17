import 'package:flutter_test/flutter_test.dart';
import 'package:kid_learn/curriculum/chinese/book1/hanlin_book.dart';
import 'package:kid_learn/curriculum/chinese/book1/kangxuan_book.dart';
import 'package:kid_learn/curriculum/chinese/book1/nani_book.dart';
import 'package:kid_learn/curriculum/chinese/primer/hanlin_primer.dart';
import 'package:kid_learn/curriculum/chinese/primer/kangxuan_primer.dart';
import 'package:kid_learn/curriculum/chinese/primer/nani_primer.dart';
import 'package:kid_learn/curriculum/handwriting/lesson_writing.dart';
import 'package:kid_learn/models/lesson.dart';

void main() {
  test('國語第一冊三版本課次與冊別都齊', () {
    expect(kKangxuanBookLessons.map((l) => l.title).toList(), [
      '國字真簡單',
      '拍拍手',
      '這是誰的？',
      '秋千',
      '大個子，小個子',
      '比一比',
      '小路',
    ]);
    expect(kHanlinBookLessons.map((l) => l.title).toList(), [
      '一起走',
      '大風吹',
      '火車過山洞',
      '請問',
      '七彩的滑梯',
      '秋千',
      '回音',
    ]);
    expect(kNaniBookLessons.map((l) => l.title).toList(), [
      '魔法文字',
      '小船',
      '印手印',
      '吹泡泡',
      '你好',
      '外星人',
      '小金魚',
      '紅紅的春',
    ]);

    expect(kKangxuanPrimerLessons.first.editionLabel, '康軒 · 1上 首冊 第 1 課');
    expect(kKangxuanBookLessons.first.editionLabel, '康軒 · 1上 第一冊 入門');
    expect(kKangxuanBookLessons[1].editionLabel, '康軒 · 1上 第一冊 第 1 課');
    expect(kHanlinBookLessons.first.editionLabel, '翰林 · 1上 第一冊 第 1 課');
    expect(kNaniBookLessons[1].editionLabel, '南一 · 1上 第一冊 第 1 課');

    final books = [
      ...kKangxuanBookLessons,
      ...kHanlinBookLessons,
      ...kNaniBookLessons,
    ];
    final primers = [
      ...kKangxuanPrimerLessons,
      ...kHanlinPrimerLessons,
      ...kNaniPrimerLessons,
    ];
    final ids = {...primers.map((l) => l.id), ...books.map((l) => l.id)};
    expect(ids.length, primers.length + books.length);

    for (final lesson in books) {
      expect(lesson.part, TextbookPart.volumeOne);
      expect(lesson.grade, 1);
      expect(lesson.semester, Semester.first);
      expect(lesson.questions.length, inInclusiveRange(20, 24), reason: lesson.id);
      expect(lesson.writingPractice.length, greaterThanOrEqualTo(8), reason: lesson.title);
      final prompts = lesson.questions.map((q) => q.prompt).toList();
      expect(prompts.toSet().length, prompts.length, reason: lesson.id);
      final passage = lesson.content.split('生字：').first;
      for (final glyph in lesson.writingPractice) {
        expect(passage.contains(glyph.char), isTrue, reason: '${lesson.title} ${glyph.char}');
        expect(_strokes[glyph.char], glyph.strokes, reason: glyph.char);
        expect(_readings[glyph.char], glyph.zhuyin, reason: glyph.char);
      }
      expect(
        lesson.content.contains(
          '生字：${lesson.writingPractice.map((g) => g.char).join('、')}',
        ),
        isTrue,
        reason: lesson.id,
      );
      for (final q in lesson.questions) {
        expect(q.options.length, 4, reason: q.prompt);
        expect(q.options.toSet().length, 4, reason: q.prompt);
        expect(q.correctIndex, inInclusiveRange(0, 3));
        expect(q.explanation, isNotNull);
        if (q.id.contains('-bank-')) {
          expect(
            _checkBank(q.prompt, q.options[q.correctIndex], q.explanation!, lesson),
            isTrue,
            reason: '${lesson.title} ${q.prompt}',
          );
        }
      }
      final set = writingSetFor(lesson);
      expect(set, isNotNull);
      expect(set!.name, '${lesson.publisher!.label}・${lesson.title}');
    }

    final kx = [...kKangxuanPrimerLessons, ...kKangxuanBookLessons]..sort(_byPartThenUnit);
    expect(kx.first.title, '貓咪');
    expect(kx[kKangxuanPrimerLessons.length].title, '國字真簡單');
    expect(kx.last.title, '小路');
  });
}

int _byPartThenUnit(Lesson a, Lesson b) {
  final part = (a.part?.order ?? 99).compareTo(b.part?.order ?? 99);
  if (part != 0) return part;
  return (a.unit ?? 99).compareTo(b.unit ?? 99);
}

bool _checkBank(String prompt, String answer, String explanation, Lesson lesson) {
  final byChar = {
    for (final g in lesson.writingPractice) g.char: g,
  };
  final byReading = {
    for (final g in lesson.writingPractice) g.zhuyin: g.char,
  };

  final reading = RegExp(r'^「(.)」的注音是哪一個？$').firstMatch(prompt);
  if (reading != null) {
    final glyph = byChar[reading.group(1)!]!;
    expect(answer, glyph.zhuyin);
    expect(explanation, '${glyph.char}的注音是 ${glyph.zhuyin}。');
    return true;
  }

  final strokes = RegExp(r'^「(.)」有幾畫？$').firstMatch(prompt);
  if (strokes != null) {
    final glyph = byChar[strokes.group(1)!]!;
    expect(answer, '${glyph.strokes} 畫');
    expect(explanation, '${glyph.char}有 ${glyph.strokes} 畫。');
    return true;
  }

  final tone = RegExp(r'^「(.)」的聲調是？$').firstMatch(prompt);
  if (tone != null) {
    final glyph = byChar[tone.group(1)!]!;
    expect(answer, _toneName(glyph.zhuyin));
    expect(explanation, contains(glyph.zhuyin));
    return true;
  }

  final which = RegExp(r'^哪一個字念「(.+)」？$').firstMatch(prompt);
  if (which != null) {
    expect(byReading[which.group(1)], answer);
    expect(explanation, '${which.group(1)} 是「$answer」。');
    return true;
  }

  final meaning = RegExp(r'^「(.+)」的意思最接近？$').firstMatch(prompt);
  if (meaning != null) {
    final term = meaning.group(1)!;
    if (term.runes.length == 1 && byChar.containsKey(term)) {
      expect(answer, byChar[term]!.meaning);
    } else {
      final vocab = lesson.vocabulary.where((v) => v.term == term);
      expect(vocab, isNotEmpty, reason: prompt);
      expect(answer, vocab.first.meaning);
    }
    expect(explanation, contains(answer));
    return true;
  }

  final sentence = RegExp(r'^哪一句用到了「(.+)」？$').firstMatch(prompt);
  if (sentence != null) {
    expect(answer.contains(sentence.group(1)!), isTrue);
    return true;
  }

  fail('未檢查的題目：$prompt');
}

String _toneName(String reading) {
  if (reading.contains('˙')) return '輕聲';
  if (reading.contains('ˋ')) return '四聲';
  if (reading.contains('ˇ')) return '三聲';
  if (reading.contains('ˊ')) return '二聲';
  return '一聲';
}

const _strokes = <String, int>{
  '一': 1, '了': 2, '人': 2, '七': 2, '八': 2, '又': 2, '九': 2, '二': 2, '十': 2,
  '上': 3, '下': 3, '大': 3, '子': 3, '小': 3, '山': 3, '千': 3, '也': 3, '三': 3,
  '不': 4, '比': 4, '天': 4, '心': 4, '手': 4, '日': 4, '月': 4, '木': 4, '水': 4,
  '火': 4, '王': 4, '分': 4, '友': 4, '太': 4, '少': 4, '巴': 4, '什': 4,
  '五': 4, '六': 4,
  '左': 5, '右': 5, '出': 5, '去': 5, '四': 5, '外': 5, '他': 5, '主': 5,
  '加': 5, '叫': 5, '句': 5, '田': 5, '白': 5,
  '在': 6, '多': 6, '好': 6, '早': 6, '有': 6, '朵': 6, '回': 6, '地': 6,
  '向': 6, '同': 6, '池': 6,
  '我': 7, '你': 7, '走': 7, '車': 7, '那': 7, '住': 7, '尾': 7,
  '把': 7, '沒': 7, '吹': 7, '谷': 7, '找': 7,
  '的': 8, '和': 8, '到': 8, '來': 8, '玩': 8, '朋': 8, '兩': 8, '拉': 8,
  '青': 8, '門': 8, '長': 8, '泡': 8, '招': 8, '抱': 8, '爸': 8, '金': 8,
  '房': 8, '空': 8, '拍': 8, '爬': 8, '花': 8, '呢': 8,
  '秋': 9, '紅': 9, '星': 9, '看': 9, '要': 9, '前': 9, '音': 9, '風': 9,
  '洞': 9, '春': 9, '哈': 9, '是': 9,
  '高': 10, '海': 10, '個': 10, '們': 10, '起': 10, '草': 10, '笑': 10,
  '悄': 10, '家': 10, '隻': 10,
  '這': 11, '陪': 11, '晚': 11, '從': 11, '問': 11, '彩': 11, '堆': 11,
  '停': 11, '魚': 11, '啊': 11, '都': 11,
  '跑': 12, '蛙': 12, '開': 12, '棉': 12, '貼': 12,
  '裡': 13, '路': 13, '話': 13, '想': 13, '嗎': 13,
  '說': 14, '麼': 14, '滿': 14, '福': 14,
  '誰': 15, '課': 15, '請': 15,
  '頭': 16,
};

const _readings = <String, String>{
  '一': 'ㄧ', '二': 'ㄦˋ', '三': 'ㄙㄢ', '四': 'ㄙˋ', '五': 'ㄨˇ', '六': 'ㄌㄧㄡˋ',
  '七': 'ㄑㄧ', '八': 'ㄅㄚ', '九': 'ㄐㄧㄡˇ', '十': 'ㄕˊ',
  '拍': 'ㄆㄞ', '手': 'ㄕㄡˇ', '左': 'ㄗㄨㄛˇ', '右': 'ㄧㄡˋ', '你': 'ㄋㄧˇ',
  '他': 'ㄊㄚ', '也': 'ㄧㄝˇ', '上': 'ㄕㄤˋ', '下': 'ㄒㄧㄚˋ',
  '這': 'ㄓㄜˋ', '是': 'ㄕˋ', '誰': 'ㄕㄟˊ', '的': '˙ㄉㄜ', '我': 'ㄨㄛˇ',
  '分': 'ㄈㄣ', '好': 'ㄏㄠˇ', '了': '˙ㄌㄜ', '啊': '˙ㄚ', '多': 'ㄉㄨㄛ', '個': 'ㄍㄜˋ',
  '秋': 'ㄑㄧㄡ', '千': 'ㄑㄧㄢ', '和': 'ㄏㄜˊ', '玩': 'ㄨㄢˊ', '陪': 'ㄆㄟˊ',
  '高': 'ㄍㄠ', '山': 'ㄕㄢ', '到': 'ㄉㄠˋ', '大': 'ㄉㄚˋ', '海': 'ㄏㄞˇ',
  '朋': 'ㄆㄥˊ', '友': 'ㄧㄡˇ', '們': 'ㄇㄣˊ', '起': 'ㄑㄧˇ',
  '子': 'ㄗˇ', '小': 'ㄒㄧㄠˇ', '課': 'ㄎㄜˋ', '兩': 'ㄌㄧㄤˇ', '人': 'ㄖㄣˊ',
  '拉': 'ㄌㄚ', '看': 'ㄎㄢˋ', '找': 'ㄓㄠˇ', '隻': 'ㄓ', '青': 'ㄑㄧㄥ',
  '蛙': 'ㄨㄚ', '開': 'ㄎㄞ', '心': 'ㄒㄧㄣ',
  '比': 'ㄅㄧˇ', '門': 'ㄇㄣˊ', '裡': 'ㄌㄧˇ', '外': 'ㄨㄞˋ', '有': 'ㄧㄡˇ',
  '什': 'ㄕㄣˊ', '麼': '˙ㄇㄜ', '不': 'ㄅㄨˋ', '同': 'ㄊㄨㄥˊ', '早': 'ㄗㄠˇ',
  '晚': 'ㄨㄢˇ', '王': 'ㄨㄤˊ', '主': 'ㄓㄨˇ', '又': 'ㄧㄡˋ',
  '路': 'ㄌㄨˋ', '長': 'ㄔㄤˊ', '白': 'ㄅㄞˊ', '花': 'ㄏㄨㄚ', '紅': 'ㄏㄨㄥˊ',
  '走': 'ㄗㄡˇ', '在': 'ㄗㄞˋ', '向': 'ㄒㄧㄤˋ', '說': 'ㄕㄨㄛ', '朵': 'ㄉㄨㄛˇ',
  '從': 'ㄘㄨㄥˊ', '頭': 'ㄊㄡˊ', '那': 'ㄋㄚˋ',
  '前': 'ㄑㄧㄢˊ', '風': 'ㄈㄥ', '吹': 'ㄔㄨㄟ', '來': 'ㄌㄞˊ', '停': 'ㄊㄧㄥˊ',
  '跑': 'ㄆㄠˇ', '火': 'ㄏㄨㄛˇ', '車': 'ㄔㄜ', '洞': 'ㄉㄨㄥˋ', '出': 'ㄔㄨ',
  '堆': 'ㄉㄨㄟ', '請': 'ㄑㄧㄥˇ', '問': 'ㄨㄣˋ', '草': 'ㄘㄠˇ', '天': 'ㄊㄧㄢ',
  '星': 'ㄒㄧㄥ', '少': 'ㄕㄠˇ', '太': 'ㄊㄞˋ', '水': 'ㄕㄨㄟˇ', '去': 'ㄑㄩˋ',
  '彩': 'ㄘㄞˇ', '想': 'ㄒㄧㄤˇ', '爬': 'ㄆㄚˊ', '沒': 'ㄇㄟˊ', '棉': 'ㄇㄧㄢˊ',
  '泡': 'ㄆㄠˋ', '池': 'ㄔˊ', '空': 'ㄎㄨㄥ', '田': 'ㄊㄧㄢˊ', '回': 'ㄏㄨㄟˊ',
  '音': 'ㄧㄣ', '谷': 'ㄍㄨˇ', '叫': 'ㄐㄧㄠˋ', '嗎': '˙ㄇㄚ', '笑': 'ㄒㄧㄠˋ',
  '哈': 'ㄏㄚ', '魚': 'ㄩˊ', '加': 'ㄐㄧㄚ', '招': 'ㄓㄠ', '地': 'ㄉㄧˋ',
  '抱': 'ㄅㄠˋ', '爸': 'ㄅㄚˋ', '要': 'ㄧㄠˋ', '住': 'ㄓㄨˋ', '金': 'ㄐㄧㄣ',
  '句': 'ㄐㄩˋ', '話': 'ㄏㄨㄚˋ', '都': 'ㄉㄡ', '悄': 'ㄑㄧㄠˇ', '尾': 'ㄨㄟˇ',
  '巴': 'ㄅㄚ', '滿': 'ㄇㄢˇ', '春': 'ㄔㄨㄣ', '貼': 'ㄊㄧㄝ', '呢': '˙ㄋㄜ',
  '家': 'ㄐㄧㄚ', '把': 'ㄅㄚˇ', '房': 'ㄈㄤˊ', '福': 'ㄈㄨˊ', '日': 'ㄖˋ',
  '月': 'ㄩㄝˋ', '木': 'ㄇㄨˋ',
};
