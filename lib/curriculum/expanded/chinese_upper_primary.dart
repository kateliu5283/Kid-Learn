import '../../models/lesson.dart';
import 'lesson_108_helpers.dart';

/// 國語 5～6 年級：每學期 6 單元（閱讀、寫作、古詩、媒體素養等），對齊 108 課綱國語文學習內容。
List<Lesson> buildChineseUpperPrimaryLessons() {
  final rows = <({int g, List<String> s1, List<String> s2})>[
    (
      g: 5,
      s1: [
        '寓言與寓意',
        '記敘文要點',
        '說明文閱讀',
        '字詞辨析與成語',
        '古詩選讀（一）',
        '媒體識讀入門',
      ],
      s2: [
        '抒情文與感受',
        '段落大意與主旨',
        '應用文：通知與啟事',
        '標點與句子',
        '閱讀策略：預測與提問',
        '綜合練習',
      ],
    ),
    (
      g: 6,
      s1: [
        '小說與人物',
        '議論文初探',
        '說明方法：舉例、比較',
        '文言短文入門',
        '詩歌的意象',
        '專題閱讀',
      ],
      s2: [
        '寫作：立意與取材',
        '寫作：組織與修辭',
        '口語表達與報告',
        '跨文本閱讀',
        '字音字形統整',
        '銜接國中語文',
      ],
    ),
  ];

  final out = <Lesson>[];
  for (final r in rows) {
    for (var i = 0; i < r.s1.length; i++) {
      final title = r.s1[i];
      out.add(
        lesson108Core(
          id: 'ex-cn-${r.g}-1-${i + 1}',
          subjectId: 'chinese',
          grade: r.g,
          semester: Semester.first,
          unit: i + 1,
          title: title,
          summary: '國小 ${r.g} 年級上學期：$title。',
          content: _semContentIntro(r.g, Semester.first, title) +
              '\n\n閱讀時可標示關鍵句，寫作時先列大綱再擴寫。',
        ),
      );
    }
    for (var i = 0; i < r.s2.length; i++) {
      final title = r.s2[i];
      out.add(
        lesson108Core(
          id: 'ex-cn-${r.g}-2-${i + 1}',
          subjectId: 'chinese',
          grade: r.g,
          semester: Semester.second,
          unit: i + 1,
          title: title,
          summary: '國小 ${r.g} 年級下學期：$title。',
          content: _semContentIntro(r.g, Semester.second, title) +
              '\n\n多朗讀、多思考作者寫作目的，有助於理解文本。',
        ),
      );
    }
  }
  return out;
}

String _semContentIntro(int grade, Semester sem, String focus) {
  final s = sem == Semester.first ? '上學期' : '下學期';
  return '國小 $grade 年級國語 $s：$focus\n\n'
      '本單元呼應《十二年國民基本教育課程綱要》國語文領域之閱讀、寫作、口語溝通等面向；'
      '實際篇目與活動可依各校選用教材調整。';
}
