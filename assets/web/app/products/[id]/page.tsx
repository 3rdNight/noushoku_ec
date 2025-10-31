"use client"

import { useState } from "react"
import { useParams, useRouter } from "next/navigation"
import Link from "next/link"
import { Button } from "@/components/ui/button"
import { Card, CardContent } from "@/components/ui/card"
import { Badge } from "@/components/ui/badge"
import { products } from "@/lib/products"
import { ArrowLeft, ShoppingCart, Minus, Plus, MapPin, User } from "lucide-react"

export default function ProductDetailPage() {
  const params = useParams()
  const router = useRouter()
  const [quantity, setQuantity] = useState(1)
  const [addedToCart, setAddedToCart] = useState(false)

  const product = products.find((p) => p.id === params.id)

  if (!product) {
    return (
      <div className="min-h-screen bg-[#E8E3D8] flex items-center justify-center">
        <div className="text-center">
          <h1 className="text-2xl font-serif text-foreground mb-4">商品が見つかりません</h1>
          <Link href="/products">
            <Button>商品一覧へ戻る</Button>
          </Link>
        </div>
      </div>
    )
  }

  const handleAddToCart = () => {
    // Get existing cart from localStorage
    const existingCart = JSON.parse(localStorage.getItem("cart") || "[]")

    // Check if product already exists in cart
    const existingItemIndex = existingCart.findIndex((item: any) => item.id === product.id)

    if (existingItemIndex > -1) {
      // Update quantity if exists
      existingCart[existingItemIndex].quantity += quantity
    } else {
      // Add new item
      existingCart.push({ ...product, quantity })
    }

    // Save to localStorage
    localStorage.setItem("cart", JSON.stringify(existingCart))

    window.dispatchEvent(new Event("cartUpdated"))

    setAddedToCart(true)
    setTimeout(() => setAddedToCart(false), 2000)
  }

  const incrementQuantity = () => setQuantity((prev) => prev + 1)
  const decrementQuantity = () => setQuantity((prev) => (prev > 1 ? prev - 1 : 1))

  const totalPrice = product.price * quantity

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
          <Link href="/cart">
            <Button variant="outline" size="sm" className="gap-2 bg-transparent">
              <ShoppingCart className="w-4 h-4" />
              カート
            </Button>
          </Link>
        </div>
      </header>

      <main className="max-w-7xl mx-auto px-6 py-12">
        <div className="grid md:grid-cols-2 gap-12">
          {/* Product Image */}
          <div className="relative aspect-square rounded-3xl overflow-hidden bg-muted">
            <img src={product.image || "/placeholder.svg"} alt={product.name} className="w-full h-full object-cover" />
            {!product.inStock && (
              <div className="absolute inset-0 bg-black/50 flex items-center justify-center">
                <Badge variant="secondary" className="text-lg px-6 py-2">
                  売り切れ
                </Badge>
              </div>
            )}
          </div>

          {/* Product Info */}
          <div className="flex flex-col">
            <div className="mb-6">
              <Badge className="mb-4">
                {product.category === "sweets"
                  ? "和菓子・洋菓子"
                  : product.category === "meat-eggs"
                    ? "肉・卵"
                    : "野菜"}
              </Badge>
              <h1 className="text-4xl font-serif text-foreground mb-4">{product.name}</h1>
              <p className="text-3xl font-bold text-primary mb-6">¥{product.price.toLocaleString()}</p>
            </div>

            <div className="mb-8">
              <p className="text-foreground/80 leading-relaxed">{product.description}</p>
            </div>

            {/* Producer Info */}
            <Card className="mb-8">
              <CardContent className="p-6">
                <h3 className="font-medium text-foreground mb-4 flex items-center gap-2">
                  <User className="w-5 h-5" />
                  生産者情報
                </h3>
                <div className="space-y-2 text-sm">
                  <p className="text-foreground/80">
                    <span className="font-medium">生産者:</span> {product.producer}
                  </p>
                  <p className="text-foreground/80 flex items-center gap-1">
                    <MapPin className="w-4 h-4" />
                    <span className="font-medium">産地:</span> {product.region}
                  </p>
                </div>
              </CardContent>
            </Card>

            {/* Quantity Selector */}
            {product.inStock && (
              <>
                <div className="mb-6">
                  <label className="block text-sm font-medium text-foreground mb-3">数量</label>
                  <div className="flex items-center gap-4">
                    <Button variant="outline" size="icon" onClick={decrementQuantity} disabled={quantity <= 1}>
                      <Minus className="w-4 h-4" />
                    </Button>
                    <span className="text-2xl font-medium text-foreground w-12 text-center">{quantity}</span>
                    <Button variant="outline" size="icon" onClick={incrementQuantity}>
                      <Plus className="w-4 h-4" />
                    </Button>
                  </div>
                </div>

                {/* Total Price */}
                <div className="mb-6 p-4 bg-muted rounded-lg">
                  <div className="flex justify-between items-center">
                    <span className="text-foreground/70">合計金額</span>
                    <span className="text-2xl font-bold text-primary">¥{totalPrice.toLocaleString()}</span>
                  </div>
                </div>

                {/* Add to Cart Button */}
                <Button size="lg" className="w-full text-lg py-6" onClick={handleAddToCart} disabled={addedToCart}>
                  {addedToCart ? (
                    "カートに追加しました"
                  ) : (
                    <>
                      <ShoppingCart className="w-5 h-5 mr-2" />
                      カートに追加
                    </>
                  )}
                </Button>
              </>
            )}

            {!product.inStock && (
              <div className="p-6 bg-muted rounded-lg text-center">
                <p className="text-foreground/70">申し訳ございません。この商品は現在売り切れです。</p>
              </div>
            )}
          </div>
        </div>

        {/* Related Products */}
        <section className="mt-24">
          <h2 className="text-3xl font-serif text-foreground mb-8">関連商品</h2>
          <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-6">
            {products
              .filter((p) => p.category === product.category && p.id !== product.id)
              .slice(0, 4)
              .map((relatedProduct) => (
                <Link key={relatedProduct.id} href={`/products/${relatedProduct.id}`}>
                  <Card className="group cursor-pointer hover:shadow-lg transition-all duration-300 overflow-hidden h-full">
                    <div className="relative aspect-square overflow-hidden bg-muted">
                      <img
                        src={relatedProduct.image || "/placeholder.svg"}
                        alt={relatedProduct.name}
                        className="w-full h-full object-cover group-hover:scale-105 transition-transform duration-300"
                      />
                    </div>
                    <CardContent className="p-4">
                      <h3 className="font-medium text-lg mb-2 text-foreground group-hover:text-primary transition-colors">
                        {relatedProduct.name}
                      </h3>
                      <p className="text-xl font-bold text-primary">¥{relatedProduct.price.toLocaleString()}</p>
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
