output = getDirectory("処理後の画像はどこに保存しますか?");
NileRedShort = getDirectory("処理するNile redの短波長側の蛍光画像のみが入ったファイル");
NileRedLong = getDirectory("処理するNile redの長波長側の蛍光画像のみが入ったファイル");
NileRedShortList = getFileList(NileRedShort);
NileRedLongList = getFileList(NileRedLong);

ShortCount = NileRedShortList.length;
LongCount = NileRedLongList.length;

for(i = 0; i < NileRedShortList.length; i++){
	open(NileRedLong + NileRedLongList[i]);
	long = getTitle();
	name = getTitle();
	open(NileRedShort + NileRedShortList[i]);
	short = getTitle();

	run("Merge Channels...", "c1=" + long + " c2=" + short + " create");
	selectWindow("Composite");
	rename(name);

	saveAs("AVI", output + name);
	close();
}

