class MenuItem {
  final String id;
  final String labelKey;
  final String imagePath;
  final double price;
  final String descriptionKey;
  final String subcategory;

  MenuItem({
    required this.id,
    required this.labelKey,
    required this.imagePath,
    required this.price,
    required this.descriptionKey,
    required this.subcategory,
  });
}

final List<MenuItem> foodsMenu = [
  // カヌレ
  MenuItem(
    id: 'canele_1',
    labelKey: 'クラシックカヌレ',
    imagePath: 'assets/images/canele1.jpg',
    price: 480,
    descriptionKey: '外はカリッと中はしっとり、伝統的なフランス菓子。',
    subcategory: 'カヌレ',
  ),
  MenuItem(
    id: 'canele_2',
    labelKey: 'ショコラカヌレ',
    imagePath: 'assets/images/canele2.jpg',
    price: 520,
    descriptionKey: '濃厚なチョコレート風味のカヌレ。',
    subcategory: 'カヌレ',
  ),
  MenuItem(
    id: 'canele_3',
    labelKey: '抹茶カヌレ',
    imagePath: 'assets/images/canele3.jpg',
    price: 520,
    descriptionKey: '宇治抹茶の香りが広がる上品な味わい。',
    subcategory: 'カヌレ',
  ),

  // ワイン
  MenuItem(
    id: 'wine_1',
    labelKey: '赤ワイン',
    imagePath: 'assets/images/wine1.jpg',
    price: 1200,
    descriptionKey: 'フルーティで飲みやすい赤ワイン。',
    subcategory: 'ワイン',
  ),
  MenuItem(
    id: 'wine_2',
    labelKey: '白ワイン',
    imagePath: 'assets/images/wine2.jpg',
    price: 1200,
    descriptionKey: '爽やかで軽やかな白ワイン。',
    subcategory: 'ワイン',
  ),

  // 日本酒
  MenuItem(
    id: 'sake_1',
    labelKey: '吟醸酒',
    imagePath: 'assets/images/sake1.jpg',
    price: 1500,
    descriptionKey: '香り高くまろやかな味わいの吟醸酒。',
    subcategory: '日本酒',
  ),
  MenuItem(
    id: 'sake_2',
    labelKey: '純米酒',
    imagePath: 'assets/images/sake2.jpg',
    price: 1300,
    descriptionKey: '米の旨味をしっかり感じる純米酒。',
    subcategory: '日本酒',
  ),

  // 茶葉
  MenuItem(
    id: 'tea_leaf_1',
    labelKey: '煎茶',
    imagePath: 'assets/images/tea1.jpg',
    price: 600,
    descriptionKey: '香り高くすっきりとした味わいの煎茶。',
    subcategory: '茶葉',
  ),
  MenuItem(
    id: 'tea_leaf_2',
    labelKey: 'ほうじ茶',
    imagePath: 'assets/images/tea2.jpg',
    price: 580,
    descriptionKey: '香ばしく落ち着く味わいのほうじ茶。',
    subcategory: '茶葉',
  ),

  // 調味料
  MenuItem(
    id: 'seasoning_1',
    labelKey: '醤油',
    imagePath: 'assets/images/seasoning1.jpg',
    price: 400,
    descriptionKey: '伝統的な製法で作られた香り豊かな醤油。',
    subcategory: '調味料',
  ),
  MenuItem(
    id: 'seasoning_2',
    labelKey: '味噌',
    imagePath: 'assets/images/seasoning2.jpg',
    price: 500,
    descriptionKey: 'まろやかでコクのある手作り味噌。',
    subcategory: '調味料',
  ),

  // 食材
  MenuItem(
    id: 'ingredient_1',
    labelKey: '有機小麦粉',
    imagePath: 'assets/images/ingredient1.jpg',
    price: 350,
    descriptionKey: 'お菓子やパン作りに最適なオーガニック小麦粉。',
    subcategory: '食材',
  ),
  MenuItem(
    id: 'ingredient_2',
    labelKey: '米粉',
    imagePath: 'assets/images/ingredient2.jpg',
    price: 400,
    descriptionKey: 'グルテンフリーで軽い仕上がりの米粉。',
    subcategory: '食材',
  ),
];
