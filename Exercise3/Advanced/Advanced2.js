var Advanced2 = function () {

    // shader program
    var shaderProgram;

    // clear color
    var clearColor = [0.1, 0.1, 0.1];

    // gl buffer data
    var vbo;
    var ibo;
    var iboN;

    // time variable
    var time = 0;


    ////////////////////////////////
    ////////  webGL helper  ////////
    ////////////////////////////////
    function initGL(canvas) {
        // http://webglfundamentals.org/webgl/lessons/webgl-anti-patterns.html
        var gl;
        try {
            gl = canvas.getContext("experimental-webgl");
        } catch (e) { }
        if (!gl) alert("Could not initialise WebGL, sorry :-(\nTo enable WebGL support in your browser, go to about:config and skip the warning.\nSearch for webgl.disabled and set its value to false.");

        return gl;
    }

    // shader from java script block
    function getShader(gl, id) {
        var shaderScript = document.getElementById(id);
        if (!shaderScript) {
            return null;
        }

        var str = "";
        var k = shaderScript.firstChild;
        while (k) {
            if (k.nodeType == 3) {
                str += k.textContent;
            }
            k = k.nextSibling;
        }

        var shader;
        if (shaderScript.type == "--fragment") {
            shader = gl.createShader(gl.FRAGMENT_SHADER);
        }
        else if (shaderScript.type == "--vertex") {
            shader = gl.createShader(gl.VERTEX_SHADER);
        }
        else return null;

        gl.shaderSource(shader, str);
        gl.compileShader(shader);

        if (!gl.getShaderParameter(shader, gl.COMPILE_STATUS)) {
            alert(gl.getShaderInfoLog(shader));
            return null;
        }

        return shader;
    }

    function shaderProgram(gl, vertexShaderSourceID, fragmentShaderSourceID) {
        var vertexShader = getShader(gl, vertexShaderSourceID);
        var fragmentShader = getShader(gl, fragmentShaderSourceID);

        // create shader program
        var shaderProgram = gl.createProgram();

        // attach shaders
        gl.attachShader(shaderProgram, vertexShader);
        gl.attachShader(shaderProgram, fragmentShader);

        // link program
        gl.linkProgram(shaderProgram);
        if (!gl.getProgramParameter(shaderProgram, gl.LINK_STATUS)) {
            alert("Could not initialise shaders");
        }
        return shaderProgram;
    }

    //////////////////////////////
    ////////  init scene  ////////
    //////////////////////////////
    function initScene(gl) {

        //////////////////////////////////
        ////////  setup geometry  ////////
        //////////////////////////////////

        var vertices = [];

        var nodes = 80;
        var side_length = 100;

        for (var i = 0; i < nodes; i++) {
            for (var j = 0; j < nodes; j++) {
                var center = [i / (nodes - 1) * side_length, j / (nodes - 1) * side_length];
                vertices.push(center[1] - side_length * 0.5);
                vertices.push(0);
                vertices.push(center[0] - side_length * 0.5);
            }
        }

        var indices = [];

        // TODO 3.5a)	Fill the index buffer with the
        //              correct indices to form a plane
        //              of triangles.
        //              Look at the setup of the 'vertices'
        //              array to see which vertex has which
        //              index in the array!

        indices.push(32);
        indices.push(5981);
        indices.push(2347);

        indices.push(704);
        indices.push(3957);
        indices.push(4927);


        // create vertex buffer on the gpu
        vbo = gl.createBuffer();
        // bind buffer
        gl.bindBuffer(gl.ARRAY_BUFFER, vbo);
        // copy data from cpu to gpu memory
        gl.bufferData(gl.ARRAY_BUFFER, new Float32Array(vertices), gl.STATIC_DRAW);

        // create indices buffer on the gpu
        ibo = gl.createBuffer();
        // bind buffer
        gl.bindBuffer(gl.ELEMENT_ARRAY_BUFFER, ibo);
        // copy data from cpu to gpu memory
        gl.bufferData(gl.ELEMENT_ARRAY_BUFFER, new Uint16Array(indices), gl.STATIC_DRAW);

        iboN = indices.length;


        ///////////////////////////////
        ////////  setup shaders  //////
        ///////////////////////////////
        shaderProgram = shaderProgram(gl, "shader-vs-water", "shader-fs-water");
    }

    //////////////////////////////
    ////////  draw scene  ////////
    //////////////////////////////

    function drawScene(gl) {

        gl.useProgram(shaderProgram);
        // enable vertex attributes
        var attrVertexTerrain = gl.getAttribLocation(shaderProgram, "vVertex");
        gl.enableVertexAttribArray(attrVertexTerrain);

        // set shader uniforms
        var uniformLocMVP = gl.getUniformLocation(shaderProgram, "MVP");
        gl.uniformMatrix4fv(uniformLocMVP, false, [1.49, 0, 0, 0,
                                            0, 3.04, -0.59, -0.58,
                                            0, -0.87, -0.33, -0.32,
                                            0, 0, 77.66, 86.02]);

        time++;
        var uniformLocTime = gl.getUniformLocation(shaderProgram, "time");
        gl.uniform1f(uniformLocTime, time / 10.0);

        // bind buffers
        gl.bindBuffer(gl.ARRAY_BUFFER, vbo);
        gl.bindBuffer(gl.ELEMENT_ARRAY_BUFFER, ibo);
        var attrVertex = gl.getAttribLocation(shaderProgram, "vVertex");
        gl.vertexAttribPointer(attrVertex, 3, gl.FLOAT, false, 12, 0);

        // draw
        gl.drawElements(gl.TRIANGLES, iboN, gl.UNSIGNED_SHORT, 0);
    }

    /////////////////////////////
    ///////   Render Loop   /////
    /////////////////////////////
    var gl; // webGL context

    function renderLoop() {

        gl.clear(gl.COLOR_BUFFER_BIT);
        gl.clear(gl.DEPTH_BUFFER_BIT);

        // draw scene
        gl.viewport(0, 0, gl.drawingBufferWidth, gl.drawingBufferHeight);
        drawScene(gl);

        // wait
        window.setTimeout(renderLoop, 1000 / 60);

    }

    ///////////////////////////////////
    //////////   setup web gl   ///////
    ///////////////////////////////////

    var canvas;

    return {
        webGLStart: function (_canvas) {
            // store canvas
            canvas = _canvas;

            // initialize webGL canvas
            gl = new initGL(canvas);

            // init scene and shaders
            initScene(gl);

            // set clear color and enable depth test
            gl.clearColor(clearColor[0], clearColor[1], clearColor[2], 1.0);
            gl.enable(gl.DEPTH_TEST);

            // start render loop
            renderLoop();
        },

    }

}()
