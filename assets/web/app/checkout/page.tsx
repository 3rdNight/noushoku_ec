"use client"

import type React from "react"

import { useState, useEffect } from "react"
import Link from "next/link"
import { useRouter } from "next/navigation"
import { Button } from "@/components/ui/button"
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card"
import { Input } from "@/components/ui/input"
import { Label } from "@/components/ui/label"
import { Textarea } from "@/components/ui/textarea"
import { ArrowLeft, CreditCard, Package } from "lucide-react"
import type { Product } from "@/lib/products"

interface CartItem extends Product {
  quantity: number
}

export default function CheckoutPage() {
  const router = useRouter()
  const [cartItems, setCartItems] = useState<CartItem[]>([])
  const [isProcessing, setIsProcessing] = useState(false)
  const [formData, setFormData] = useState({
    name: "",
    email: "",
    phone: "",
    postalCode: "",
    prefecture: "",
    city: "",
    address: "",
    building: "",
    notes: "",
  })

  useEffect(() => {
    const savedCart = localStorage.getItem("cart")
    if (savedCart) {
      const cart = JSON.parse(savedCart)
      if (cart.length === 0) {
        router.push("/cart")
      }
      setCartItems(cart)
    } else {
      router.push("/cart")
    }
  }, [router])

  const subtotal = cartItems.reduce((sum, item) => sum + item.price * item.quantity, 0)
  const shippingFee = subtotal >= 5000 ? 0 : 500
  const total = subtotal + shippingFee

  const handleInputChange = (e: React.ChangeEvent<HTMLInputElement | HTMLTextAreaElement>) => {
    setFormData({
      ...formData,
      [e.target.name]: e.target.value,
    })
  }

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault()
    setIsProcessing(true)

    // Simulate order processing
    await new Promise((resolve) => setTimeout(resolve, 2000))

    // Clear cart
    localStorage.removeItem("cart")

    // Redirect to success page
    router.push("/checkout/success")
  }

  return (
    <div className="min-h-screen bg-[#E8E3D8]">
      {/* Header */}
      <header className="bg-background/80 backdrop-blur-sm border-b border-foreground/10 sticky top-0 z-50">
        <div className="max-w-7xl mx-auto px-6 py-4 flex items-center justify-between">
          <Link
            href="/cart"
            className="flex items-center gap-2 text-foreground hover:text-foreground/80 transition-colors"
          >
            <ArrowLeft className="w-5 h-5" />
            <span className="font-serif text-lg">カートへ戻る</span>
          </Link>
        </div>
      </header>

      <main className="max-w-7xl mx-auto px-6 py-12">
        <h1 className="text-4xl md:text-5xl font-serif text-foreground mb-8">お会計</h1>

        <form onSubmit={handleSubmit}>
          <div className="grid lg:grid-cols-3 gap-8">
            {/* Checkout Form */}
            <div className="lg:col-span-2 space-y-6">
              {/* Customer Information */}
              <Card>
                <CardHeader>
                  <CardTitle className="flex items-center gap-2">
                    <Package className="w-5 h-5" />
                    お客様情報
                  </CardTitle>
                </CardHeader>
                <CardContent className="space-y-4">
                  <div>
                    <Label htmlFor="name">お名前 *</Label>
                    <Input
                      id="name"
                      name="name"
                      value={formData.name}
                      onChange={handleInputChange}
                      required
                      placeholder="山田 太郎"
                    />
                  </div>

                  <div className="grid md:grid-cols-2 gap-4">
                    <div>
                      <Label htmlFor="email">メールアドレス *</Label>
                      <Input
                        id="email"
                        name="email"
                        type="email"
                        value={formData.email}
                        onChange={handleInputChange}
                        required
                        placeholder="example@email.com"
                      />
                    </div>
                    <div>
                      <Label htmlFor="phone">電話番号 *</Label>
                      <Input
                        id="phone"
                        name="phone"
                        type="tel"
                        value={formData.phone}
                        onChange={handleInputChange}
                        required
                        placeholder="090-1234-5678"
                      />
                    </div>
                  </div>
                </CardContent>
              </Card>

              {/* Shipping Address */}
              <Card>
                <CardHeader>
                  <CardTitle>配送先住所</CardTitle>
                </CardHeader>
                <CardContent className="space-y-4">
                  <div className="grid md:grid-cols-3 gap-4">
                    <div>
                      <Label htmlFor="postalCode">郵便番号 *</Label>
                      <Input
                        id="postalCode"
                        name="postalCode"
                        value={formData.postalCode}
                        onChange={handleInputChange}
                        required
                        placeholder="123-4567"
                      />
                    </div>
                    <div className="md:col-span-2">
                      <Label htmlFor="prefecture">都道府県 *</Label>
                      <Input
                        id="prefecture"
                        name="prefecture"
                        value={formData.prefecture}
                        onChange={handleInputChange}
                        required
                        placeholder="東京都"
                      />
                    </div>
                  </div>

                  <div>
                    <Label htmlFor="city">市区町村 *</Label>
                    <Input
                      id="city"
                      name="city"
                      value={formData.city}
                      onChange={handleInputChange}
                      required
                      placeholder="渋谷区"
                    />
                  </div>

                  <div>
                    <Label htmlFor="address">番地 *</Label>
                    <Input
                      id="address"
                      name="address"
                      value={formData.address}
                      onChange={handleInputChange}
                      required
                      placeholder="1-2-3"
                    />
                  </div>

                  <div>
                    <Label htmlFor="building">建物名・部屋番号</Label>
                    <Input
                      id="building"
                      name="building"
                      value={formData.building}
                      onChange={handleInputChange}
                      placeholder="マンション名 101号室"
                    />
                  </div>

                  <div>
                    <Label htmlFor="notes">配送に関する備考</Label>
                    <Textarea
                      id="notes"
                      name="notes"
                      value={formData.notes}
                      onChange={handleInputChange}
                      placeholder="配送時間の指定など"
                      rows={3}
                    />
                  </div>
                </CardContent>
              </Card>

              {/* Payment Method */}
              <Card>
                <CardHeader>
                  <CardTitle className="flex items-center gap-2">
                    <CreditCard className="w-5 h-5" />
                    お支払い方法
                  </CardTitle>
                </CardHeader>
                <CardContent>
                  <div className="bg-muted p-4 rounded-lg">
                    <p className="text-foreground/80">代金引換（商品到着時にお支払い）</p>
                    <p className="text-sm text-foreground/60 mt-2">
                      配達員に現金またはクレジットカードでお支払いください。
                    </p>
                  </div>
                </CardContent>
              </Card>
            </div>

            {/* Order Summary */}
            <div className="lg:col-span-1">
              <Card className="sticky top-24">
                <CardHeader>
                  <CardTitle>注文内容</CardTitle>
                </CardHeader>
                <CardContent className="space-y-4">
                  {/* Cart Items */}
                  <div className="space-y-3 max-h-64 overflow-y-auto">
                    {cartItems.map((item) => (
                      <div key={item.id} className="flex gap-3 text-sm">
                        <div className="w-16 h-16 rounded overflow-hidden bg-muted flex-shrink-0">
                          <img
                            src={item.image || "/placeholder.svg"}
                            alt={item.name}
                            className="w-full h-full object-cover"
                          />
                        </div>
                        <div className="flex-1 min-w-0">
                          <p className="font-medium text-foreground truncate">{item.name}</p>
                          <p className="text-foreground/60">
                            ¥{item.price.toLocaleString()} × {item.quantity}
                          </p>
                        </div>
                        <p className="font-medium text-foreground">¥{(item.price * item.quantity).toLocaleString()}</p>
                      </div>
                    ))}
                  </div>

                  <div className="border-t border-foreground/10 pt-4 space-y-2">
                    <div className="flex justify-between text-foreground/80">
                      <span>小計</span>
                      <span>¥{subtotal.toLocaleString()}</span>
                    </div>
                    <div className="flex justify-between text-foreground/80">
                      <span>配送料</span>
                      <span>{shippingFee === 0 ? "無料" : `¥${shippingFee.toLocaleString()}`}</span>
                    </div>
                    <div className="flex justify-between text-xl font-bold text-foreground pt-2 border-t border-foreground/10">
                      <span>合計</span>
                      <span className="text-primary">¥{total.toLocaleString()}</span>
                    </div>
                  </div>

                  <Button type="submit" size="lg" className="w-full text-lg py-6" disabled={isProcessing}>
                    {isProcessing ? "処理中..." : "注文を確定する"}
                  </Button>

                  <p className="text-xs text-foreground/60 text-center">
                    注文を確定することで、利用規約に同意したものとみなされます。
                  </p>
                </CardContent>
              </Card>
            </div>
          </div>
        </form>
      </main>
    </div>
  )
}
