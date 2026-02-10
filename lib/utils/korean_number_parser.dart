/// [Project] Buddy - AI 가계부 서비스
/// [File] KoreanNumberParser - 한글 금액 파싱
/// [Description]
/// "만원" → 10000, "이만오천" → 25000, "3만5천" → 35000 등
/// 한글/혼합 금액 표현을 정수로 변환

class KoreanNumberParser {
  // 한글 숫자 → 값
  static const Map<String, int> _digits = {
    '일': 1, '이': 2, '삼': 3, '사': 4, '오': 5,
    '육': 6, '칠': 7, '팔': 8, '구': 9,
    '한': 1, '두': 2, '세': 3, '네': 4, '다섯': 5,
    '여섯': 6, '일곱': 7, '여덟': 8, '아홉': 9,
  };

  // 한글 단위 → 배수
  static const Map<String, int> _units = {
    '십': 10,
    '백': 100,
    '천': 1000,
    '만': 10000,
  };

  /// 텍스트에서 한글/혼합 금액을 파싱하여 정수 반환.
  /// 파싱 실패 시 null.
  static int? parse(String text) {
    // "원" 제거, 공백 제거
    String cleaned = text.replaceAll('원', '').replaceAll(' ', '');

    // 금액 부분만 추출 (한글 숫자 + 아라비아 숫자 + 단위가 포함된 부분)
    // "스벅만원" → "만" 부분 추출, "스벅3만5천" → "3만5천" 추출
    final amountPattern = RegExp(
      r'(\d+[만천백십][\d만천백십]*|[일이삼사오육칠팔구한두세네다섯여섯일곱여덟아홉십백천만]+[\d만천백십]*|\d+[만천백십])',
    );
    final match = amountPattern.firstMatch(cleaned);
    if (match == null) return null;

    final amountStr = match.group(0)!;
    return _parseAmount(amountStr);
  }

  static int? _parseAmount(String s) {
    if (s.isEmpty) return null;

    int total = 0;
    int current = 0;
    int i = 0;

    while (i < s.length) {
      // 아라비아 숫자 시퀀스 읽기
      final digitMatch = RegExp(r'\d+').matchAsPrefix(s, i);
      if (digitMatch != null) {
        current = int.parse(digitMatch.group(0)!);
        i = digitMatch.end;
        continue;
      }

      // 여러 글자 한글 숫자 먼저 확인 (다섯, 여섯, 일곱, 여덟, 아홉)
      String? matchedDigit;
      for (final key in _digits.keys) {
        if (key.length > 1 && s.startsWith(key, i)) {
          if (matchedDigit == null || key.length > matchedDigit.length) {
            matchedDigit = key;
          }
        }
      }
      if (matchedDigit != null) {
        current = _digits[matchedDigit]!;
        i += matchedDigit.length;
        continue;
      }

      // 한 글자 한글 숫자/단위 확인
      final char = s[i];

      if (_digits.containsKey(char)) {
        current = _digits[char]!;
        i++;
        continue;
      }

      if (_units.containsKey(char)) {
        final unitValue = _units[char]!;
        if (current == 0) {
          // "만원" → current=0 이면 1로 취급
          current = 1;
        }
        total += current * unitValue;
        current = 0;
        i++;
        continue;
      }

      // 인식 불가 문자 → 스킵
      i++;
    }

    total += current; // 남은 숫자 더하기

    return total > 0 ? total : null;
  }
}
