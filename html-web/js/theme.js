// theme.js — alterna data-theme en <html>. Se parte del tema del
// sistema (prefers-color-scheme) y luego el botón alterna en
// memoria durante la sesión. Si despliegas este sitio fuera de
// esta vista previa, puedes sumar localStorage aquí para
// recordar la elección entre visitas.

(function () {
  const root = document.documentElement;
  const toggleBtn = document.getElementById("theme-toggle");
  const iconSun = "☀️";
  const iconMoon = "🌙";

  function currentTheme() {
    return root.getAttribute("data-theme") || "dark";
  }

  function applyTheme(theme) {
    root.setAttribute("data-theme", theme);
    if (toggleBtn) {
      toggleBtn.textContent = theme === "dark" ? iconMoon : iconSun;
      toggleBtn.setAttribute(
        "aria-label",
        theme === "dark" ? "Cambiar a modo claro" : "Cambiar a modo oscuro"
      );
    }
  }

  const prefersLight =
    window.matchMedia &&
    window.matchMedia("(prefers-color-scheme: light)").matches;

  applyTheme(prefersLight ? "light" : "dark");

  if (toggleBtn) {
    toggleBtn.addEventListener("click", function () {
      applyTheme(currentTheme() === "dark" ? "light" : "dark");
    });
  }
})();
