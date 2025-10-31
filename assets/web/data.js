// Products Data
const products = [
  {
    id: 1,
    name: "バニラカヌレ",
    category: "sweets",
    categoryLabel: "洋菓子",
    price: 450,
    image: "public/vanilla-canele-pastry.jpg",
    description:
      "外はカリッと、中はもっちりとした食感が特徴のフランス伝統菓子。北海道産の新鮮な卵とバニラビーンズを使用し、職人が一つ一つ丁寧に焼き上げています。",
    producer: "田中パティスリー",
    producerId: 1,
  },
  {
    id: 2,
    name: "桜餅",
    category: "sweets",
    categoryLabel: "和菓子",
    price: 380,
    image: "public/sakura-mochi-japanese-sweet.jpg",
    description:
      "春の訪れを感じさせる伝統的な和菓子。北海道産のもち米と小豆を使用し、塩漬けの桜葉で包んでいます。上品な甘さと桜の香りが特徴です。",
    producer: "山田和菓子店",
    producerId: 2,
  },
  {
    id: 3,
    name: "抹茶カヌレ",
    category: "sweets",
    categoryLabel: "洋菓子",
    price: 480,
    image: "public/matcha-green-tea-canele.jpg",
    description:
      "京都産の高級抹茶を贅沢に使用したカヌレ。ほろ苦い抹茶の風味と、カヌレ特有のもっちり食感が絶妙にマッチしています。",
    producer: "田中パティスリー",
    producerId: 1,
  },
  {
    id: 4,
    name: "どら焼き",
    category: "sweets",
    categoryLabel: "和菓子",
    price: 350,
    image: "public/dorayaki-japanese-pancake-sweet.jpg",
    description:
      "ふんわりとした生地に、北海道産小豆を使った自家製餡をたっぷりと挟んだどら焼き。昔ながらの製法で、一つ一つ手焼きしています。",
    producer: "山田和菓子店",
    producerId: 2,
  },
  {
    id: 5,
    name: "和牛ステーキ",
    category: "meat",
    categoryLabel: "肉",
    price: 3500,
    image: "public/wagyu-beef-marbled-steak.jpg",
    description:
      "きめ細かな霜降りが美しい、最高級の和牛ステーキ。柔らかく、口の中でとろけるような食感と、深い旨味が特徴です。",
    producer: "佐藤牧場",
    producerId: 3,
  },
  {
    id: 6,
    name: "平飼い卵（6個入り）",
    category: "meat",
    categoryLabel: "卵",
    price: 680,
    image: "public/free-range-eggs-in-carton.jpg",
    description:
      "広々とした環境で、ストレスなく育てられた鶏の卵。濃厚な黄身と、弾力のある白身が特徴。栄養価も高く、安心・安全な卵です。",
    producer: "佐藤牧場",
    producerId: 3,
  },
  {
    id: 7,
    name: "鶏もも肉",
    category: "meat",
    categoryLabel: "肉",
    price: 980,
    image: "public/fresh-chicken-thigh-meat.jpg",
    description:
      "ジューシーで柔らかい鶏もも肉。自然飼育で育てられた鶏は、臭みがなく、旨味が凝縮されています。唐揚げや照り焼きに最適です。",
    producer: "佐藤牧場",
    producerId: 3,
  },
  {
    id: 8,
    name: "有機トマト",
    category: "vegetables",
    categoryLabel: "野菜",
    price: 580,
    image: "public/organic-tomatoes-on-vine.jpg",
    description:
      "太陽の光をたっぷり浴びて育った、甘みと酸味のバランスが絶妙な有機トマト。農薬を使わず、自然の力で育てています。",
    producer: "鈴木農園",
    producerId: 4,
  },
  {
    id: 9,
    name: "無農薬ほうれん草",
    category: "vegetables",
    categoryLabel: "野菜",
    price: 380,
    image: "public/organic-spinach-bunch.jpg",
    description: "栄養価が高く、えぐみの少ない無農薬ほうれん草。柔らかい葉と茎は、サラダからお浸しまで幅広く使えます。",
    producer: "鈴木農園",
    producerId: 4,
  },
  {
    id: 10,
    name: "季節の野菜セット",
    category: "vegetables",
    categoryLabel: "野菜",
    price: 1800,
    image: "public/seasonal-vegetable-box-assortment.jpg",
    description:
      "旬の野菜を詰め合わせたお得なセット。その時期に最も美味しい野菜を、農家が厳選してお届けします。内容は季節により変わります。",
    producer: "鈴木農園",
    producerId: 4,
  },
]

