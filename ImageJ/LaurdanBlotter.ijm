getDimensions(width, height, channels, slices, frames);
pnc = getNumber("Laurdan処理のProminenceの値を定めてください", 10);
run("Find Maxima...", "prominence=pnc output=List");

cntlist = getValue("results.count");

newImage("LaurdanBlot", "8-bit black", width, height, 1);

roiManager("Deselect");
run("Subtract...", "value = 255");

for(u = 0; u < cntlist; u++){
	x = getResult("X", u);
	y = getResult("Y", u);
	makeRectangle(x, y, 1, 1);
	roiManager("add");
	roiManager("select", u);
	run("Add...", "value=255");
}

run("Clear Results");
roiManager("Delete");
roiManager("Delete");