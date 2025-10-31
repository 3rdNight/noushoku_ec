"use client"

import Link from "next/link"
import { ShoppingCart } from "lucide-react"
import { Button } from "@/components/ui/button"
import { useEffect, useState } from "react"

export function SiteHeader() {
  const [cartCount, setCartCount] = useState(0)

  useEffect(() => {
    // Update cart count from localStorage
    const updateCartCount = () => {
      const cart = JSON.parse(localStorage.getItem("cart") || "[]")
      const totalItems = cart.reduce((sum: number, item: any) => sum + item.quantity, 0)
      setCartCount(totalItems)
    }

    updateCartCount()

    // Listen for cart updates
    window.addEventListener("storage", updateCartCount)
    window.addEventListener("cartUpdated", updateCartCount)

    return () => {
      window.removeEventListener("storage", updateCartCount)
      window.removeEventListener("cartUpdated", updateCartCount)
    }
  }, [])

  return (
    <header className="sticky top-0 z-50 w-full border-b border-foreground/10 bg-[#E8E3D8]/95 backdrop-blur supports-[backdrop-filter]:bg-[#E8E3D8]/80">
      <div className="max-w-7xl mx-auto px-6 h-16 flex items-center justify-between">
        <Link
          href="/"
          className="font-serif text-xl md:text-2xl text-foreground hover:text-foreground/80 transition-colors"
        >
          日本の食文化
        </Link>

        <nav className="flex items-center gap-6">
          <Link
            href="/products"
            className="text-sm font-medium text-foreground/70 hover:text-foreground transition-colors hidden md:inline-block"
          >
            商品一覧
          </Link>
          <Link
            href="/producers"
            className="text-sm font-medium text-foreground/70 hover:text-foreground transition-colors hidden md:inline-block"
          >
            生産者紹介
          </Link>
          <Link href="/cart">
            <Button variant="ghost" size="sm" className="relative">
              <ShoppingCart className="w-5 h-5" />
              {cartCount > 0 && (
                <span className="absolute -top-1 -right-1 bg-primary text-primary-foreground text-xs w-5 h-5 rounded-full flex items-center justify-center font-medium">
                  {cartCount}
                </span>
              )}
            </Button>
          </Link>
        </nav>
      </div>
    </header>
  )
}
