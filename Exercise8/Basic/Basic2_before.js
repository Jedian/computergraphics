mat4.perspective = function (out, fovy, near, far) {
    var f = 1.0 / Math.tan(fovy / 2),
    nf = 1 / (near - far);

    out[0] = f;
    out[1] = 0;
    out[2] = 0;
    out[3] = 0;

    out[4] = 0;
    out[5] = f;
    out[6] = 0;
    out[7] = 0;

    out[8] = 0;
    out[9] = 0;
    out[10] = (far + near) * nf;
    out[11] = -1;

    out[12] = 0;
    out[13] = 0;
    out[14] = (2 * far * near) * nf;
    out[15] = 0;

    return out;
};

function Camera3D() {
    this.eye = [0, 0, 3.6];
    this.fovy = 30.0 / 180.0 * Math.PI;
    this.near = 1;
    this.far = 100;
    this.lookAtPoint = [0, 0, 0];
    this.upVector = [0, 1, 0];
    this.direction = 0;

    // the cameraMatrix transforms from world space to camera space
    this.cameraMatrix = mat4.create();
    // projection matrix
    this.projectionMatrix = mat4.create();

    this.cameraMatrixInverse = mat4.create();

    // setup matrices
    this.update();
}

Camera3D.prototype.setMatrices = function (cameraMatrix, projectionMatrix) {
    this.cameraMatrix = cameraMatrix;
    this.projectionMatrix = projectionMatrix;
};

Camera3D.prototype.lookAt = function (point3D) {
    this.lookAtPoint = [point3D[0], point3D[1], point3D[2]];
    this.update();
};

Camera3D.prototype.setEye = function (eye3D) {
    this.eye[0] = eye3D[0];
    this.eye[1] = eye3D[1];
    this.eye[2] = eye3D[2];
    this.update();
};

Camera3D.prototype.promote = function (time) {
    var min = 3.6;
    var max = 50;
    var offset = 0.1;
    var factor = 3;
    var step = (this.eye[2] - min) / (max - min) * factor + offset;
    if (this.direction == 0) {
        if (this.eye[2] < max) {
            this.eye[2] += step;
        } else {
            this.direction = 1;
        }
    } else {
        if (this.eye[2] > min) {
            this.eye[2] -= step;
        } else {
            this.direction = 0;
        }
    }
    this.update();
};

Camera3D.prototype.move = function (dir) {
    var min = 3.6;
    var max = 50;
    var offset = 0.1;
    var factor = 3;
    var step = (this.eye[2] - min) / (max - min) * factor + offset;
    if (dir == 0) {
        if (this.eye[2] < max) {
            this.eye[2] += step;
        }
    } else if (dir == 1) {
        if (this.eye[2] > min) {
            this.eye[2] -= step;
        }
    }
    this.update();
};

Camera3D.prototype.update = function () {
    var e = vec3.fromValues(this.eye[0], this.eye[1], this.eye[2]);
    var g = vec3.fromValues(this.lookAtPoint[0] - this.eye[0],
                            this.lookAtPoint[1] - this.eye[1],
                            this.lookAtPoint[2] - this.eye[2]);
    var t = vec3.fromValues(this.upVector[0], this.upVector[1], this.upVector[2]);

    this.w = vec3.fromValues(-g[0], -g[1], -g[2]);
    vec3.normalize(this.w, this.w);

    this.u = vec3.create();
    vec3.cross(this.u, t, this.w);
    vec3.normalize(this.u, this.u);

    this.v = vec3.create();
    vec3.cross(this.v, this.w, this.u);

    var first_matrix = mat4.fromValues(this.u[0], this.v[0], this.w[0], 0,
                                        this.u[1], this.v[1], this.w[1], 0,
                                        this.u[2], this.v[2], this.w[2], 0,
                                        0, 0, 0, 1);
    var second_matrix = mat4.fromValues(1, 0, 0, 0,
                                        0, 1, 0, 0,
                                        0, 0, 1, 0,
                                        -e[0], -e[1], -e[2], 1);
    mat4.multiply(this.cameraMatrix, first_matrix, second_matrix);

    mat4.invert(this.cameraMatrixInverse, this.cameraMatrix);

    mat4.perspective(this.projectionMatrix, this.fovy, this.near, this.far);
};


