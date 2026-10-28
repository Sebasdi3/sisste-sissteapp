/// Formatos de fecha y textos de estado, sin depender de `intl`.
String two(int n) => n.toString().padLeft(2, '0');

/// 26/10/2026 23:55
String fechaHora(DateTime? d) {
  if (d == null) return '—';
  return '${two(d.day)}/${two(d.month)}/${d.year} ${two(d.hour)}:${two(d.minute)}';
}

/// 26/10/2026
String soloFecha(DateTime? d) {
  if (d == null) return '—';
  return '${two(d.day)}/${two(d.month)}/${d.year}';
}

String estadoLegible(String estado) {
  switch (estado) {
    case 'en_espera':
      return 'En espera';
    case 'en_proceso':
      return 'En proceso';
    case 'atendida':
      return 'Atendida';
    default:
      return estado;
  }
}

/// Quita acentos y pasa a minúsculas para que la búsqueda no distinga
/// "Cámara" de "camara".
String normalizar(String s) {
  const from = 'áàäâéèëêíìïîóòöôúùüûñÁÀÄÂÉÈËÊÍÌÏÎÓÒÖÔÚÙÜÛÑ';
  const to = 'aaaaeeeeiiiioooouuuunAAAAEEEEIIIIOOOOUUUUN';
  final b = StringBuffer();
  for (final ch in s.runes) {
    final c = String.fromCharCode(ch);
    final i = from.indexOf(c);
    b.write(i >= 0 ? to[i] : c);
  }
  return b.toString().toLowerCase();
}
