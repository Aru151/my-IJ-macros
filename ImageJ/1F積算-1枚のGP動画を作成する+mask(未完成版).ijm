//画像(RGB, RGの二次元要素を持つ画像[Nileredの蛍光動画など])を引数として受け取り
////画像はDMSOの短波長側、DMSOの長波長側、処理を行う重ね合わせ、の順に受け取ります。////
//各フレームでGP画像を作製して一通りのGP動画を作成します。

prominence=getNumber("prominenceの値を入力してください", 100);

//Gfactor画像を作製する
open(); //補正されたDMSO-NileRedの短波長側の画像を開いてください
DMSOShort = getImageID();
open(); //補正されたDMSO-Nileredの長波長側の画像を開いてください
DMSOLong = getImageID();

selectImage(DMSOShort);
run("Z Project...","projection=[Average Intensity]");
DMSOIDShort = getImageID();
DMSOnameShort = getTitle();
selectImage(DMSOLong);
run("Z Project...","projection=[Average Intensity]");
DMSOIDLong = getImageID();
DMSOnameLong = getTitle();

gpref = -0.1436; //梅林さん:-0.74 私:-0.34209(NR12S),-0.40555(CoA-PEG11-NR)

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
Gfactor = getImageID();
selectImage(Gfactor);
close("\\Others");


////main function////
open();
getDimensions(width, height, channels, slices, frames);
name = getTitle();

run("Split Channels");
selectWindow(name + " (blue)");
close();

selectWindow(name + " (green)");
shortStack = getImageID();

selectWindow(name + " (red)");
longStack = getImageID();


for(i = 0; i < slices; i++) {
	n = i+1;
	selectImage(shortStack);
	run("Z Project...", "start=n stop=n projection=[Average Intensity]");
	short = getImageID();

	selectImage(longStack);
	run("Z Project...", "start=n stop=n projection=[Average Intensity]");
	run("32-bit");
	preLong = getImageID();
	imageCalculator("Multiply create 32-bit", preLong, Gfactor); 
	long = getImageID();

	imageCalculator("Add create 32-bit", short, long);
	add = getImageID();

	imageCalculator("Subtract create 32-bit", short, long);
	sub = getImageID();

	imageCalculator("Divide create 32-bit", sub, add);
	GPimage = getTitle();

	//maskを作製する
	selectImage(add);
	run("Find Maxima...", "prominence=prominence output=List");
	resultCount = getValue("results.count");

	newImage("mask", "8-bit black", width, height, 1);
	mask = getImageID();
	
	for(o = 0; o < resultCount; o++) {
		xValue = getResult("X", o, "Results");
		yValue = getResult("Y", o, "Results");

		makeOval(xValue, yValue, 9, 9);
		roiManager("add");
	}

	selectImage(mask);
	for(o = 0; o < resultCount; o++) {
		roiManager("Select", o);
		run("Add...", "value=255");
	}

	run("Subtract...", "value=254");
	imageCalculator("Multiply create 32-bit", GPimage, mask);
	rename("stack-" + n);

	selectImage(short);
	close();
	selectImage(preLong);
	close();
	selectImage(long);
	close();
	selectImage(add);
	close();
	selectImage(sub);
	close();
	selectImage(GPimage);
	close();
	selectImage(mask);
	close();

	roiManager("Deselect");
	roiManager("Delete");

	run("Clear Results");
}

run("Images to Stack", "name=GP-movie +  title=stack- use");
close("\\Others");
