---
layout: archive  # Use the same layout as your blog posts
title: "My CV"
permalink: /cv/
author_profile: true  # Include author profile if applicable
---

# My Curriculum Vitae

<div id="pdf-viewer" style="width: 100%; height: 800px; margin: 20px 0;"></div>

<script>
    document.addEventListener('DOMContentLoaded', function() {
        const url = 'https://ryan-a-anderson.github.io/files/Ryan_Anderson_CV_092024.pdf'; // Update with your PDF URL

        const pdfjsLib = window['pdfjs-dist/build/pdf'];
        pdfjsLib.GlobalWorkerOptions.workerSrc = 'https://cdnjs.cloudflare.com/ajax/libs/pdf.js/2.10.377/pdf.worker.min.js';

        const loadingTask = pdfjsLib.getDocument(url);
        loadingTask.promise.then(pdf => {
            console.log('PDF loaded');

            // Fetch the first page
            const pageNumber = 1;
            pdf.getPage(pageNumber).then(page => {
                console.log('Page loaded');

                const scale = 1.5;
                const viewport = page.getViewport({ scale: scale });

                // Prepare canvas using PDF page dimensions
                const canvas = document.createElement('canvas');
                const context = canvas.getContext('2d');
                canvas.height = viewport.height;
                canvas.width = viewport.width;

                // Append the canvas to the div
                document.getElementById('pdf-viewer').appendChild(canvas);

                // Render PDF page into canvas context
                const renderContext = {
                    canvasContext: context,
                    viewport: viewport
                };
                page.render(renderContext).promise.then(() => {
                    console.log('Page rendered');
                });
            });
        }, reason => {
            console.error(reason);
        });
    });
</script>
