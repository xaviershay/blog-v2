var bookFilter = document.getElementById('book-filter');
var genre = null;

function filterElements() {
  var elements = document.querySelectorAll('.book-summary');
  elements.forEach(element => {
    matchingGenre = !genre || element.classList.contains(genre);
    matchingRating = !bookFilter.checked || element.getAttribute('data-rating') >= 4
    element.style.display = matchingGenre && matchingRating ? 'block' : 'none';
  });
}

bookFilter.addEventListener('change', function() {
  filterElements();
});

var genreFilters = document.querySelectorAll('.genre-filter')
genreFilters.forEach(link => {
  link.addEventListener('click', function(event) {
    event.preventDefault();
    var newGenre = this.getAttribute('data-genre')
    if (newGenre == genre) {
      genre = null;
    } else {
      genre = newGenre;
    }
    filterElements();
  });
});
