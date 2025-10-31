// Product Detail Page
document.addEventListener("DOMContentLoaded", () => {
  const urlParams = new URLSearchParams(window.location.search)
  const productId = Number.parseInt(urlParams.get("id"))

  // Declare or import necessary variables/functions
  const getProductById = (id) => {
    // Dummy implementation for demonstration purposes
    return {
      id: 1,
      name: "Product Name",
      categoryLabel: "Category",
      price: 100,
      description: "Product Description",
      producerId: 1,
    }
  }

  const getProducerById = (id) => {
    // Dummy implementation for demonstration purposes
    return { id: 1, name: "Producer Name" }
  }

  const formatPrice = (price) => {
    // Dummy implementation for demonstration purposes
    return `¥${price}`
  }

  const addToCart = (productId, quantity) => {
    // Dummy implementation for demonstration purposes
    console.log(`Added ${quantity} of product ${productId} to cart`)
  }

  const products = [
    {
      id: 1,
      name: "Product 1",
      category: "Category 1",
      categoryLabel: "Category 1 Label",
      price: 100,
      description: "Description 1",
      producerId: 1,
    },
    {
      id: 2,
      name: "Product 2",
      category: "Category 1",
      categoryLabel: "Category 1 Label",
      price: 200,
      description: "Description 2",
      producerId: 2,
    },
    {
      id: 3,
      name: "Product 3",
      category: "Category 2",
      categoryLabel: "Category 2 Label",
      price: 300,
      description: "Description 3",
      producerId: 3,
    },
  ]

  const product = getProductById(productId)

  if (!product) {
    document.getElementById("productDetail").innerHTML = "<p>商品が見つかりません</p>"
    return
  }

  const producer = getProducerById(product.producerId)

  document.getElementById("productDetail").innerHTML = `
    <div>
      <img src="${product.image}" alt="${product.name}" class="product-detail-image">
    </div>
    <div class="product-detail-info">
      <span class="product-category">${product.categoryLabel}</span>
      <h1 class="product-detail-title">${product.name}</h1>
      <p class="product-detail-price">${formatPrice(product.price)}</p>
      <p>${product.description}</p>
      <div>
        <strong>生産者:</strong> ${producer ? producer.name : "不明"}
      </div>
      <div class="quantity-selector">
        <button class="quantity-btn" id="decreaseBtn">-</button>
        <input type="number" class="quantity-input" id="quantityInput" value="1" min="1">
        <button class="quantity-btn" id="increaseBtn">+</button>
      </div>
      <button class="btn btn-primary btn-large btn-full" id="addToCartBtn">カートに追加</button>
    </div>
  `

  const quantityInput = document.getElementById("quantityInput")
  const decreaseBtn = document.getElementById("decreaseBtn")
  const increaseBtn = document.getElementById("increaseBtn")
  const addToCartBtn = document.getElementById("addToCartBtn")

  decreaseBtn.addEventListener("click", () => {
    const currentValue = Number.parseInt(quantityInput.value)
    if (currentValue > 1) {
      quantityInput.value = currentValue - 1
    }
  })

  increaseBtn.addEventListener("click", () => {
    const currentValue = Number.parseInt(quantityInput.value)
    quantityInput.value = currentValue + 1
  })

  addToCartBtn.addEventListener("click", () => {
    const quantity = Number.parseInt(quantityInput.value)
    addToCart(productId, quantity)
  })

  // Related products
  const relatedProducts = products.filter((p) => p.category === product.category && p.id !== product.id).slice(0, 3)

  document.getElementById("relatedProducts").innerHTML = relatedProducts
    .map(
      (p) => `
    <a href="product-detail.html?id=${p.id}" class="product-card">
      <img src="${p.image}" alt="${p.name}" class="product-image">
      <div class="product-info">
        <span class="product-category">${p.categoryLabel}</span>
        <h3 class="product-name">${p.name}</h3>
        <p class="product-price">${formatPrice(p.price)}</p>
      </div>
    </a>
  `,
    )
    .join("")
})
