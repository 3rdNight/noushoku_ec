// Producers Page
const producers = [
  {
    name: "Producer 1",
    image: "image1.jpg",
    specialty: "Specialty 1",
    description: "Description 1",
    location: "Location 1",
  },
  {
    name: "Producer 2",
    image: "image2.jpg",
    specialty: "Specialty 2",
    description: "Description 2",
    location: "Location 2",
  },
  // Add more producers as needed
]

document.addEventListener("DOMContentLoaded", () => {
  const producersGrid = document.getElementById("producersGrid")

  producersGrid.innerHTML = producers
    .map(
      (producer) => `
    <div class="producer-card">
      <img src="${producer.image}" alt="${producer.name}" class="producer-image">
      <div class="producer-info">
        <h3 class="producer-name">${producer.name}</h3>
        <p class="producer-specialty">${producer.specialty}</p>
        <p>${producer.description}</p>
        <p style="margin-top: 1rem; color: var(--color-accent); font-size: 0.875rem;">
          📍 ${producer.location}
        </p>
      </div>
    </div>
  `,
    )
    .join("")
})
