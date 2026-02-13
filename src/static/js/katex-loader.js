// Dynamically load KaTeX and auto-render, then render math on the page.
(function(){
  function loadScript(src, cb){
    var s = document.createElement('script');
    s.src = src;
    s.defer = true;
    s.onload = cb;
    document.head.appendChild(s);
  }

  // add KaTeX stylesheet
  var l = document.createElement('link');
  l.rel = 'stylesheet';
  l.href = 'https://cdn.jsdelivr.net/npm/katex@0.16.8/dist/katex.min.css';
  document.head.appendChild(l);

  // load katex then auto-render and run it
  loadScript('https://cdn.jsdelivr.net/npm/katex@0.16.8/dist/katex.min.js', function(){
    loadScript('https://cdn.jsdelivr.net/npm/katex@0.16.8/dist/contrib/auto-render.min.js', function(){
      if (typeof renderMathInElement === 'function'){
        try{
          renderMathInElement(document.body, {
            // support $...$ and $$...$$ delimiters
            delimiters: [
              {left: '$$', right: '$$', display: true},
              {left: '$', right: '$', display: false}
            ],
            throwOnError: false
          });
        }catch(e){
          console.error('KaTeX render error:', e);
        }
      }
    });
  });
})();
