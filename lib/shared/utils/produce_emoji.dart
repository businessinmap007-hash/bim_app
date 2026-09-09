/// A best-effort emoji for a produce name — a lightweight, offline stand-in
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
  final name = (nameEn ?? '').toLowerCase();
  if (name.isEmpty) return '🧺';

  const byMostSpecificFirst = <String, String>{
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
