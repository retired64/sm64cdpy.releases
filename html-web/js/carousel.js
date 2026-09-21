// carousel.js — controla el track de slides. Data-driven por el
// número de .carousel__slide presentes en el HTML, así que
// agregar una 7ª captura es solo agregar un slide más al markup.

(function () {
  const root = document.querySelector("[data-carousel]");
  if (!root) return;

  const track = root.querySelector(".carousel__track");
  const slides = Array.from(root.querySelectorAll(".carousel__slide"));
  const dotsWrap = root.querySelector(".carousel__dots");
  const prevBtn = root.querySelector("[data-carousel-prev]");
  const nextBtn = root.querySelector("[data-carousel-next]");

  let index = 0;

  slides.forEach((_, i) => {
    const dot = document.createElement("button");
    dot.className = "carousel__dot" + (i === 0 ? " is-active" : "");
    dot.setAttribute("aria-label", "Ir a la captura " + (i + 1));
    dot.addEventListener("click", () => goTo(i));
    dotsWrap.appendChild(dot);
  });

  const dots = Array.from(dotsWrap.children);

  function goTo(i) {
    index = (i + slides.length) % slides.length;
    track.style.transform = "translateX(-" + index * 100 + "%)";
    dots.forEach((d, di) => d.classList.toggle("is-active", di === index));
  }

  prevBtn.addEventListener("click", () => goTo(index - 1));
  nextBtn.addEventListener("click", () => goTo(index + 1));

  root.setAttribute("tabindex", "0");
  root.addEventListener("keydown", (e) => {
    if (e.key === "ArrowLeft") goTo(index - 1);
    if (e.key === "ArrowRight") goTo(index + 1);
  });
})();
