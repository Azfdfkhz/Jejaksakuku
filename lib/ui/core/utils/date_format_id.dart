import 'package:intl/intl.dart';

/// Util pemformatan tanggal berbahasa Indonesia yang dipakai di seluruh app.
///
/// Sebelumnya banyak halaman menampilkan tanggal contoh yang di-hardcode
/// (mis. "Kamis, 25 September 2026") sehingga tidak pernah cocok dengan
/// tanggal sebenarnya. Semua pemanggil sekarang WAJIB melewatkan
/// [DateTime] nyata (baik `DateTime.now()` maupun `vm.selectedDate`) supaya
/// tanggal yang tampil selalu sesuai.
class DateFormatId {
  DateFormatId._();

  /// "Kamis, 25 September 2026"
  static String full(DateTime date) => DateFormat('EEEE, d MMMM y', 'id_ID').format(date);

  /// "25 Sep 2026"
  static String shortDate(DateTime date) => DateFormat('d MMM y', 'id_ID').format(date);

  /// "September 2026"
  static String monthYear(DateTime date) => DateFormat('MMMM y', 'id_ID').format(date);

  /// "25 September 2026"
  static String longNoDay(DateTime date) => DateFormat('d MMMM y', 'id_ID').format(date);

  /// "25 Sep 2026 · 22:15"
  static String withTime(DateTime date) => '${DateFormat('d MMM y', 'id_ID').format(date)} · ${DateFormat('HH:mm').format(date)}';
}
