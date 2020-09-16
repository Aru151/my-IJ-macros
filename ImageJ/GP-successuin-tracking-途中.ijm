//追跡とGP算出

output = getDirectory("結果を出力する先を選択");
inputShort = getDirectory("処理を行う短波長側のAVIファイルが入ったファイル");
inputLong = getDirectory("処理を行う長波長側のAVIファイルが入ったファイル");

inputShortList = getFileList(inputShort);
inputLongList = getFileList(inputLong);
count = inputShortList.length;

//G-factorの算出
open(); //補正されたDMSO-NileRedの短波長側の画像を開いてください
DMSOShort = getImageID();
open(); //補正されたDMSO-Nileredの長波長側の画像を開いてください
run("8-bit");
DMSOLong = getImageID();

selectImage(DMSOShort);
run("8-bit");
run("Z Project...","projection=[Average Intensity]");
DMSOIDShort = getImageID();
DMSOnameShort = getTitle();
selectImage(DMSOLong);
run("Z Project...","projection=[Average Intensity]");
DMSOIDLong = getImageID();
DMSOnameLong = getTitle();

gpref = 0.207; //梅林さん:-0.74 私:-0.34209(NR12S),-0.40555(CoA-PEG11-NR) Laurdan:0.207

imageCalculator("Add create 32-bit", DMSOIDShort, DMSOIDLong);
DMSOAdd = getImageID();
imageCalculator("Sub create 32-bit", DMSOIDShort, DMSOIDLong);
DMSOSub = getImageID();
imageCalculator("Divide create 32-bit", DMSOSub, DMSOAdd);
GPmes = getImageID();

imageCalculator("Copy create 32-bit",GPmes,GPmes);
run("Multiply...","value=gpref");
GPmesGPref = getImageID();
imageCalculator("Copy create 32-bit",GPmesGPref,GPmesGPref);
run("Add...","value=gpref");
warareru = getImageID();
imageCalculator("Subtract create 32-bit",warareru,GPmes);
run("Subtract...","value=1");
warareruu = getImageID();
imageCalculator("Add create 32-bit",GPmes,GPmesGPref);
run("Subtract...","value=1");
run("Subtract...","value=gpref");
waru = getImageID();
imageCalculator("Divide create 32-bit",warareruu,waru);
run("8-bit");
Gfactor = getImageID();

selectImage(Gfactor);
close("\\Others");

for(i = 0; i < count; i++){
	open(inputShort + inputShortList[i]);
	run("8-bit");
	short = getImageID();
	imageCalculator("Copy create 32-bit stack",short,short);
	shortT = getImageID();
	imageCalculator("Copy create 32-bit stack",shortT,shortT);
	shortY = getImageID();
	getDimensions(width, height, channels, slices, frames);
	shortName = getTitle();
	open(inputLong + inputLongList[i]);
	run("8-bit");
	long = getImageID();

	imageCalculator("Multiply create 32-bit stack", long, Gfactor);
	longB = getImageID();

	//maskを作成するためのADD
	for(p = 0; p < slices; p++){
		//GP動画を作成
		n = p+1;
		
		selectImage(longB);
		startFrame = n;
		stopFrame = n;
		run("Z Project...", "start=startFrame stop=stopFrame project=[Average Intensity]");
		longC = getImageID();
		
		selectImage(short);
		setSlice(n);
		selectImage(shortT);
		setSlice(n);

		imageCalculator("Add 32-bit", short, longC);
		imageCalculator("Substract 32-bit", shortT, longC);

		selectImage(longC);
		close();
		
		if(n == slices){
			imageCalculator("Divide 32-bit stack", shortT, short);
			GP = getImageID();
			imageCalculator("Add 32-bit stack", shortY, long);
			ADDforMASK = getImageID();
		}
	}

	for(p = 0; p < slices; p++){
		n = p+1;
		selectImage(ADDforMASK);
		setSlice(n);
		run("Find Maxima...", "prominence=1000 output=List");
		RCount = getValue("results.count");

		for(q = 0; q < RCount; q++){
			x = getResult("X", q);
			y = getResult("Y", q);
			xx = x-5;
			yy = y-5;
			drawOval(xx, yy, 10, 10);
			roiManager("Add");
		}
		
		newImage("maskImage", "8-bit black", width, height, 1);
		maskImage = getImageID();
		run("Subtract...", "value = 255");

		for(q = 0; q < RCount; q++){
			roiManager("Select",q);
			run("Add...", "value=1");
		}
		
		selectImage(GP);
		setSlice(n);
		imageCalculator("Divide", GP, maskImage);

		run("Clear Results");
		roiManager("Deleat");
	}
}
