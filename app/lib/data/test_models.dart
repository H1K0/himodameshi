enum CableType { jackTs, jackTrs, xlr }

extension CableTypeExtension on CableType {
  String get displayName {
    switch (this) {
      case CableType.jackTs:
        return 'Jack TS';
      case CableType.jackTrs:
        return 'Jack TRS';
      case CableType.xlr:
        return 'XLR';
    }
  }

  String get iconPath {
    // Пока возвращаем строку, позже заменим на иконки
    switch (this) {
      case CableType.jackTs:
        return 'ts';
      case CableType.jackTrs:
        return 'trs';
      case CableType.xlr:
        return 'xlr';
    }
  }

  bool get supportsCmrr {
    switch (this) {
      case CableType.jackTs:
        return false;
      case CableType.jackTrs:
        return true;
      case CableType.xlr:
        return true;
    }
  }
}

enum TestType { continuity, cmrr, freqResponse }

extension TestTypeExtension on TestType {
  String get displayName {
    switch (this) {
      case TestType.continuity:
        return 'Целостность';
      case TestType.cmrr:
        return 'CMRR';
      case TestType.freqResponse:
        return 'АЧХ';
    }
  }

  int get durationSeconds {
    switch (this) {
      case TestType.continuity:
        return 3;
      case TestType.cmrr:
        return 3;
      case TestType.freqResponse:
        return 3;
    }
  }
}
