export interface Product {
  id: string
  name: string
  category: "sweets" | "meat-eggs" | "vegetables"
  price: number
  description: string
  image: string
  producer: string
  region: string
  inStock: boolean
}

export const products: Product[] = [
  // Sweets & Canelé
  {
    id: "canele-vanilla",
    name: "バニラカヌレ",
    category: "sweets",
    price: 380,
    description: "フランス伝統のカヌレを日本の素材で。外はカリッと、中はもっちり。",
    image: "/vanilla-canele-pastry.jpg",
    producer: "パティスリー山田",
    region: "東京都",
    inStock: true,
  },
  {
    id: "wagashi-sakura",
    name: "桜餅",
    category: "sweets",
    price: 450,
    description: "春の訪れを感じる伝統的な和菓子。厳選された道明寺粉を使用。",
    image: "/sakura-mochi-japanese-sweet.jpg",
    producer: "和菓子処 花月",
    region: "京都府",
    inStock: true,
  },
  {
    id: "canele-matcha",
    name: "抹茶カヌレ",
    category: "sweets",
    price: 420,
    description: "宇治抹茶を贅沢に使用した和洋折衷の逸品。",
    image: "/matcha-green-tea-canele.jpg",
    producer: "パティスリー山田",
    region: "東京都",
    inStock: true,
  },
  {
    id: "dorayaki",
    name: "どら焼き",
    category: "sweets",
    price: 350,
    description: "北海道産小豆を使用した自家製餡が自慢のどら焼き。",
    image: "/dorayaki-japanese-pancake-sweet.jpg",
    producer: "和菓子処 花月",
    region: "京都府",
    inStock: true,
  },

  // Meat & Eggs
  {
    id: "wagyu-beef",
    name: "黒毛和牛 サーロイン",
    category: "meat-eggs",
    price: 5800,
    description: "A5ランクの黒毛和牛。きめ細かなサシと深い旨味が特徴。",
    image: "/wagyu-beef-marbled-steak.jpg",
    producer: "田中牧場",
    region: "鹿児島県",
    inStock: true,
  },
  {
    id: "free-range-eggs",
    name: "平飼い有精卵",
    category: "meat-eggs",
    price: 680,
    description: "自然豊かな環境で育った鶏の卵。濃厚な黄身が特徴。6個入り。",
    image: "/fresh-farm-eggs.png",
    producer: "山本養鶏場",
    region: "岩手県",
    inStock: true,
  },
  {
    id: "chicken-thigh",
    name: "地鶏もも肉",
    category: "meat-eggs",
    price: 1200,
    description: "放し飼いで育てた地鶏。弾力のある肉質と深い味わい。",
    image: "/fresh-chicken-thigh-meat.jpg",
    producer: "佐藤養鶏",
    region: "宮崎県",
    inStock: true,
  },
  {
    id: "pork-belly",
    name: "豚バラ肉",
    category: "meat-eggs",
    price: 980,
    description: "自然飼育の豚肉。脂身と赤身のバランスが絶妙。",
    image: "/pork-belly-sliced-meat.jpg",
    producer: "鈴木養豚場",
    region: "千葉県",
    inStock: true,
  },

  // Vegetables
  {
    id: "tomatoes",
    name: "完熟トマト",
    category: "vegetables",
    price: 580,
    description: "太陽の恵みをたっぷり浴びた完熟トマト。甘みと酸味のバランスが絶妙。",
    image: "/ripe-red-tomatoes.jpg",
    producer: "緑の農園",
    region: "熊本県",
    inStock: true,
  },
  {
    id: "leafy-greens",
    name: "無農薬ほうれん草",
    category: "vegetables",
    price: 380,
    description: "農薬不使用で育てた新鮮なほうれん草。栄養たっぷり。",
    image: "/fresh-spinach.png",
    producer: "大地の恵み農場",
    region: "長野県",
    inStock: true,
  },
  {
    id: "carrots",
    name: "有機人参",
    category: "vegetables",
    price: 450,
    description: "有機栽培の人参。甘みが強く、生でも美味しい。",
    image: "/organic-carrots.png",
    producer: "緑の農園",
    region: "熊本県",
    inStock: true,
  },
  {
    id: "daikon",
    name: "大根",
    category: "vegetables",
    price: 320,
    description: "みずみずしい大根。煮物やサラダに最適。",
    image: "/japanese-daikon-radish.jpg",
    producer: "大地の恵み農場",
    region: "長野県",
    inStock: true,
  },
]

export const categories = [
  { id: "all", name: "すべて", value: "all" },
  { id: "sweets", name: "和菓子・洋菓子", value: "sweets" },
  { id: "meat-eggs", name: "肉・卵", value: "meat-eggs" },
  { id: "vegetables", name: "野菜", value: "vegetables" },
] as const
