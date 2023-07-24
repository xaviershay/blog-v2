// Thanks ChatGPT!

// Get all the figure elements on the page
const figureElements = document.getElementsByTagName('figure');

// Loop through each figure element
for (let i = 0; i < figureElements.length; i++) {
    const figure = figureElements[i];

    // Find all img elements within the figure
    const imgElements = figure.querySelectorAll('img');

    // Loop through each img element within the figure
    imgElements.forEach(img => {
        // Create a new anchor (link) element
        const link = document.createElement('a');

        // Set the href attribute of the link (you can modify this URL)
        link.href = img.src;

        // Append the img element to the link
        link.appendChild(img.cloneNode(true)); // Clone the img element to avoid moving it

        // Replace the img element with the link in the DOM
        img.parentNode.replaceChild(link, img);
    });

    figure.classList.add('linked');
}
