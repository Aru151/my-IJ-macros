saveDirectory = getDirectory("結果を保存する先を選択してください");
openDirectory = getDirectory("処理するAVIファイルの入ったファイルを選択してください");

openList = getFileList(openDirectory);
openListCount = openList.length;

for(p = 0; p < openListCount; p++) {
	open(openDirectory + openList[p]);
	name = getTitle();

getDimensions(width, height, channels, slices, frames);

for(i = 0; i < slices; i++) {
	n = i+1;
	setSlice(n);
	run("Measure");
}


/* 

roiを導入しようとした名残

maxMean = 0;
maxSlice = 0;

for(i = 0; i < slices; i++) {
	mean = getResult("Mean", i);
	if(maxMean < mean) {
		maxMean = mean;
		maxSlice = i+1;
	}
}

setSlice(maxSlice);
run("Copy");
run("Internal Clipboard");
run("8-bit");
*/

saveAs("Results", saveDirectory + name + ".csv");
close();
run("Clear Results");
}