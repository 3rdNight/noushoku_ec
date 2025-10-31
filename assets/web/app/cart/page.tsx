"use client"

import { useState, useEffect } from "react"
import Link from "next/link"
import { useRouter } from "next/navigation"
import { Button } from "@/components/ui/button"
import { Card, CardContent } from "@/components/ui/card"
import { ArrowLeft, Minus, Plus, Trash2, ShoppingBag } from "lucide-react"
import type { Product } from "@/lib/products"

interface CartItem extends Product {
  quantity: number
}

export default function CartPage() {
  const router = useRouter()
  const [cartItems, setCartItems] = useState<CartItem[]>([])
  const [isLoading, setIsLoading] = useState(true)

  useEffect(() => {
    // Load cart from localStorage
    const savedCart = localStorage.getItem("cart")
    if (savedCart) {
      setCartItems(JSON.parse(savedCart))
    }
    setIsLoading(false)
  }, [])

  const updateCart = (newCart: CartItem[]) => {
    setCartItems(newCart)
    localStorage.setItem("cart", JSON.stringify(newCart))
    window.dispatchEvent(new Event("cartUpdated"))
  }

  const updateQuantity = (productId: string, newQuantity: number) => {
    if (newQuantity < 1) return
    const updatedCart = cartItems.map((item) => (item.id === productId ? { ...item, quantity: newQuantity } : item))
    updateCart(updatedCart)
  }

  const removeItem = (productId: string) => {
    const updatedCart = cartItems.filter((item) => item.id !== productId)
    updateCart(updatedCart)
  }

  const clearCart = () => {
    updateCart([])
  }

  const subtotal = cartItems.reduce((sum, item) => sum + item.price * item.quantity, 0)
  const shippingFee = subtotal >= 5000 ? 0 : 500
  const total = subtotal + shippingFee

  const handleCheckout = () => {
    router.push("/checkout")
  }

  if (isLoading) {
    return (
      <div className="min-h-screen bg-[#E8E3D8] flex items-center justify-center">
        <p className="text-foreground/60">読み込み中...</p>
      </div>
    )
  }

  return (
    <div className="min-h-screen bg-[#E8E3D8]">
      {/* Header */}
      <header className="bg-background/80 backdrop-blur-sm border-b border-foreground/10 sticky top-0 z-50">
        <div className="max-w-7xl mx-auto px-6 py-4 flex items-center justify-between">
          <Link
            href="/products"
            className="flex items-center gap-2 text-foreground hover:text-foreground/80 transition-colors"
          >
            <ArrowLeft className="w-5 h-5" />
            <span className="font-serif text-lg">買い物を続ける</span>
          </Link>
        </div>
      </header>

      <main className="max-w-7xl mx-auto px-6 py-12">
        <h1 className="text-4xl md:text-5xl font-serif text-foreground mb-8">ショッピングカート</h1>

        {cartItems.length === 0 ? (
          <div className="text-center py-16">
            <ShoppingBag className="w-24 h-24 mx-auto text-foreground/20 mb-6" />
            <h2 className="text-2xl font-serif text-foreground mb-4">カートは空です</h2>
            <p className="text-foreground/60 mb-8">商品を追加してください</p>
            <Link href="/products">
              <Button size="lg">商品を探す</Button>
            </Link>
          </div>
        ) : (
          <div className="grid lg:grid-cols-3 gap-8">
            {/* Cart Items */}
            <div className="lg:col-span-2 space-y-4">
              {cartItems.map((item) => (
                <Card key={item.id}>
                  <CardContent className="p-6">
                    <div className="flex gap-6">
                      {/* Product Image */}
                      <Link href={`/products/${item.id}`} className="flex-shrink-0">
                        <div className="w-24 h-24 rounded-lg overflow-hidden bg-muted">
                          <img
                            src={item.image || "/placeholder.svg"}
                            alt={item.name}
                            className="w-full h-full object-cover hover:scale-105 transition-transform duration-300"
                          />
                        </div>
                      </Link>

                      {/* Product Info */}
                      <div className="flex-1 min-w-0">
                        <Link href={`/products/${item.id}`}>
                          <h3 className="font-medium text-lg text-foreground hover:text-primary transition-colors mb-1">
                            {item.name}
                          </h3>
                        </Link>
                        <p className="text-sm text-foreground/60 mb-2">
                          {item.producer} / {item.region}
                        </p>
                        <p className="text-lg font-bold text-primary">¥{item.price.toLocaleString()}</p>
                      </div>

                      {/* Quantity Controls */}
                      <div className="flex flex-col items-end gap-4">
                        <Button
                          variant="ghost"
                          size="icon"
                          onClick={() => removeItem(item.id)}
                          className="text-destructive hover:text-destructive hover:bg-destructive/10"
                        >
                          <Trash2 className="w-4 h-4" />
                        </Button>

                        <div className="flex items-center gap-2">
                          <Button
                            variant="outline"
                            size="icon"
                            className="h-8 w-8 bg-transparent"
                            onClick={() => updateQuantity(item.id, item.quantity - 1)}
                            disabled={item.quantity <= 1}
                          >
                            <Minus className="w-3 h-3" />
                          </Button>
                          <span className="text-lg font-medium text-foreground w-8 text-center">{item.quantity}</span>
                          <Button
                            variant="outline"
                            size="icon"
                            className="h-8 w-8 bg-transparent"
                            onClick={() => updateQuantity(item.id, item.quantity + 1)}
                          >
                            <Plus className="w-3 h-3" />
                          </Button>
                        </div>

                        <p className="text-sm text-foreground/60">
                          小計: ¥{(item.price * item.quantity).toLocaleString()}
                        </p>
                      </div>
                    </div>
                  </CardContent>
                </Card>
              ))}

              <div className="flex justify-end pt-4">
                <Button
                  variant="outline"
                  onClick={clearCart}
                  className="text-destructive hover:text-destructive bg-transparent"
                >
                  <Trash2 className="w-4 h-4 mr-2" />
                  カートを空にする
                </Button>
              </div>
            </div>

            {/* Order Summary */}
            <div className="lg:col-span-1">
              <Card className="sticky top-24">
                <CardContent className="p-6">
                  <h2 className="text-xl font-serif text-foreground mb-6">注文内容</h2>

                  <div className="space-y-4 mb-6">
                    <div className="flex justify-between text-foreground/80">
                      <span>小計</span>
                      <span>¥{subtotal.toLocaleString()}</span>
                    </div>

                    <div className="flex justify-between text-foreground/80">
                      <span>配送料</span>
                      <span>{shippingFee === 0 ? "無料" : `¥${shippingFee.toLocaleString()}`}</span>
                    </div>

                    {subtotal < 5000 && (
                      <p className="text-xs text-foreground/60 bg-muted p-3 rounded">¥5,000以上のご購入で送料無料</p>
                    )}

                    <div className="border-t border-foreground/10 pt-4">
                      <div className="flex justify-between text-xl font-bold text-foreground">
                        <span>合計</span>
                        <span className="text-primary">¥{total.toLocaleString()}</span>
                      </div>
                    </div>
                  </div>

                  <Button size="lg" className="w-full text-lg py-6" onClick={handleCheckout}>
                    お会計へ進む
                  </Button>

                  <Link href="/products">
                    <Button variant="outline" size="lg" className="w-full mt-3 bg-transparent">
                      買い物を続ける
                    </Button>
                  </Link>
                </CardContent>
              </Card>
            </div>
          </div>
        )}
      </main>
    </div>
  )
}
