function drawPixelwiseCircle(canvas) {
    var context = canvas.getContext("2d");
    var img = context.createImageData(200, 200);
		var center = [100, 100]; //x, y
		var rad = 50;

		for (var i = 0; i < 4 * 200 * 200; i += 4) {
				var vecx = (i/4)/200 - center[0];
				var vecy = (i/4)%200 - center[1];
				if(((vecx*vecx) + (vecy*vecy)) < rad**2){
					img.data[i] = 0; 				//R
					img.data[i + 1] = 255; 	//G
					img.data[i + 2] = 0; 		//B
					img.data[i + 3] = 255; 	//A
				}
		}

    context.putImageData(img, 0, 0);
}

function drawContourCircle(canvas) {
    var context = canvas.getContext("2d");
    var img = context.createImageData(200, 200);
		var center = [100, 100]; //x, y
		var rad = 50;
		var coverlap = 10;

		for (var i = 0; i < 4 * 200 * 200; i += 4) {
				var vecx = (i/4)/200 - center[0];
				var vecy = (i/4)%200 - center[1];
				if(((vecx*vecx) + (vecy*vecy)) < rad*rad){
					img.data[i] = 0; 				//R
					img.data[i + 1] = 255; 	//G
					img.data[i + 2] = 0; 		//B
					img.data[i + 3] = 255; 	//A
				}
				if(((vecx*vecx) + (vecy*vecy)) < (rad+(coverlap/2))**2 &&
            ((vecx*vecx) + (vecy*vecy)) > (rad-(coverlap/2))**2){
				    img.data[i] = 0;
            img.data[i + 1] = 127;
            img.data[i + 2] = 0;
            img.data[i + 3] = 255;  
				}
		}


    context.putImageData(img, 0, 0);
}

function drawSmoothCircle(canvas) {
    var context = canvas.getContext("2d");
    var img = context.createImageData(200, 200);
		var center = [100, 100]; //x, y
		var rad = 50;
		var coverlap = 10;

		for (var i = 0; i < 4 * 200 * 200; i += 4) {
				var vecx = Math.floor((i/4)/200) - center[0];
				var vecy = (i/4)%200 - center[1];
        //main circle
				if(((vecx*vecx) + (vecy*vecy)) < rad*rad){
					img.data[i] = 0; 				//R
					img.data[i + 1] = 255; 	//G
					img.data[i + 2] = 0; 		//B
					img.data[i + 3] = 255; 	//A
				}
        //contour + smoothing
				if(((vecx*vecx) + (vecy*vecy)) < (rad+(coverlap/2))**2 &&
            ((vecx*vecx) + (vecy*vecy)) > (rad-(coverlap/2))**2){
				    img.data[i] = 0;
            img.data[i + 1] = 127;
            img.data[i + 2] = 0;
            img.data[i + 3] = 255;  
				}
        var dist = Math.sqrt((vecx*vecx) + (vecy*vecy));
        if(Math.floor(dist) == (rad+(coverlap/2))){
            img.data[i] = 0;
            img.data[i + 1] = 127; 
            img.data[i + 2] = 0;
            img.data[i + 3] = 255 - ((dist-55))*255;
				} else if(Math.floor(dist) == (rad-(coverlap/2))){
            img.data[i] = 0;
            img.data[i + 1] = 127 + (1-(dist-45))*127;
            img.data[i + 2] = 0;
            img.data[i + 3] = 255;
        }
		}

    context.putImageData(img, 0, 0);
}
