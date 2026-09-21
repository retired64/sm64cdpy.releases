// main.js — reveal de secciones al hacer scroll (IntersectionObserver)

(function () {
  const revealEls = document.querySelectorAll(".reveal");
  if (!("IntersectionObserver" in window) || revealEls.length === 0) {
    revealEls.forEach((el) => el.classList.add("is-visible"));
    return;
  }

  const observer = new IntersectionObserver(
    (entries) => {
      entries.forEach((entry) => {
        if (entry.isIntersecting) {
          entry.target.classList.add("is-visible");
          observer.unobserve(entry.target);
        }
      });
    },
    { threshold: 0.15 }
  );

  revealEls.forEach((el) => observer.observe(el));
})();
