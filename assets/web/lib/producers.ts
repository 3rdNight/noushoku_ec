export interface Producer {
  id: string
  name: string
  region: string
  category: "sweets" | "meat-eggs" | "vegetables"
  description: string
  story: string
  image: string
  philosophy: string
  products: string[]
}

export const producers: Producer[] = [
  {
    id: "patisserie-yamada",
    name: "パティスリー山田",
    region: "東京都",
    category: "sweets",
    description: "伝統と革新を融合させた洋菓子作りを追求しています。",
    story:
      "フランスで修行を積んだパティシエ山田が、2010年に東京で開業。日本の素材とフランスの技術を融合させた独自のスタイルを確立しました。特にカヌレは、外はカリッと中はもっちりとした食感にこだわり、毎日手作りで焼き上げています。",
    image: "/japanese-patisserie-chef.jpg",
    philosophy: "素材の味を最大限に引き出し、食べる人を幸せにするお菓子作り",
    products: ["canele-vanilla", "canele-matcha"],
  },
  {
    id: "wagashi-kagetsu",
    name: "和菓子処 花月",
    region: "京都府",
    category: "sweets",
    description: "京都の伝統を守り続ける老舗和菓子店。",
    story:
      "創業100年を超える老舗和菓子店。代々受け継がれてきた伝統の技と味を守りながら、現代の感性も取り入れた和菓子作りを行っています。厳選された国産素材のみを使用し、季節の移ろいを表現した美しい和菓子をお届けしています。",
    image: "/traditional-japanese-wagashi-shop.jpg",
    philosophy: "四季の美しさを和菓子で表現し、日本の心を伝える",
    products: ["wagashi-sakura", "dorayaki"],
  },
  {
    id: "tanaka-farm",
    name: "田中牧場",
    region: "鹿児島県",
    category: "meat-eggs",
    description: "黒毛和牛の飼育に情熱を注ぐ家族経営の牧場。",
    story:
      "鹿児島の豊かな自然の中で、三代にわたり黒毛和牛を育てています。牛一頭一頭に愛情を注ぎ、ストレスの少ない環境で健康的に育てることを心がけています。飼料にもこだわり、地元産の良質な穀物を使用。その結果、きめ細かなサシと深い旨味を持つA5ランクの和牛を生産しています。",
    image: "/japanese-cattle-farm-wagyu.jpg",
    philosophy: "牛との信頼関係を大切に、最高品質の和牛を育てる",
    products: ["wagyu-beef"],
  },
  {
    id: "yamamoto-poultry",
    name: "山本養鶏場",
    region: "岩手県",
    category: "meat-eggs",
    description: "平飼いで健康的に育てた鶏の卵を生産。",
    story:
      "岩手の山間部で、鶏たちが自由に動き回れる平飼い養鶏を実践しています。化学飼料を使わず、地元産の穀物と野菜くずを中心とした自然な飼料で育てることで、濃厚で栄養価の高い卵を生産。鶏たちのストレスを最小限に抑え、健康的な環境で育てることが美味しい卵作りの秘訣です。",
    image: "/free-range-chicken-farm-japan.jpg",
    philosophy: "鶏の幸せが、美味しい卵を生む",
    products: ["free-range-eggs"],
  },
  {
    id: "sato-poultry",
    name: "佐藤養鶏",
    region: "宮崎県",
    category: "meat-eggs",
    description: "地鶏の飼育にこだわる養鶏場。",
    story:
      "宮崎の温暖な気候を活かし、地鶏を放し飼いで育てています。広い敷地で自由に運動させることで、弾力のある肉質と深い味わいを実現。飼料は地元産の穀物を中心に、栄養バランスを考えた独自のブレンドを使用しています。",
    image: "/japanese-local-chicken-farm.jpg",
    philosophy: "自然に近い環境で、本来の美味しさを引き出す",
    products: ["chicken-thigh"],
  },
  {
    id: "suzuki-pig-farm",
    name: "鈴木養豚場",
    region: "千葉県",
    category: "meat-eggs",
    description: "自然飼育にこだわる養豚場。",
    story:
      "千葉の自然豊かな環境で、豚を健康的に育てています。抗生物質を使わず、ストレスの少ない環境で飼育することで、脂身と赤身のバランスが絶妙な豚肉を生産。地元の野菜くずも飼料に活用し、循環型農業を実践しています。",
    image: "/natural-pig-farm-japan.jpg",
    philosophy: "健康な豚から、安全で美味しい豚肉を",
    products: ["pork-belly"],
  },
  {
    id: "midori-farm",
    name: "緑の農園",
    region: "熊本県",
    category: "vegetables",
    description: "有機栽培で野菜を育てる農園。",
    story:
      "熊本の肥沃な大地で、農薬や化学肥料を使わない有機栽培を実践しています。土づくりから丁寧に行い、微生物の力を活かした健康な土壌で野菜を育てています。太陽の恵みをたっぷり浴びたトマトや人参は、甘みが強く栄養価も高いのが特徴です。",
    image: "/organic-vegetable-farm-japan.jpg",
    philosophy: "土を育て、野菜を育て、人を育てる",
    products: ["tomatoes", "carrots"],
  },
  {
    id: "daichi-farm",
    name: "大地の恵み農場",
    region: "長野県",
    category: "vegetables",
    description: "標高の高い環境で育てる高原野菜。",
    story:
      "長野の標高1000mを超える高原で、昼夜の寒暖差を活かした野菜作りを行っています。冷涼な気候が野菜の甘みを引き出し、病害虫も少ないため農薬の使用を最小限に抑えられます。ほうれん草や大根など、みずみずしく栄養価の高い野菜をお届けしています。",
    image: "/highland-vegetable-farm-japan.jpg",
    philosophy: "高原の恵みを、そのまま食卓へ",
    products: ["leafy-greens", "daikon"],
  },
]

export const producerCategories = [
  { id: "all", name: "すべて", value: "all" },
  { id: "sweets", name: "和菓子・洋菓子", value: "sweets" },
  { id: "meat-eggs", name: "肉・卵", value: "meat-eggs" },
  { id: "vegetables", name: "野菜", value: "vegetables" },
] as const
