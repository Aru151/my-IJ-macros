
output = getDirectory("結果を出力する先を選択");
NileredShort = getDirectory("切り取り後のNile redの短波長側の画像が入ったファイル");
NileredLong = getDirectory("切り取り後のNile redの長波長側の画像が入ったファイル");

File.makeDirectory(output + "overlaid");

NileredShortList = getFileList(NileredShort);
NileredLongList = getFileList(NileredLong);
count = NileredShortList.length;


for(i = 0; i < count; i++){
	open(NileredShort + NileredShortList[i]);
	short = getImageID();
	ShortName = getTitle();
	getDimensions(width, hight, channels, slices, frames);
	newImage(emptyImage.avi, AVI, width, hight, frames);
	empty = getImageID();
	open(NileredLong + NileredLongList[i]);
	long = getImageID();
	LongName = getTitle();
	run("Merge Channels...", "c1=[LongName] c2=[ShortName] c3=[emptyImage.avi] create keep");
	save("AVI", "output + "overlaid" + "ShortName" + "/-overlaid.avi"");
	close("*");
	}
