"use strict";

///////////////////////////
//// global variables  ////
///////////////////////////

var polygon = new Polygon([new Point(100, 10),
                            new Point(120, 72),
                            new Point(186, 72),
                            new Point(136, 112),
                            new Point(153, 173),
                            new Point(100, 138),
                            new Point(47, 173),
                            new Point(64, 112),
                            new Point(14, 72),
                            new Point(80, 72)],
                            10, new Color(255, 127, 0));

/////////////////////
//// edge table  ////
/////////////////////

// edge table entry
function EdgeTableEntry(edge) {
    var dx = 0;
    var dy = 0;
    if (edge.startPoint.y < edge.endPoint.y) {
        this.y_lower = edge.startPoint.y;
        this.x_lower = edge.startPoint.x;
        this.y_upper = edge.endPoint.y;
        dx = edge.endPoint.x - edge.startPoint.x;
        dy = edge.endPoint.y - edge.startPoint.y;
    }
    else {
        this.y_lower = edge.endPoint.y;
        this.x_lower = edge.endPoint.x;
        this.y_upper = edge.startPoint.y;
        dx = edge.startPoint.x - edge.endPoint.x;
        dy = edge.startPoint.y - edge.endPoint.y;
    }

    this.invSlope = dx / dy;
}

function compareEdgeTableEntries(a, b) {
    return a.y_lower - b.y_lower;
}

function printEdgeTableEntry(e) {
    console.log("ET: " + e.y_lower + " " + e.x_lower + " " + e.y_upper + " " + e.invSlope);
}

// edge table
function EdgeTable(polygon) {
    this.entries = new Array(polygon.nEdges);
    this.nEntries = polygon.nEdges;

    console.log(polygon.edges);
    for (var i = 0; i < polygon.nEdges; i++) {
        this.entries[i] = new EdgeTableEntry(polygon.edges[i]);
    }
    this.entries.sort(compareEdgeTableEntries);

    for (var i = 0; i < polygon.nEdges; i++) {
        printEdgeTableEntry(this.entries[i]);
    }
}

////////////////////////////
//// active edge table  ////
////////////////////////////

// active edge table entry
function ActiveEdgeTableEntry(edgeTableEntry) {
    this.x_intersect = edgeTableEntry.x_lower;
    this.y_upper = edgeTableEntry.y_upper;
    this.invSlope = edgeTableEntry.invSlope;
}

function compareActiveEdgeTableEntries(a, b) {
    return a.x_intersect - b.x_intersect;
}

// active edge table
function ActiveEdgeTable() {
    this.entries = new Array();
    this.nEntries = 0;
}


/////////////////////////////
//// scanline algorithm  ////
/////////////////////////////

function scanline(image, polygon) {

    var edgeTable = new EdgeTable(polygon);
    var activeEdgeTable = new ActiveEdgeTable();

    for (var y_scanline = 0; y_scanline < image.height; y_scanline++) {

        var newAET = new ActiveEdgeTable();
        for(var i = 0; i < activeEdgeTable.nEntries; i++){
            entry = activeEdgeTable.entries[i];
            if(y_scanline < entry.y_upper){ //copy the still active edges
                newAET.entries.push(activeEdgeTable.entries[i]);
                newAET.nEntries++;
            }
        }
        activeEdgeTable = newAET;

        for(var i = 0; i < edgeTable.nEntries; i++){
            var entry = edgeTable.entries[i];
            if(entry.y_lower == y_scanline && entry.y_upper != y_scanline){
                activeEdgeTable.entries.push(new ActiveEdgeTableEntry
                    (edgeTable.entries[i]));
                activeEdgeTable.nEntries++;
            }
        }

        activeEdgeTable.entries.sort(compareActiveEdgeTableEntries);

        for(var i = 0; i < activeEdgeTable.nEntries; i+=2){
            var entry1 = activeEdgeTable.entries[i];
            var entry2 = activeEdgeTable.entries[i+1];
            console.log(entry1.x_intersect);
            console.log('lower = ' + entry1.x_lower);
            for(var x = Math.floor(entry1.x_intersect); x <= entry2.x_intersect; x++){
                setPixel(image, new Point(x, y_scanline), polygon.color);
            }
        }

        for(var i = 0; i < activeEdgeTable.nEntries; i++){
            activeEdgeTable.entries[i].x_intersect += activeEdgeTable.entries[i].invSlope;
        }
    }
}


//////////////////////////
//// render function  ////
//////////////////////////

function RenderCanvas3() {
    // get canvas handle
    var context = document.getElementById("canvas3").getContext("2d");
    var canvas = context.createImageData(200, 200);

    // clear canvas
    clearImage(canvas, new Color(255, 255, 255));

    // draw line
    scanline(canvas, polygon);

    // show image
    context.putImageData(canvas, 0, 0);
}

function setupScanline(canvas) {
    // execute rendering
    RenderCanvas3();
}
