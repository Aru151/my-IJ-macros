//共焦点で撮影したスペクトルからGP値を測定する
//20.06.25撮影用のmacro

//ver1.00
//GP画像の作成が可能に
//ver1.10
//ROIに関する機能を追加

thisIs = getString("この処理の名前を教えてください", "スペクトルGP");
open(); //DMSO-NileRedの画像を開いてください
DMSO = getImageID();
gpref = getNumber("GPrefの値を入力してください", -0.34209); //梅林さん:-0.74 私:-0.34209(NR12S),-0.40555(CoA-PEG11-NR)
output = getDirectory("結果を出力する先を選択");

NileredDir = getDirectory("共焦点顕微鏡で撮影したスペクトル画像のディレクトリを選択");
File.makeDirectory(output + "/GP");
File.makeDirectory(output + "/roi");

NileredList = getFileList(NileredDir);
count = NileredList.length;

RoipathList = newArray(count);
GPpathList = newArray(count);

//DMSO-NileredからGfactorを作成する
selectImage(DMSO);
run("8-bit");
run("Z Project...", "start=1 stop=1 project=[Average Intensity]");
DMSO1 = getImageID();

selectImage(DMSO);
run("Z Project...", "start=4 stop=4 project=[Average Intensity]");
DMSO4 = getImageID();

selectImage(DMSO);
run("Z Project...", "start=7 stop=7 project=[Average Intensity]");
DMSO7 = getImageID();

selectImage(DMSO);
run("Z Project...", "start=10 stop=10 project=[Average Intensity]");
DMSO10 = getImageID();

selectImage(DMSO);
run("Z Project...", "start=13 stop=13 project=[Average Intensity]");
DMSO13 = getImageID();


imageCalculator("Add create 32-bit", DMSO1, DMSO4);
DMSO14 = getImageID();

imageCalculator("Add create 32-bit", DMSO14, DMSO7);
DMSO147 = getImageID();

run("Divide...", "value=3");
DMSOShort = getImageID;

imageCalculator("Add create 32-bit", DMSO10, DMSO13);
DMSO1013 = getImageID();

run("Divide...", "value=2");
DMSOLong = getImageID();


imageCalculator("Add create 32-bit", DMSOLong, DMSOShort);
DMSOAdd = getImageID();

imageCalculator("Subtract create 32-bit", DMSOShort, DMSOLong);
DMSOSub = getImageID();

imageCalculator("Divade create 32-bit", DMSOSub, DMSOAdd);
GPmes = getImageID();


imageCalculator("Copy create", GPmes, GPmes);
copyGPmes = getImageID();
selectImage(copyGPmes);
run("Multiply...", "value=gpref");
GPmesGPref = getImageID();



run("Add...", "value=gpref");
GPrefADDGPmesGPref = getImageID();
imageCalculator("Subtract create 32-bit", GPrefADDGPmesGPref, GPmes);
GPrefADDGPmesGPrefSUBGPmes = getImageID();
run("Subtract...", "value=1");
GPrefADDGPmesGPrefSUBGPmesSUB1 = getImageID();

imageCalculator("Add create 32-bit", GPmesGPref, GPmes);
GPmesADDGPmesGPref = getImageID();
run("Subtract...", "value=gpref");
GPmesADDGPmesGPrefSUBGPref = getImageID();
run("Subtract...", "value=1");
GPmesADDGPmesGPrefSUBGPrefSUB1 = getImageID();

imageCalculator("Divide create 32-bit", GPrefADDGPmesGPrefSUBGPmesSUB1, GPmesADDGPmesGPrefSUBGPrefSUB1);
Gfactor = getImageID();

selectImage(Gfactor);
close("\\Others");


for(i = 0; i < count; i++) {
	open(NileredDir + NileredList[i]);
	name = getTitle();
	Nilered = getImageID();
	run("8-bit");
	run("Z Project...", "start=1 stop=1 project=[Average Intensity]");
	Nilered1 = getImageID();

	selectImage(Nilered);
	run("Z Project...", "start=4 stop=4 project=[Average Intensity]");
	Nilered4 = getImageID();

	selectImage(Nilered);
	run("Z Project...", "start=7 stop=7 project=[Average Intensity]");
	Nilered7 = getImageID();

	selectImage(Nilered);
	run("Z Project...", "start=10 stop=10 project=[Average Intensity]");
	Nilered10 = getImageID();

	selectImage(Nilered);
	run("Z Project...", "start=13 stop=13 project=[Average Intensity]");
	Nilered13 = getImageID();


	imageCalculator("Add create 32-bot", Nilered1, Nilered4);
	Nilered14 = getImageID();

	imageCalculator("Add create 32-bit", Nilered14, Nilered7);
	Nilered147 = getImageID();

	run("Divide...", "value=3");
	NileredShort = getImageID;

	imageCalculator("Add create 32-bit", Nilered10, Nilered13);
	Nilered1013 = getImageID();

	run("Divide...", "value=2");
	NileredLong = getImageID();


	//GP値の算出
	imageCalculator("Multiply create 32-bit", NileredLong, Gfactor);
	NileredLongGfactor = getImageID();

	imageCalculator("Add create 32-bit", NileredShort, NileredLongGfactor);
	NileredAdd = getImageID();

	imageCalculator("Subtract create 32-bit", NileredShort, NileredLongGfactor);
	NileredSub = getImageID();

	imageCalculator("Divide create 32-bit", NileredSub, NileredAdd);
	NileredGP = getImageID();

	//GP画像の保存
	saveAs("tiff", output + "/GP/" + name + "-GP.tif");
	GPpathList[i] = output + "/GP/" + name + "-GP.tif";


	//Add画像の二値化とROIの作成
	//ここでNileredAddを8bit化している
	selectImage(NileredAdd);
	run("8-bit");
	
	run("Threshold...");
	setAutoThreshold("Otsu dark"); //2値化処理
	run("Convert to Mask");
	run("Analyze Particles...","clear add");

	//ROImanagerに追加しROIを保存、保存先のディレクトリをROIpathListに保存
	roiManager("Save", output + "/roi/" + name + "-roi.zip");
	RoipathList[i] = output + "/roi/" + name + "-roi.zip";
	roiManager("delete");

	
	//Gfactor以外の画像の削除
	selectImage(Gfactor);
	close("\\Others");
}
close();

//roiとGP画像を呼び出し,GP値を測定し保存
for(i = 0; i < count; i++){
	open(GPpathList[i]);
	if(RoipathList[i] != "nothing"){
		roiManager("open", RoipathList[i]);
		roiManager("Show ALL");
		roiManager("Measure");
		roiManager("delete");
	}
	close();
}

saveAs("Results", output + thisIs + "-GP-Value.csv");
run("Clear Results");