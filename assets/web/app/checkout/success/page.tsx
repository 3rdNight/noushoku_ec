"use client"

import Link from "next/link"
import { Button } from "@/components/ui/button"
import { Card, CardContent } from "@/components/ui/card"
import { CheckCircle, Home, Package } from "lucide-react"

export default function CheckoutSuccessPage() {
  return (
    <div className="min-h-screen bg-[#E8E3D8] flex items-center justify-center px-6">
      <Card className="max-w-2xl w-full">
        <CardContent className="p-12 text-center">
          <div className="mb-6 flex justify-center">
            <div className="w-20 h-20 rounded-full bg-primary/10 flex items-center justify-center">
              <CheckCircle className="w-12 h-12 text-primary" />
            </div>
          </div>

          <h1 className="text-3xl md:text-4xl font-serif text-foreground mb-4">ご注文ありがとうございます</h1>

          <p className="text-foreground/80 leading-relaxed mb-8">
            ご注文を承りました。
            <br />
            ご登録いただいたメールアドレスに確認メールをお送りしました。
            <br />
            商品は2〜3営業日以内に発送いたします。
          </p>

          <div className="bg-muted p-6 rounded-lg mb-8">
            <div className="flex items-center justify-center gap-2 text-foreground/70 mb-2">
              <Package className="w-5 h-5" />
              <span className="font-medium">配送状況の確認</span>
            </div>
            <p className="text-sm text-foreground/60">発送後、追跡番号をメールでお知らせいたします。</p>
          </div>

          <div className="flex flex-col sm:flex-row gap-4 justify-center">
            <Link href="/">
              <Button size="lg" className="gap-2">
                <Home className="w-5 h-5" />
                ホームへ戻る
              </Button>
            </Link>
            <Link href="/products">
              <Button size="lg" variant="outline" className="gap-2 bg-transparent">
                買い物を続ける
              </Button>
            </Link>
          </div>
        </CardContent>
      </Card>
    </div>
  )
}
