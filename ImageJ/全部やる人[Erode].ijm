open(); //DMSO-Laurdanの重ね合わせ画像を開いてください
output = getDirectory("保存先を選んでください");
overlay = getDirectory("重ね合わせ画像の入ったファイルを選択してください");
File.makeDirectory(output + "/roi");
File.makeDirectory(output + "/GP");
overlaylist = getFileList(overlay);
count = overlaylist.length;
GPpathList = newArray(count);
RoipathList = newArray(count);

startframe = getNumber("重ね合わせを開始するフレームを入力",1);
stopframe = getNumber("重ね合わせを狩猟するフレームを入力",30);

//G-factorを求める
nameOfDMSO = getTitle();
run("Split Channels");
close();
run("Z Project...","projection=[Average Intensity]");
DMSOIDShort = getImageID();
DMSOnameShort = getTitle();
selectWindow(nameOfDMSO + " (red)");
run("Z Project...","projection=[Average Intensity]");
DMSOIDLong = getImageID();
DMSOnameLong = getTitle();

gpref = 0.207;

imageCalculator("Add create 32-bit", DMSOIDShort, DMSOIDLong);
DMSOAdd = getImageID();
imageCalculator("Sub create 32-bit", DMSOIDShort, DMSOIDLong);
DMSOSub = getImageID();
imageCalculator("Divide create 32-bit", DMSOSub, DMSOAdd);
GPmes = getImageID();

imageCalculator("Copy create 32-bit",GPmes,GPmes);
run("Multiply...","value=0.207");
GPmesGPref = getImageID();
imageCalculator("Copy create 32-bit",GPmesGPref,GPmesGPref);
run("Add...","value=0.207");
warareru = getImageID();
imageCalculator("Subtract create 32-bit",warareru,GPmes);
run("Subtract...","value=1");
warareruu = getImageID();
imageCalculator("Add create 32-bit",GPmes,GPmesGPref);
run("Subtract...","value=1.207");
waru = getImageID();
imageCalculator("Divide create 32-bit",warareruu,waru);
Gfactor = getImageID();

//main function
for(i = 0; i < count; i++){
	open(overlaylist[i]);
	nameOfoverlay = getTitle();
	run("Split Channels");
	run("Z Project...", "projection=[Average Intensity]"); //Stella650の8-bit 1F aviが作成された
	
	run("Threshold...");
	setAutoThreshold("Yen dark");
	run("Convert to Mask");
	run("Analyze Particles...","clear add");
	
	//particleを15以下まで縮小する
	HowMany = roiManager("count");
	for(u = HowMany - 1; u > -1; u--){
		roiManager("Select", u);
		Area = getResult("Area", u);
			while(Area > 15){
				run("Erode");
				roiManager("Delete");
				roiManager("Delete");
				run("Analyze Particles...","clear add");
				roiManager("Select", u);
				Area = getResult("Area", u);
			}
	}
		close();
		close();
		
		run("Z Project...", "start=startframe stop=stopframe project=[Average Intensity]");    //現在(green)が一番前にある
		ModeGreen = getValue("Mode");
		setMinAndMax(ModeGreen,255);
		run("Apply LUT");

		selectWindow(nameOfoverlay + " (red)");	//(red)を一番前に
		run("Z Project...", "start=startframe stop=stopframe project=[Average Intensity]");
		ModeRed = getValue("Mode");
		setMinAndMax(ModeRed,255);
		run("Apply LUT");

		imageCalculator("Multiply create 32-bit","AVG_" + nameOfoverlay + " (red)",Gfactor);
		imageCalculator("Add create 32-bit", "AVG_" + nameOfoverlay + " (green)","Result of AVG_" + nameOfoverlay + " (red)");
		add = getImageID();
		imageCalculator("Substract create 32-bit", "AVG_" + nameOfoverlay + " (green)","Result of AVG_" + nameOfoverlay + " (red)");
		sub = getImageID();
		imageCalculator("Divide create 32-bit",sub,add);
		GP = getImageID();
		saveAs("tiff", output + "/GP/" + nameOfoverlay + "-GP.tif");
		GPpathList[i] = output + "/GP/" + nameOfoverlay + "-GP.tif";

		selectImage(add);
		nameOfAdd = getTitle();
		run("Copy");
		run("Internal Clipboard");
		LaurdanCopy = getImageID();
		run("Flip Horizontally");
		run("Flip Vertically");
		roiManager("Deselect");
		roiManager("Show None");
		roiManager("Show ALL");
		roiManager("Measure");
		HowMany = roiManager("count");

		a = HowMany * 19 / 20;
		where = a - (a % 1);

		valueList = newArray(HowMany);

		for(n = 0; n < HowMany; n++){
			valueList[n] = getResult("Mean", n);
		}

		Array.sort(valueList);
		threshold = valueList[where];
		
		run("Clear Results");
		selectImage(add);
		roiManager("Show All");
		roiManager("measure");
		
		for(m = HowMany - 1; m > -1; m--){
			Value = getResult("Mean",m);
			if(Value < threshold){
				roiManager("Select", m);
				roiManager("Delete");
			}
		}
	selectImage(Gfactor);
	close("\\Others");
	roiManager("Save", output + "/roi/" + nameOfoverlay + "-roi.zip");
	RoipathList[i] = output + "/roi/" + nameOfoverlay + "-roi.zip";
	roiManager("delete");
	run("Clear Results");
}
close();

for(i = 0; i < count; i++){
	open(GPpathList[i]);
	roiManager("open", RoipathList[i]);
	roiManager("Show ALL");
	roiManager("Measure");
	roiManager("delete");
	close();
}

saveAs("Results",output + "GP-Value.csv");