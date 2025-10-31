"use client"

import { useState } from "react"
import Link from "next/link"
import { Button } from "@/components/ui/button"
import { Card, CardContent } from "@/components/ui/card"
import { Badge } from "@/components/ui/badge"
import { producers, producerCategories } from "@/lib/producers"
import { ArrowLeft, MapPin } from "lucide-react"

export default function ProducersPage() {
  const [selectedCategory, setSelectedCategory] = useState<string>("all")

  const filteredProducers =
    selectedCategory === "all" ? producers : producers.filter((p) => p.category === selectedCategory)

  return (
    <div className="min-h-screen bg-[#E8E3D8]">
      {/* Header */}
      <header className="bg-background/80 backdrop-blur-sm border-b border-foreground/10 sticky top-0 z-50">
        <div className="max-w-7xl mx-auto px-6 py-4 flex items-center justify-between">
          <Link href="/" className="flex items-center gap-2 text-foreground hover:text-foreground/80 transition-colors">
            <ArrowLeft className="w-5 h-5" />
            <span className="font-serif text-lg">ホームへ戻る</span>
          </Link>
        </div>
      </header>

      <main className="max-w-7xl mx-auto px-6 py-12">
        {/* Page Title */}
        <div className="mb-12">
          <h1 className="text-4xl md:text-5xl font-serif text-foreground mb-4">生産者紹介</h1>
          <p className="text-foreground/70 leading-relaxed">
            日本各地で丹精込めて食材を育てる生産者の方々をご紹介します。
          </p>
        </div>

        {/* Category Filter */}
        <div className="mb-8 flex flex-wrap gap-3">
          {producerCategories.map((category) => (
            <Button
              key={category.id}
              variant={selectedCategory === category.value ? "default" : "outline"}
              onClick={() => setSelectedCategory(category.value)}
              className="rounded-full"
            >
              {category.name}
            </Button>
          ))}
        </div>

        {/* Producers Grid */}
        <div className="grid grid-cols-1 md:grid-cols-2 gap-8">
          {filteredProducers.map((producer) => (
            <Link key={producer.id} href={`/producers/${producer.id}`}>
              <Card className="group cursor-pointer hover:shadow-lg transition-all duration-300 overflow-hidden h-full">
                <div className="relative aspect-[3/2] overflow-hidden bg-muted">
                  <img
                    src={producer.image || "/placeholder.svg"}
                    alt={producer.name}
                    className="w-full h-full object-cover group-hover:scale-105 transition-transform duration-300"
                  />
                  <div className="absolute top-4 left-4">
                    <Badge>
                      {producer.category === "sweets"
                        ? "和菓子・洋菓子"
                        : producer.category === "meat-eggs"
                          ? "肉・卵"
                          : "野菜"}
                    </Badge>
                  </div>
                </div>
                <CardContent className="p-6">
                  <h3 className="font-serif text-2xl text-foreground group-hover:text-primary transition-colors mb-2">
                    {producer.name}
                  </h3>
                  <p className="text-sm text-foreground/60 mb-3 flex items-center gap-1">
                    <MapPin className="w-4 h-4" />
                    {producer.region}
                  </p>
                  <p className="text-foreground/80 leading-relaxed line-clamp-3">{producer.description}</p>
                </CardContent>
              </Card>
            </Link>
          ))}
        </div>

        {filteredProducers.length === 0 && (
          <div className="text-center py-16">
            <p className="text-foreground/60">該当する生産者が見つかりませんでした。</p>
          </div>
        )}
      </main>
    </div>
  )
}
