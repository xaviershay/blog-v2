document.getElementById('book-filter').addEventListener('change', function() {
  var ratingElements = document.querySelectorAll('.book-summary');
  for (var i = 0; i < ratingElements.length; i++) {
    var rating = ratingElements[i].getAttribute('data-rating');
    if (rating < 4) {
      ratingElements[i].style.display = this.checked ? 'none' : 'block';
    }
  }
});