var Basic2_before = function () {

    // shader programs
    var shaderProgramPlane;

    // clear color
    var clearColor = [0.1, 0.1, 0.5];

    // gl buffer data
    var vboPlane;
    var iboPlane;
    var iboNPlane;

    var motion = false;

    // camera
    var camera = new Camera3D();

    ////////////////////////////////
    ////////  webGL helper  ////////
    ////////////////////////////////
    function initGL(canvas) {
        console.log("init webGL");
        // http://webglfundamentals.org/webgl/lessons/webgl-anti-patterns.html
        var gl;
        try {
            gl = canvas.getContext("webgl2");
        } catch (e) { }
        if (!gl) alert("Could not initialise WebGL, sorry :-(");
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

        //////////////////////////////////////////
        ////////  set up geometry - plane ////////
        //////////////////////////////////////////

        var vPlane = [  -1, -1, 0, 0, 0,
                        -1, 1, 0, 0, 1,
                        1, -1, 0, 1, 0,
                        1, 1, 0, 1, 1];
        var iPlane = [0, 1, 2, 2, 3, 1];

        // create vertex buffer on the gpu
        vboPlane = gl.createBuffer();
        // bind buffer
        gl.bindBuffer(gl.ARRAY_BUFFER, vboPlane);
        // copy data from cpu to gpu memory
        gl.bufferData(gl.ARRAY_BUFFER, new Float32Array(vPlane), gl.STATIC_DRAW);

        // create index buffer on the gpu
        iboPlane = gl.createBuffer();
        // bind buffer
        gl.bindBuffer(gl.ELEMENT_ARRAY_BUFFER, iboPlane);
        // copy data from cpu to gpu memory
        gl.bufferData(gl.ELEMENT_ARRAY_BUFFER, new Uint16Array(iPlane), gl.STATIC_DRAW);

        iboNPlane = iPlane.length;

        ////////////////////////////////
        ////////  set up shaders  //////
        ////////////////////////////////
        shaderProgramPlane = shaderProgram(gl, "shader-vs-noise", "shader-fs-noise");

    }

    //////////////////////////////
    ////////  draw scene  ////////
    //////////////////////////////

    function drawScene(gl, time) {

        var modelMatrixPlane = mat4.create();

        if (motion) {
            camera.promote(time);
        }

        // draw the plane
        drawPlane(gl, modelMatrixPlane);
    }

    function drawPlane(gl, modelMatrix) {

        var normalMatrix = mat4.create();
        mat4.transpose(normalMatrix, modelMatrix);

        gl.useProgram(shaderProgramPlane);
        // enable vertex attributes
        var attrVertexPlane = gl.getAttribLocation(shaderProgramPlane, "vVertex");
        gl.enableVertexAttribArray(attrVertexPlane);
        var attrTexCoordPlane = gl.getAttribLocation(shaderProgramPlane, "vTexCoord");
        gl.enableVertexAttribArray(attrTexCoordPlane);

        // set shader uniforms
        var uniformLocModelMatrix = gl.getUniformLocation(shaderProgramPlane, "modelMatrix");
        gl.uniformMatrix4fv(uniformLocModelMatrix, false, modelMatrix);
        var uniformLocCameraMatrix = gl.getUniformLocation(shaderProgramPlane, "cameraMatrix");
        gl.uniformMatrix4fv(uniformLocCameraMatrix, false, camera.cameraMatrix);
        var uniformLocProjectionMatrix = gl.getUniformLocation(shaderProgramPlane, "projectionMatrix");
        gl.uniformMatrix4fv(uniformLocProjectionMatrix, false, camera.projectionMatrix);

        // bind buffers
        gl.bindBuffer(gl.ARRAY_BUFFER, vboPlane);
        gl.bindBuffer(gl.ELEMENT_ARRAY_BUFFER, iboPlane);
        var attrVertex = gl.getAttribLocation(shaderProgramPlane, "vVertex");
        gl.vertexAttribPointer(attrVertex, 3, gl.FLOAT, false, 20, 0);
        var attrTexCoord = gl.getAttribLocation(shaderProgramPlane, "vTexCoord");
        gl.vertexAttribPointer(attrTexCoord, 2, gl.FLOAT, false, 20, 12);


        // draw
        gl.drawElements(gl.TRIANGLES, iboNPlane, gl.UNSIGNED_SHORT, 0);
    }

    /////////////////////////////
    ///////   Render Loop   /////
    /////////////////////////////
    var gl; // webGL context
    var t = 0; // time counter

    function renderLoop() {

        gl.clear(gl.COLOR_BUFFER_BIT);
        gl.clear(gl.DEPTH_BUFFER_BIT);

        // draw scene
        gl.viewport(0, 0, gl.drawingBufferWidth, gl.drawingBufferHeight);
        drawScene(gl, t);

        // wait
        window.setTimeout(renderLoop, 1000 / 60);

        // update time
        t += 1000 / 60;
    }

    ///////////////////////////////////
    //////////   setup web gl   ///////
    ///////////////////////////////////

    var canvas;

    return {
        webGLStart: function (_canvas) { 

            // store canvas
            canvas = _canvas;

            // add event listener
            document.addEventListener('keypress', onKeyPress, false);

            document.getElementById("motion").checked = false;

            // initialize webGL canvas
            gl = new initGL(canvas);

            var ext = gl.getExtension('GL_OES_standard_derivatives');
            console.log(ext);

            // init scene and shaders
            initScene(gl);

            // set clear color and enable depth test
            gl.clearColor(clearColor[0], clearColor[1], clearColor[2], 1.0);
            gl.enable(gl.DEPTH_TEST);

            // start render loop
            renderLoop();
        },

        onChangeMotion: function () {
            motion = !motion;
        }

    }

    /////////////////////////////////////
    //////////   event listener   ///////
    /////////////////////////////////////

    function onKeyPress(e) {
        if (!motion) {
            if (e.charCode == 119) { // W
                camera.move(0);
            } else if (e.charCode == 115) { // S
                camera.move(1);
            }
        }
    }
}()
