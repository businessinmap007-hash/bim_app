/// A best-effort emoji for a produce (or device) name — a lightweight, offline stand-in
/// for a real photo per item (downloading and licensing photos for ~120
/// generic vegetables/fruits isn't something to do sight-unseen). Matched by
/// substring on the English name so e.g. "Baladi Orange"/"Navel Orange"/
/// "Blood Orange" all land on 🍊. Falls back to a neutral basket for the long
/// tail (okra, molokhia, taro...) that has no fitting emoji.
///
/// Shared between the merchant's item list/grid/type-selection screens and
/// the customer-facing menu card — a photo-less item should look the same
/// (a 🥔, not a generic fork-and-knife icon) wherever it's shown.
String produceEmoji(String? nameEn) {
  // Arabic spelled loosely («انتريه»/«أنتريه»، «ركنه»/«ركنة») still has to land.
  final name = (nameEn ?? '')
      .toLowerCase()
      .replaceAll(RegExp('[أإآ]'), 'ا')
      .replaceAll('ة', 'ه')
      .replaceAll('ى', 'ي');
  if (name.isEmpty) return '🧺';

  const byMostSpecificFirst = <String, String>{
    // Furniture (the «أثاث وتشطيب منزلي» branches) — first, because «Sitting
    // Corner» would otherwise be read as corn. Both the English and the Arabic
    // name of each, since a hand-typed item carries only the Arabic one.
    'bed room': '🛏️',
    'bedroom': '🛏️',
    'غرفه نوم': '🛏️',
    'سرير': '🛏️',
    'مرتبه': '🛏️',
    'children room': '🧸',
    'غرفه اطفال': '🧸',
    'dinning': '🍽️',
    'dining': '🍽️',
    'سفره': '🍽️',
    'sitting corner': '🛋️',
    'ركنه': '🛋️',
    'armchair': '🛋️',
    'فوتيه': '🛋️',
    'salon': '🛋️',
    'صالون': '🛋️',
    'sofa': '🛋️',
    'كنبه': '🛋️',
    'انتريه': '🛋️',
    'chair': '🪑',
    'كرسي': '🪑',
    'office furniture': '🖥️',
    'اثاث مكتبي': '🖥️',
    'مكتب': '🖥️',
    'hotel furniture': '🏨',
    'اثاث فندقي': '🏨',
    'kitchen': '🍳',
    'مطبخ': '🍳',
    'carpet': '🧶',
    'سجاد': '🧶',
    'tableau': '🖼️',
    'تابلوه': '🖼️',
    'drawer': '🗄️',
    'دولاب': '🗄️',
    'furniture': '🪑',
    'اثاث': '🪑',
    // Devices and their accessories (the «أجهزة الموبايل» / «اكسسوارات»
    // branches) — a phone with no photo showed a produce basket.
    'in-car': '🚗',
    'smart watch': '⌚',
    'headphone': '🎧',
    'charger': '🔌',
    'power bank': '🔋',
    'memory card': '💾',
    'screen protector': '📱',
    'cases & covers': '📱',
    'tablet': '📱',
    'mobile': '📱',
    'sweet potato': '🍠',
    'watermelon': '🍉',
    'cantaloupe': '🍈',
    'melon': '🍈',
    'papaya': '🍈',
    'mango': '🥭',
    'strawberry': '🍓',
    'grapes': '🍇',
    'vine leaves': '🍇',
    'orange': '🍊',
    'mandarin': '🍊',
    'grapefruit': '🍊',
    'lemon': '🍋',
    'lime': '🍋',
    'banana': '🍌',
    'apple': '🍎',
    'pear': '🍐',
    'peach': '🍑',
    'apricot': '🍑',
    'nectarine': '🍑',
    'plum': '🍑',
    'cherry tomato': '🍅',
    'cherries': '🍒',
    'pineapple': '🍍',
    'avocado': '🥑',
    'kiwi': '🥝',
    'coconut': '🥥',
    'mulberry': '🫐',
    'date': '🌴',
    'tomato': '🍅',
    'potato': '🥔',
    'onion': '🧅',
    'garlic': '🧄',
    'cucumber': '🥒',
    'courgette': '🥒',
    'zucchini': '🥒',
    'chilli': '🌶️',
    'pepper': '🫑',
    'aubergine': '🍆',
    'eggplant': '🍆',
    'carrot': '🥕',
    'bean': '🫘',
    'pea': '🫛',
    'spinach': '🥬',
    'lettuce': '🥬',
    'cabbage': '🥬',
    'chard': '🥬',
    'broccoli': '🥦',
    'cauliflower': '🥦',
    'pumpkin': '🎃',
    'corn': '🌽',
    'mushroom': '🍄',
    'ginger': '🫚',
    'herb': '🌿',
    'parsley': '🌿',
    'coriander': '🌿',
    'dill': '🌿',
    'mint': '🌿',
    'basil': '🌿',
    'rocket': '🌿',
    'celery': '🌿',
    'leek': '🌿',
    'radish': '🌿',
  };

  for (final entry in byMostSpecificFirst.entries) {
    if (name.contains(entry.key)) return entry.value;
  }

  return '🧺';
}
