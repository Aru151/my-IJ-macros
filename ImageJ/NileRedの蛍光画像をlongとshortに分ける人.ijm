//ROI LONG SHORTの順

output = getDirectory("処理後の画像はどこに保存しますか?");
NileRedShort = getDirectory("処理するNile redの短波長側の蛍光画像のみが入ったファイル");
NileRedLong = getDirectory("処理するNile redの長波長側の蛍光画像のみが入ったファイル");
NileRedShortList = getFileList(NileRedShort);
NileRedLongList = getFileList(NileRedLong);

ShortCount = NileRedShortList.length;
LongCount = NileRedLongList.length;

//アップデート予定:ShortCountとLongCountの値が異なる場合にerrorを出す

File.makeDirectory(output + "crop-NileRed");
File.makeDirectory(output + "crop-NileRed/" + "短波長側");
File.makeDirectory(output + "crop-NileRed/" + "長波長側");

for(i = 0; i < ShortCount; i++) {
	open(NileRedLong + NileRedLongList[i]);
	name = getTitle();
	roiManager("select",0);
	run("Crop");
	saveAs("avi",output + "crop-NileRed/" + "長波長側/" + name + "-Long.avi");
	close();
	open(NileRedShort + NileRedShortList[i]);
	roiManager("select",1);
	run("Crop");
	saveAs("avi",output + "crop-NileRed/" + "短波長側/" + name + "-Short.avi");
	close();
}