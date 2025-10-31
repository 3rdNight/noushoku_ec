import { Button } from "@/components/ui/button"
import { Search, ChevronRight } from "lucide-react"
import Link from "next/link"

export default function JapaneseAgriculturePage() {
  return (
    <main className="min-h-screen bg-[#E8E3D8]">
      {/* Hero Section */}
      <section className="relative h-[500px] md:h-[600px] overflow-hidden">
        <div className="absolute inset-0">
          <img src="/golden-rice-field-in-sunlight.jpg" alt="Rice field" className="w-full h-full object-cover" />
          <div className="absolute inset-0 bg-gradient-to-b from-transparent to-[#E8E3D8]/30" />
        </div>

        <div className="relative h-full max-w-7xl mx-auto px-6 flex items-center justify-between">
          <div className="text-foreground/80 font-serif text-sm md:text-base">日本の農業を守る</div>

          <div className="flex flex-col items-center gap-2 text-foreground font-serif">
            <span className="text-2xl md:text-4xl tracking-widest" style={{ writingMode: "vertical-rl" }}>
              伝統と食文化
            </span>
          </div>
        </div>
      </section>

      {/* Section 01: Our Mission */}
      <section className="py-16 md:py-24 px-6">
        <div className="max-w-6xl mx-auto">
          <h2 className="text-5xl md:text-6xl font-serif mb-12 text-foreground">
            <span className="text-6xl md:text-7xl">01</span>
            <span className="text-2xl md:text-3xl ml-2">私たちの想い</span>
          </h2>

          <div className="grid md:grid-cols-2 gap-12 items-center">
            <div className="relative aspect-square max-w-md mx-auto">
              <img
                src="/white-rice-in-black-ceramic-bowl-on-dark-backgroun.jpg"
                alt="Japanese rice"
                className="w-full h-full object-cover rounded-3xl"
              />
            </div>

            <div className="space-y-6 text-foreground/80 leading-relaxed">
              <p className="text-lg">
                日本の農業を継承し、
                <br />
                伝統を守るための食事をお届けします。
              </p>

              <p>
                日本各地の生産者が丹精込めて育てた食材を、
                <br />
                皆様の食卓へお届けすることで、
                <br />
                日本の農業と食文化を次世代へ繋ぎます。
              </p>

              <p>
                安心・安全な食材を通じて、
                <br />
                生産者と消費者を結び、
                <br />
                持続可能な農業の未来を創造します。
              </p>

              <div className="flex justify-center py-4">
                <div className="flex gap-1">
                  <span className="w-2 h-2 rounded-full bg-foreground/60"></span>
                  <span className="w-2 h-2 rounded-full bg-foreground/60"></span>
                  <span className="w-2 h-2 rounded-full bg-foreground/60"></span>
                </div>
              </div>

              <div className="pt-4">
                <p className="font-medium text-foreground mb-2">私たちの使命</p>
                <p className="text-foreground/70">それは、</p>
                <p className="text-foreground/80">日本の伝統的な食文化と農業を守り、未来へ繋ぐことです。</p>
              </div>
            </div>
          </div>
        </div>
      </section>

      {/* Section 02: Our Products */}
      <section className="py-16 md:py-24 px-6 bg-[#E8E3D8]">
        <div className="max-w-6xl mx-auto">
          <h2 className="text-5xl md:text-6xl font-serif mb-16 text-foreground text-right">
            <span className="text-6xl md:text-7xl">02</span>
            <span className="text-2xl md:text-3xl ml-2">取り扱い商品</span>
          </h2>

          <div className="grid md:grid-cols-3 gap-8">
            {/* Product Category 1: Japanese Sweets */}
            <div className="flex flex-col items-center text-center">
              <div className="relative w-48 h-48 mb-6">
                <div className="absolute -top-2 -right-2 bg-primary text-primary-foreground px-3 py-1 rounded-full text-xs font-medium rotate-12">
                  和菓子・洋菓子
                </div>
                <img
                  src="/japanese-traditional-sweets-wagashi-and-canele-pas.jpg"
                  alt="Japanese sweets and canelé"
                  className="w-full h-full object-cover rounded-full"
                />
              </div>
              <p className="text-sm leading-relaxed text-foreground/80">
                伝統的な和菓子から、人気のカヌレまで。厳選された素材を使用し、職人が丁寧に作り上げた逸品をお届けします。季節の味わいをお楽しみください。
              </p>
            </div>

            {/* Product Category 2: Meat & Eggs */}
            <div className="flex flex-col items-center text-center">
              <div className="relative w-48 h-48 mb-6">
                <div className="absolute -top-2 -right-2 bg-primary text-primary-foreground px-3 py-1 rounded-full text-xs font-medium rotate-12">
                  肉・卵
                </div>
                <img
                  src="/fresh-japanese-wagyu-beef-and-farm-eggs.jpg"
                  alt="Meat and eggs"
                  className="w-full h-full object-cover rounded-full"
                />
              </div>
              <p className="text-sm leading-relaxed text-foreground/80">
                日本各地の契約農家から直送される新鮮な肉と卵。自然豊かな環境で育てられた、安心・安全な畜産物をご提供します。
              </p>
            </div>

            {/* Product Category 3: Vegetables */}
            <div className="flex flex-col items-center text-center">
              <div className="relative w-48 h-48 mb-6">
                <div className="absolute -top-2 -right-2 bg-primary text-primary-foreground px-3 py-1 rounded-full text-xs font-medium rotate-12">
                  新鮮野菜
                </div>
                <img
                  src="/hands-holding-golden-rice-stalks-in-field.jpg"
                  alt="Fresh vegetables"
                  className="w-full h-full object-cover rounded-full"
                />
              </div>
              <p className="text-sm leading-relaxed text-foreground/80">
                旬の野菜を産地直送でお届け。農薬を極力使わず、土づくりからこだわった生産者の野菜は、本来の味わいと栄養がぎっしり詰まっています。
              </p>
            </div>
          </div>

          <div className="mt-12 text-center">
            <Link href="/products">
              <Button size="lg" className="rounded-full px-8">
                商品一覧を見る
              </Button>
            </Link>
          </div>
        </div>
      </section>

      {/* Section 03: Shopping Process */}
      <section className="py-16 md:py-24 px-6">
        <div className="max-w-6xl mx-auto">
          <h2 className="text-5xl md:text-6xl font-serif mb-16 text-foreground">
            <span className="text-6xl md:text-7xl">03</span>
            <span className="text-2xl md:text-3xl ml-2">ご購入の流れ</span>
          </h2>

          <div className="flex flex-wrap justify-center items-center gap-6 md:gap-8">
            <div className="flex flex-col items-center">
              <div className="w-24 h-24 md:w-32 md:h-32 rounded-full bg-primary text-primary-foreground flex items-center justify-center text-xl md:text-2xl font-bold">
                Step1
              </div>
              <p className="mt-4 text-sm text-foreground/70">商品を探す</p>
            </div>

            <ChevronRight className="text-primary w-6 h-6 hidden md:block" />

            <div className="flex flex-col items-center">
              <div className="w-24 h-24 md:w-32 md:h-32 rounded-full bg-primary text-primary-foreground flex items-center justify-center text-xl md:text-2xl font-bold">
                Step2
              </div>
              <p className="mt-4 text-sm text-foreground/70">カートに追加・注文</p>
            </div>

            <ChevronRight className="text-primary w-6 h-6 hidden md:block" />

            <div className="flex flex-col items-center">
              <div className="w-24 h-24 md:w-32 md:h-32 rounded-full bg-primary text-primary-foreground flex items-center justify-center text-xl md:text-2xl font-bold">
                Step3
              </div>
              <p className="mt-4 text-sm text-foreground/70">お支払い手続き</p>
            </div>

            <ChevronRight className="text-primary w-6 h-6 hidden md:block" />

            <div className="flex flex-col items-center">
              <div className="w-24 h-24 md:w-32 md:h-32 rounded-full bg-primary text-primary-foreground flex items-center justify-center text-xl md:text-2xl font-bold">
                Step4
              </div>
              <p className="mt-4 text-sm text-foreground/70">ご自宅へお届け</p>
            </div>
          </div>
        </div>
      </section>

      {/* Producer Introduction Section */}
      <section className="py-16 md:py-24 px-6 bg-primary/5">
        <div className="max-w-6xl mx-auto">
          <h2 className="text-5xl md:text-6xl font-serif mb-8 text-foreground text-center">
            <span className="text-6xl md:text-7xl">04</span>
            <span className="text-2xl md:text-3xl ml-2">生産者の想い</span>
          </h2>
          <p className="text-center text-foreground/70 mb-12 leading-relaxed">
            日本各地で丹精込めて食材を育てる生産者の方々をご紹介します。
          </p>
          <div className="text-center">
            <Link href="/producers">
              <Button size="lg" className="rounded-full px-8">
                生産者を見る
              </Button>
            </Link>
          </div>
        </div>
      </section>

      {/* Topics Section */}
      <section className="py-16 md:py-24 px-6 border-t border-foreground/10">
        <div className="max-w-6xl mx-auto">
          <div className="flex items-center justify-center mb-12">
            <div className="h-px bg-foreground/20 flex-1 max-w-xs"></div>
            <h2 className="text-3xl md:text-4xl font-serif mx-8 text-foreground">Topics</h2>
            <div className="h-px bg-foreground/20 flex-1 max-w-xs"></div>
          </div>

          <div className="grid md:grid-cols-2 gap-8 max-w-4xl mx-auto">
            <div className="relative aspect-[4/3] rounded-2xl overflow-hidden group cursor-pointer">
              <img
                src="/assorted-japanese-traditional-sweets-and-canele-on.jpg"
                alt="Japanese sweets collection"
                className="w-full h-full object-cover group-hover:scale-105 transition-transform duration-300"
              />
              <div className="absolute bottom-0 left-0 right-0 bg-gradient-to-t from-black/60 to-transparent p-6">
                <p className="text-white font-medium">季節の和菓子特集</p>
              </div>
            </div>

            <div className="relative aspect-[4/3] rounded-2xl overflow-hidden group cursor-pointer">
              <img
                src="/fresh-organic-vegetables-from-japanese-farm.jpg"
                alt="Fresh vegetables"
                className="w-full h-full object-cover group-hover:scale-105 transition-transform duration-300"
              />
              <div className="absolute bottom-0 left-0 right-0 bg-gradient-to-t from-black/60 to-transparent p-6">
                <p className="text-white font-medium">産地直送の新鮮野菜</p>
              </div>
            </div>
          </div>
        </div>
      </section>

      {/* Floating Search Button */}
      <Link href="/products">
        <Button
          size="lg"
          className="fixed bottom-8 right-8 rounded-full shadow-lg bg-primary hover:bg-primary/90 text-primary-foreground px-6 py-6 text-base"
        >
          探索する
          <Search className="ml-2 w-5 h-5" />
        </Button>
      </Link>
    </main>
  )
}
