getDimensions(width, height, channels, slices, frames);
newImage("LandomBlot", "8-bit black", width, height, 1);

run("Subtract...", "value = 255");

for(u = 0; u < 500; u++){
	x = random;
	xx = x * width - (x * width) % 1;
	y = random;
	yy = y * height - (y * height) % 1;
	makeRectangle(xx-1, yy-1, 3, 3);
	roiManager("add");
	roiManager("select", u);
	run("Add...", "value=255");
		}

roiManager("Delete");
roiManager("Delete");

LandomBlot = getImageID();
selectImage(LandomBlot);
run("Clear Results");

for(u = 0; u < 500; u++){
	x = random;
	xx = x * width - (x * width) % 1;
	y = random;
	yy = y * height -(y * height) % 1;
	makeRectangle(xx-1, yy-1, 3, 3);
	roiManager("add");
}

roiManager("Measure");

q = 0;
for(u = 499; u > -1; u--){
	mean = getResult("Mean", u);
	if(mean==0){
		 	roiManager("select",u);
		 	roiManager("Delete");
		 	q += 1;
		 }
}
