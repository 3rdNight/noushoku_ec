"use client"

import { useState } from "react"
import Link from "next/link"
import { Button } from "@/components/ui/button"
import { Card, CardContent } from "@/components/ui/card"
import { Badge } from "@/components/ui/badge"
import { products, categories } from "@/lib/products"
import { ShoppingCart, ArrowLeft } from "lucide-react"

export default function ProductsPage() {
  const [selectedCategory, setSelectedCategory] = useState<string>("all")

  const filteredProducts =
    selectedCategory === "all" ? products : products.filter((p) => p.category === selectedCategory)

  return (
    <div className="min-h-screen bg-[#E8E3D8]">
      {/* Header */}
      <header className="bg-background/80 backdrop-blur-sm border-b border-foreground/10 sticky top-0 z-50">
        <div className="max-w-7xl mx-auto px-6 py-4 flex items-center justify-between">
          <Link href="/" className="flex items-center gap-2 text-foreground hover:text-foreground/80 transition-colors">
            <ArrowLeft className="w-5 h-5" />
            <span className="font-serif text-lg">ホームへ戻る</span>
          </Link>
          <Link href="/cart">
            <Button variant="outline" size="sm" className="gap-2 bg-transparent">
              <ShoppingCart className="w-4 h-4" />
              カート
            </Button>
          </Link>
        </div>
      </header>

      <main className="max-w-7xl mx-auto px-6 py-12">
        {/* Page Title */}
        <div className="mb-12">
          <h1 className="text-4xl md:text-5xl font-serif text-foreground mb-4">商品一覧</h1>
          <p className="text-foreground/70 leading-relaxed">日本各地の生産者が丹精込めて育てた食材をお届けします。</p>
        </div>

        {/* Category Filter */}
        <div className="mb-8 flex flex-wrap gap-3">
          {categories.map((category) => (
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

        {/* Products Grid */}
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-6">
          {filteredProducts.map((product) => (
            <Link key={product.id} href={`/products/${product.id}`}>
              <Card className="group cursor-pointer hover:shadow-lg transition-all duration-300 overflow-hidden h-full">
                <div className="relative aspect-square overflow-hidden bg-muted">
                  <img
                    src={product.image || "/placeholder.svg"}
                    alt={product.name}
                    className="w-full h-full object-cover group-hover:scale-105 transition-transform duration-300"
                  />
                  {!product.inStock && (
                    <div className="absolute inset-0 bg-black/50 flex items-center justify-center">
                      <Badge variant="secondary">売り切れ</Badge>
                    </div>
                  )}
                </div>
                <CardContent className="p-4">
                  <h3 className="font-medium text-lg mb-2 text-foreground group-hover:text-primary transition-colors">
                    {product.name}
                  </h3>
                  <p className="text-sm text-foreground/60 mb-3 line-clamp-2">{product.description}</p>
                  <div className="flex items-center justify-between">
                    <div>
                      <p className="text-xs text-foreground/50">{product.producer}</p>
                      <p className="text-xs text-foreground/50">{product.region}</p>
                    </div>
                    <p className="text-xl font-bold text-primary">¥{product.price.toLocaleString()}</p>
                  </div>
                </CardContent>
              </Card>
            </Link>
          ))}
        </div>

        {filteredProducts.length === 0 && (
          <div className="text-center py-16">
            <p className="text-foreground/60">該当する商品が見つかりませんでした。</p>
          </div>
        )}
      </main>
    </div>
  )
}
