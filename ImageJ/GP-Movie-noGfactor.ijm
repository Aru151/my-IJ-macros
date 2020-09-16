output = getDirectory("結果を出力する先を選択");
inputShort = getDirectory("処理を行う短波長側のAVIファイルが入ったファイル");
inputLong = getDirectory("処理を行う長波長側のAVIファイルが入ったファイル");
sift = getNumber("何フレームを積算して1枚のGP画像を作成しますか?", 5);

inputShortList = getFileList(inputShort);
inputLongList = getFileList(inputLong);
count = inputShortList.length;

//短波長と長波長の同一性の判定
open(inputShort + inputShortList[0]);
getDimensions(widthShort, heightShort, channelsShort, slicesShort, framesShort);
open(inputLong + inputLongList[0]);
getDimensions(widthLong, heightLong, channelsLong, slicesLong, framesLong);
if(widthShort != widthLong || heightShort != heightLong)exit("error:長波長と短波長の大きさが異なります");
if(slicesShort != slicesLong)exit("error:短波長と長波長の動画の長さが異なります");

//main function
for(i = 0; i < count; i++){
	open(inputShort + inputShortList[i]);
	short = getImageID();
	getDimensions(width, height, channels, slices, frames);
	shortName = getTitle();
	open(inputLong + inputLongList[i]);
	long = getImageID();

	stacks = slices - sift + 1;

	for(u = 0; u < stacks; u++){
		startFrame = u;
		stopFrame = u+4;
		selectImage(short);
		run("Z Project...", "start=startFrame stop=stopFrame project=[Average Intensity]");
		shortAVE = getImageID();
		selectImage(long);
		run("Z Project...", "start=startFrame stop=stopFrame project=[Average Intensity]");
		longAVE = getImageID();

		imageCalculator("Add create 32-bit", shortAVE, longAVE);
		run("8-bit");
		run("Threshold...");
		setAutoThreshold("Yen dark"); //2値化処理
		run("Convert to Mask");
		run("Analyze Particles...","clear add");
		run("Divide...", "value=255");
		mask = getImageID();

		imageCalculator("Add create 32-bit", shortAVE, longAVE);
		add = getImageID();
		imageCalculator("Substract create 32-bit", shortAVE, longAVE);
		sub = getImageID();

		imageCalculator("Divide create 32-bit", sub, add);
		GP = getImageID();
		imageCalculator("Divide create 32-bit", GP, mask);
		rename("stack-" + u);

		selectImage(shortAVE);
		close();
		selectImage(longAVE);
		close();
		selectImage(add);
		close();
		selectImage(sub);
		close();
		selectImage(GP);
		close();
		selectImage(mask);
		close();
	}

	run("Images to Stack", "name=GP-movie- + i title=stack- use");
	n = i+1;
	saveAs("tiff", output + "GP-movie-" + n + ".tif");
	close();
	selectImage(short);
	close();
	selectImage(long);
	close();
}