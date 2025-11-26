// Helper funkcie pre aplikáciu

class Helpers {
  /// Získa iniciály z celého mena (meno + priezvisko)
  /// Príklad: "Tomáš Hudec" → "TH", "Peter" → "PE"
  static String getInitials(String name) {
    final parts = name.trim().split(' ');
    
    if (parts.length >= 2) {
      // Meno a priezvisko - prvé písmená
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    } else if (parts.isNotEmpty && parts[0].length >= 2) {
      // Len meno - prvé dve písmená
      return parts[0].substring(0, 2).toUpperCase();
    } else if (parts.isNotEmpty) {
      // Veľmi krátke meno - jedno písmeno
      return parts[0][0].toUpperCase();
    }
    
    return '?';
  }
}







