saveDirectory = getDirectory("結果を保存する先を選択してください");

getDimensions(width, height, channels, slices, frames);
roiManagerCount = roiManager("count");
name = getTitle();

for(i = 0; i < roiManagerCount; i++) {
	
	for(n = 0; n < slices; n++) {
		o = n+1;
		roiManager("Select", i);
		setSlice(o);
		run("Measure");
	}
	
	saveAs("Results", saveDirectory + "-" + name + i + ".csv");
	run("Clear Results");
	
}