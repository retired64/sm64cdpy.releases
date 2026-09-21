// nav.js — toggle del menú mobile (hamburguesa)

(function () {
  const toggle = document.getElementById("nav-toggle");
  const nav = document.getElementById("header-nav");
  if (!toggle || !nav) return;

  function closeNav() {
    nav.classList.remove("is-open");
    toggle.setAttribute("aria-expanded", "false");
  }

  toggle.addEventListener("click", () => {
    const isOpen = nav.classList.toggle("is-open");
    toggle.setAttribute("aria-expanded", String(isOpen));
  });

  // Cierra el menú al tocar un link (o el botón de GitHub) dentro del nav
  nav.querySelectorAll("a").forEach((link) => {
    link.addEventListener("click", closeNav);
  });

  // Cierra el menú si se toca fuera de él
  document.addEventListener("click", (event) => {
    if (!nav.contains(event.target) && !toggle.contains(event.target)) {
      closeNav();
    }
  });
})();
