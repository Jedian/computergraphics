var Basic1 = function () {
    var canvas;
    var alphas = [0.5, 0.5, 0.5, 0.5];

    function getImageInContainer(container) {
        var image = document.getElementById(container).children[0];
        var c = document.createElement('canvas');
        c.width = canvas.width;
        c.height = canvas.height;
        canvas.getContext('2d').clearRect(0, 0, c.width, c.height);
        canvas.getContext('2d').drawImage(image, 0, 0, c.width, c.height);
        var data = canvas.getContext('2d').getImageData(0, 0, c.width, c.height).data;
        return data;
    }

    function doAlphaBlending(index, images, alphas) {
        var blendCircles = [1, 1, 1];

        for (var i=0; i < images.length; ++i){
            if (images[i][index + 3]) 
            {
                blendCircles[0] = (blendCircles[0] * (1- alphas[i])) + ((images[i][index  ]/255.0) * alphas[i]);
                blendCircles[1] = (blendCircles[1] * (1- alphas[i])) + ((images[i][index+1]/255.0) * alphas[i]); 
                blendCircles[2] = (blendCircles[2] * (1- alphas[i])) + ((images[i][index+2]/255.0) * alphas[i]);
            }
        }

        return [blendCircles[0]*255,blendCircles[1]*255,blendCircles[2]*255];
    }

    function Render() {

        var context = canvas.getContext("2d");
        var img = context.createImageData(canvas.width, canvas.height);

        var images = [getImageInContainer("div0"),
                      getImageInContainer("div1"),
                      getImageInContainer("div2"),
                      getImageInContainer("div3")];

        // walk over the canvas image and set the blended color for each pixel
        for (var x = 0; x < canvas.width; x++) {
            for (var y = 0; y < canvas.height; y++) {
                // compute the linearized index for the image data array
                var i = 4 * (x + canvas.width * y);
                // compute the blended color using the index, the four circle images and the alpha values
                var color = doAlphaBlending(i, images, alphas);
                // set the color accordingly, alpha value is always 255
                img.data[i] = color[0];
                img.data[i + 1] = color[1];
                img.data[i + 2] = color[2];
                img.data[i + 3] = 255;
            }
        }

        context.putImageData(img, 0, 0);
    }

    return {
        start: function (_canvas) {
            canvas = _canvas;

            var sliders = document.getElementsByName("alpha");
            for (var i = 0; i < sliders.length; i++) {
                sliders[i].value = 0.5;
            }

            Render();
        },

        onChangeAlpha: function (index, value) {
            alphas[index] = value;
            Render();
        },

        allowDrop: function (ev) {
            ev.preventDefault();
        },

        drag: function (ev) {
            ev.dataTransfer.setData("src", ev.target.id);
            start_id = ev.target.id;
        },

        drop: function (ev) {
            ev.preventDefault();
            var src = document.getElementById(ev.dataTransfer.getData("src"));
            var srcParent = src.parentNode;
            var tgt = ev.currentTarget.firstElementChild;

            var a;
            if (srcParent.id == "div0") {
                a = 0;
            } else if (srcParent.id == "div1") {
                a = 1;
            } else if (srcParent.id == "div2") {
                a = 2;
            } else {
                a = 3;
            }

            var b;
            if (tgt.parentNode.id == "div0") {
                b = 0;
            } else if (tgt.parentNode.id == "div1") {
                b = 1;
            } else if (tgt.parentNode.id == "div2") {
                b = 2;
            } else {
                b = 3;
            }

            var sliders = document.getElementsByName("alpha");
            var tmp = alphas[a];
            alphas[a] = alphas[b];
            sliders[a].value = sliders[b].value;
            alphas[b] = tmp;
            sliders[b].value = tmp;

            ev.currentTarget.replaceChild(src, tgt);
            srcParent.appendChild(tgt);

            Render();
        }
    }
}()
