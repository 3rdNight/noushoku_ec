"use client"

import { useParams, useRouter } from "next/navigation"
import Link from "next/link"
import { Button } from "@/components/ui/button"
import { Card, CardContent } from "@/components/ui/card"
import { Badge } from "@/components/ui/badge"
import { producers } from "@/lib/producers"
import { products } from "@/lib/products"
import { ArrowLeft, MapPin, Heart } from "lucide-react"

export default function ProducerDetailPage() {
  const params = useParams()
  const router = useRouter()

  const producer = producers.find((p) => p.id === params.id)

  if (!producer) {
    return (
      <div className="min-h-screen bg-[#E8E3D8] flex items-center justify-center">
        <div className="text-center">
          <h1 className="text-2xl font-serif text-foreground mb-4">生産者が見つかりません</h1>
          <Link href="/producers">
            <Button>生産者一覧へ戻る</Button>
          </Link>
        </div>
      </div>
    )
  }

  const producerProducts = products.filter((p) => producer.products.includes(p.id))

  return (
    <div className="min-h-screen bg-[#E8E3D8]">
      {/* Header */}
      <header className="bg-background/80 backdrop-blur-sm border-b border-foreground/10 sticky top-0 z-50">
        <div className="max-w-7xl mx-auto px-6 py-4 flex items-center justify-between">
          <button
            onClick={() => router.back()}
            className="flex items-center gap-2 text-foreground hover:text-foreground/80 transition-colors"
          >
            <ArrowLeft className="w-5 h-5" />
            <span className="font-serif text-lg">戻る</span>
          </button>
        </div>
      </header>

      <main className="max-w-7xl mx-auto px-6 py-12">
        {/* Hero Section */}
        <div className="grid md:grid-cols-2 gap-12 mb-16">
          <div className="relative aspect-[4/3] rounded-3xl overflow-hidden bg-muted">
            <img
              src={producer.image || "/placeholder.svg"}
              alt={producer.name}
              className="w-full h-full object-cover"
            />
          </div>

          <div className="flex flex-col justify-center">
            <Badge className="mb-4 w-fit">
              {producer.category === "sweets"
                ? "和菓子・洋菓子"
                : producer.category === "meat-eggs"
                  ? "肉・卵"
                  : "野菜"}
            </Badge>
            <h1 className="text-4xl md:text-5xl font-serif text-foreground mb-4">{producer.name}</h1>
            <p className="text-lg text-foreground/80 mb-6 flex items-center gap-2">
              <MapPin className="w-5 h-5" />
              {producer.region}
            </p>
            <p className="text-xl text-foreground/80 leading-relaxed">{producer.description}</p>
          </div>
        </div>

        {/* Story Section */}
        <section className="mb-16">
          <h2 className="text-3xl font-serif text-foreground mb-6">生産者のストーリー</h2>
          <Card>
            <CardContent className="p-8">
              <p className="text-foreground/80 leading-relaxed text-lg">{producer.story}</p>
            </CardContent>
          </Card>
        </section>

        {/* Philosophy Section */}
        <section className="mb-16">
          <h2 className="text-3xl font-serif text-foreground mb-6">こだわり・理念</h2>
          <Card className="bg-primary/5 border-primary/20">
            <CardContent className="p-8">
              <div className="flex items-start gap-4">
                <Heart className="w-8 h-8 text-primary flex-shrink-0 mt-1" />
                <p className="text-foreground/80 leading-relaxed text-lg italic">{producer.philosophy}</p>
              </div>
            </CardContent>
          </Card>
        </section>

        {/* Products Section */}
        <section>
          <h2 className="text-3xl font-serif text-foreground mb-6">取り扱い商品</h2>
          <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-6">
            {producerProducts.map((product) => (
              <Link key={product.id} href={`/products/${product.id}`}>
                <Card className="group cursor-pointer hover:shadow-lg transition-all duration-300 overflow-hidden h-full">
                  <div className="relative aspect-square overflow-hidden bg-muted">
                    <img
                      src={product.image || "/placeholder.svg"}
                      alt={product.name}
                      className="w-full h-full object-cover group-hover:scale-105 transition-transform duration-300"
                    />
                  </div>
                  <CardContent className="p-4">
                    <h3 className="font-medium text-lg mb-2 text-foreground group-hover:text-primary transition-colors">
                      {product.name}
                    </h3>
                    <p className="text-sm text-foreground/60 mb-3 line-clamp-2">{product.description}</p>
                    <p className="text-xl font-bold text-primary">¥{product.price.toLocaleString()}</p>
                  </CardContent>
                </Card>
              </Link>
            ))}
          </div>
        </section>
      </main>
    </div>
  )
}
