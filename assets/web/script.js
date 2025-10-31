// Cart Management
function getCart() {
  const cart = localStorage.getItem("cart")
  return cart ? JSON.parse(cart) : []
}

function saveCart(cart) {
  localStorage.setItem("cart", JSON.stringify(cart))
  updateCartCount()
}

function addToCart(productId, quantity = 1) {
  const cart = getCart()
  const existingItem = cart.find((item) => item.productId === productId)

  if (existingItem) {
    existingItem.quantity += quantity
  } else {
    cart.push({ productId, quantity })
  }

  saveCart(cart)
  alert("カートに追加しました")
}

function removeFromCart(productId) {
  const cart = getCart()
  const updatedCart = cart.filter((item) => item.productId !== productId)
  saveCart(updatedCart)
}

function updateCartItemQuantity(productId, quantity) {
  const cart = getCart()
  const item = cart.find((item) => item.productId === productId)

  if (item) {
    item.quantity = Math.max(1, quantity)
    saveCart(cart)
  }
}

function updateCartCount() {
  const cart = getCart()
  const totalItems = cart.reduce((sum, item) => sum + item.quantity, 0)
  const cartCountElements = document.querySelectorAll(".cart-count")
  cartCountElements.forEach((el) => {
    el.textContent = totalItems
  })
}

function clearCart() {
  localStorage.removeItem("cart")
  updateCartCount()
}

// Initialize cart count on page load
document.addEventListener("DOMContentLoaded", () => {
  updateCartCount()
})

// Format price
function formatPrice(price) {
  return `¥${price.toLocaleString()}`
}

// Get product by ID
const products = [] // Declare the products variable here
function getProductById(id) {
  return products.find((p) => p.id === id)
}

// Get producer by ID
const producers = [] // Declare the producers variable here
function getProducerById(id) {
  return producers.find((p) => p.id === id)
}
