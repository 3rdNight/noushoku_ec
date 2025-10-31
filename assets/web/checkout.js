// Checkout Page
document.addEventListener("DOMContentLoaded", () => {
  renderOrderSummary()

  const checkoutForm = document.getElementById("checkoutForm")
  checkoutForm.addEventListener("submit", handleCheckout)
})

function renderOrderSummary() {
  const cart = getCart()

  if (cart.length === 0) {
    window.location.href = "cart.html"
    return
  }

  const cartItems = cart.map((item) => {
    const product = getProductById(item.productId)
    return { ...item, product }
  })

  const subtotal = cartItems.reduce((sum, item) => sum + item.product.price * item.quantity, 0)
  const shipping = 500
  const total = subtotal + shipping

  document.getElementById("orderSummary").innerHTML = `
    <div style="display: flex; flex-direction: column; gap: 1rem; margin-bottom: 1.5rem;">
      ${cartItems
        .map(
          (item) => `
        <div style="display: flex; justify-content: space-between; font-size: 0.875rem;">
          <span>${item.product.name} × ${item.quantity}</span>
          <span>${formatPrice(item.product.price * item.quantity)}</span>
        </div>
      `,
        )
        .join("")}
    </div>
    <div style="border-top: 2px solid var(--color-border); padding-top: 1rem;">
      <div style="display: flex; justify-content: space-between; margin-bottom: 0.5rem;">
        <span>小計</span>
        <span>${formatPrice(subtotal)}</span>
      </div>
      <div style="display: flex; justify-content: space-between; margin-bottom: 1rem;">
        <span>配送料</span>
        <span>${formatPrice(shipping)}</span>
      </div>
      <div style="display: flex; justify-content: space-between; font-size: 1.25rem; font-weight: 700; color: var(--color-primary);">
        <span>合計</span>
        <span>${formatPrice(total)}</span>
      </div>
    </div>
  `
}

function handleCheckout(e) {
  e.preventDefault()

  // In a real application, you would send this data to a server
  const formData = new FormData(e.target)
  const orderData = {
    name: formData.get("name"),
    email: formData.get("email"),
    phone: formData.get("phone"),
    postalCode: formData.get("postalCode"),
    address: formData.get("address"),
    notes: formData.get("notes"),
    cart: getCart(),
    timestamp: new Date().toISOString(),
  }

  console.log("Order submitted:", orderData)

  // Clear cart and redirect to success page
  clearCart()
  alert("ご注文ありがとうございます！\n注文確認メールをお送りしました。")
  window.location.href = "index.html"
}

// Declare variables or import functions here
function getCart() {
  // Implementation for getCart
}

function getProductById(productId) {
  // Implementation for getProductById
}

function formatPrice(price) {
  // Implementation for formatPrice
}

function clearCart() {
  // Implementation for clearCart
}
