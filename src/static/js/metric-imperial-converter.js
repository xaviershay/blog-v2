if (window.location.search.indexOf("imperial=true") >= 0) {
  const spans = document.querySelectorAll('[data-alt]');

  for (const span of spans) {
    span.textContent = span.getAttribute('data-alt');
  }

  const links = document.querySelectorAll('[data-alt-href]');

  for (const link of links) {
    link.setAttribute("href", link.getAttribute("data-alt-href"));
  }
}