// Producers Data
const producers = [
  {
    id: 1,
    name: "田中パティスリー",
    specialty: "洋菓子職人",
    location: "北海道札幌市",
    image: "public/japanese-patisserie-chef.jpg",
    description:
      "フランスで修行を積んだ田中シェフが営むパティスリー。伝統的なフランス菓子の技法を守りながら、北海道の素材を活かした独自のスイーツを作り続けています。",
    story:
      "20年前、フランスでの修行を終えた田中シェフは、故郷の北海道に戻り、小さなパティスリーを開きました。「地元の素材で、本物のフランス菓子を作りたい」という想いから、北海道産の卵、バター、小麦粉にこだわり、一つ一つ手作りでお菓子を作っています。特にカヌレは、外はカリッと、中はもっちりとした理想的な食感を追求し、何度も試作を重ねて完成させた自信作です。",
    products: [1, 3],
  },
  {
    id: 2,
    name: "山田和菓子店",
    specialty: "和菓子職人",
    location: "京都府京都市",
    image: "public/japanese-wagashi-artisan.jpg",
    description: "創業100年を超える老舗和菓子店。伝統の技を守りながら、現代の味覚にも合う和菓子作りを心がけています。",
    story:
      "明治時代から続く山田和菓子店は、四代目の山田さんが伝統を守りながら新しい挑戦を続けています。「和菓子は日本の文化そのもの。季節の移ろいや、人々の想いを形にするのが和菓子職人の役目」と語る山田さん。北海道産の小豆や、地元京都の抹茶など、厳選した素材を使い、一つ一つ丁寧に手作りしています。特に桜餅は、春の訪れを感じさせる逸品として、多くのお客様に愛されています。",
    products: [2, 4],
  },
  {
    id: 3,
    name: "佐藤牧場",
    specialty: "畜産農家",
    location: "岩手県盛岡市",
    image: "public/japanese-cattle-farmer.jpg",
    description:
      "動物福祉に配慮した飼育方法で、健康な牛と鶏を育てています。ストレスの少ない環境で育てられた動物たちは、肉質も卵の質も抜群です。",
    story:
      "佐藤牧場では、「動物たちが幸せに暮らせる環境を作ることが、美味しい肉や卵を作る第一歩」という信念のもと、広々とした牧場で牛と鶏を育てています。牛は放牧され、自由に草を食べ、鶏は平飼いでストレスなく過ごしています。「動物たちの健康が、食べる人の健康につながる」と語る佐藤さん。抗生物質や成長ホルモンを使わず、自然な飼育方法にこだわっています。",
    products: [5, 6, 7],
  },
  {
    id: 4,
    name: "鈴木農園",
    specialty: "有機野菜農家",
    location: "千葉県成田市",
    image: "public/japanese-organic-farmer.jpg",
    description:
      "農薬や化学肥料を一切使わない、完全有機栽培の野菜を作っています。土作りからこだわり、栄養価の高い野菜を育てています。",
    story:
      "「土が元気なら、野菜も元気に育つ」をモットーに、鈴木農園では土作りに最も力を入れています。化学肥料を使わず、堆肥や緑肥で土を豊かにし、農薬を使わずに野菜を育てています。「最初は虫との戦いでしたが、生態系のバランスが整うと、自然と虫の被害も減りました」と語る鈴木さん。旬の野菜を中心に、季節ごとに約30種類の野菜を栽培し、新鮮な状態でお客様にお届けしています。",
    products: [8, 9, 10],
  },
]
