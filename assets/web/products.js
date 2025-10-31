// Products Page
const products = [
  { id: 1, category: "electronics", categoryLabel: "Electronics", name: "Laptop", price: 999.99, image: "laptop.jpg" },
  { id: 2, category: "clothing", categoryLabel: "Clothing", name: "T-Shirt", price: 19.99, image: "t-shirt.jpg" },
  // Add more products here
]

function formatPrice(price) {
  return `$${price.toFixed(2)}`
}

document.addEventListener("DOMContentLoaded", () => {
  const productsGrid = document.getElementById("productsGrid")
  const filterButtons = document.querySelectorAll(".filter-btn")

  let currentCategory = "all"

  function renderProducts(category = "all") {
    const filteredProducts = category === "all" ? products : products.filter((p) => p.category === category)

    productsGrid.innerHTML = filteredProducts
      .map(
        (product) => `
      <a href="product-detail.html?id=${product.id}" class="product-card">
        <img src="${product.image}" alt="${product.name}" class="product-image">
        <div class="product-info">
          <span class="product-category">${product.categoryLabel}</span>
          <h3 class="product-name">${product.name}</h3>
          <p class="product-price">${formatPrice(product.price)}</p>
        </div>
      </a>
    `,
      )
      .join("")
  }

  filterButtons.forEach((btn) => {
    btn.addEventListener("click", () => {
      filterButtons.forEach((b) => b.classList.remove("active"))
      btn.classList.add("active")
      currentCategory = btn.dataset.category
      renderProducts(currentCategory)
    })
  })

  renderProducts()
})
