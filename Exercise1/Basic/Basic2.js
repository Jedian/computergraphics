function drawArcCircle(canvas) {
    var context = canvas.getContext("2d");

    context.fillStyle = "#00FF00";

    context.beginPath();
    context.arc(60, 60, 50, 0, 2*Math.PI);
    context.closePath();
    context.fill();

    context.lineWidth = 10;
    context.strokeStyle = "#007F00"

    context.beginPath();
    context.arc(140, 140, 50, 0, 2*Math.PI);
    context.closePath();
    context.fill();
    context.stroke();
}
