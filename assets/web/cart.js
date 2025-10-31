// Cart Page
document.addEventListener("DOMContentLoaded", () => {
  renderCart()
})

function renderCart() {
  const cart = window.getCart() // Assuming getCart is a global function or needs to be imported
  const cartContent = document.getElementById("cartContent")

  if (cart.length === 0) {
    cartContent.innerHTML = `
      <div class="empty-cart">
        <div class="empty-cart-icon">🛒</div>
        <h2>カートは空です</h2>
        <p>商品を追加してください</p>
        <a href="products.html" class="btn btn-primary">商品一覧へ</a>
      </div>
    `
    return
  }

  const cartItems = cart.map((item) => {
    const product = window.getProductById(item.productId) // Assuming getProductById is a global function or needs to be imported
    return { ...item, product }
  })

  const subtotal = cartItems.reduce((sum, item) => sum + item.product.price * item.quantity, 0)
  const shipping = 500
  const total = subtotal + shipping

  cartContent.innerHTML = `
    <div class="cart-items">
      ${cartItems
        .map(
          (item) => `
        <div class="cart-item">
          <img src="${item.product.image}" alt="${item.product.name}" class="cart-item-image">
          <div class="cart-item-info">
            <h3 class="cart-item-name">${item.product.name}</h3>
            <p class="cart-item-price">${window.formatPrice(item.product.price)}</p> <!-- Assuming formatPrice is a global function or needs to be imported -->
            <div class="quantity-selector">
              <button class="quantity-btn" onclick="updateQuantity(${item.productId}, ${item.quantity - 1})">-</button>
              <input type="number" class="quantity-input" value="${item.quantity}" min="1" 
                onchange="updateQuantity(${item.productId}, this.value)">
              <button class="quantity-btn" onclick="updateQuantity(${item.productId}, ${item.quantity + 1})">+</button>
            </div>
          </div>
          <div class="cart-item-actions">
            <div class="cart-item-total">${window.formatPrice(item.product.price * item.quantity)}</div> <!-- Assuming formatPrice is a global function or needs to be imported -->
            <button class="remove-btn" onclick="removeItem(${item.productId})">削除</button>
          </div>
        </div>
      `,
        )
        .join("")}
    </div>
    
    <div class="cart-summary">
      <h2 class="form-title">注文内容</h2>
      <div class="cart-summary-row">
        <span>小計</span>
        <span>${window.formatPrice(subtotal)}</span> <!-- Assuming formatPrice is a global function or needs to be imported -->
      </div>
      <div class="cart-summary-row">
        <span>配送料</span>
        <span>${window.formatPrice(shipping)}</span> <!-- Assuming formatPrice is a global function or needs to be imported -->
      </div>
      <div class="cart-summary-row cart-summary-total">
        <span>合計</span>
        <span>${window.formatPrice(total)}</span> <!-- Assuming formatPrice is a global function or needs to be imported -->
      </div>
      <a href="checkout.html" class="btn btn-primary btn-large btn-full">チェックアウトへ進む</a>
    </div>
  `
}

function updateQuantity(productId, quantity) {
  quantity = Number.parseInt(quantity)
  if (quantity < 1) return
  window.updateCartItemQuantity(productId, quantity) // Assuming updateCartItemQuantity is a global function or needs to be imported
  renderCart()
}

function removeItem(productId) {
  if (confirm("この商品をカートから削除しますか？")) {
    window.removeFromCart(productId) // Assuming removeFromCart is a global function or needs to be imported
    renderCart()
  }
}
