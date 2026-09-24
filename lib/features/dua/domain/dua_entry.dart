import 'custom_dua.dart';
import 'dua.dart';

sealed class DuaEntry {
  const DuaEntry();

  String get id;
}

final class VerifiedDuaEntry extends DuaEntry {
  const VerifiedDuaEntry(this.dua);

  final Dua dua;

  @override
  String get id => dua.id;
}

final class CustomDuaEntry extends DuaEntry {
  const CustomDuaEntry(this.dua);

  final CustomDua dua;

  @override
  String get id => dua.id;
}
