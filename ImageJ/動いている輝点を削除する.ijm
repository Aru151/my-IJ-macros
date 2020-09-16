//連続する2Fで連続して存在しない輝点を削除する

prominence = getNumber("Find Maximaで使用する, prominenceの値を入力してください", 10);
judgeDistance = getNumber("フレーム間で何pix移動していれば別の輝点とみなしますか?", 5);
squaredJudgeDistance = judgeDistance*judgeDistance;
output = getDirectory("結果を出力する場所を選択してください");

getDimensions(width, height, channels, slices, frames);
sliceRoop = slices-1;

//開かれているAVIの総フレーム数-１回繰り返す処理
//各フレームとその次のフレームを比較します
for(i = 0; i < slicesRoop; i++) {
	//対象のフレームの次のフレーム内の輝点座標をResultsリストにアップします。
	//Resultsの名前をnextに変更します。
	j = i+1;
	setSlice(j);
	run("Find Maxima...", "prominence=" + prominence + " output=List");
	nextPointCount = getValue("results.count"); 
	IJ.renameResults("next");

	//対象のフレーム内の輝点座標をResultsリストにアップします。
	setSlice(i);
	run("Find Maxima...", "prominence=" + prominence + " output=List");
	resultsPointCount = getValue("results.count");

	//Resultsの輝点座標を取り出します。
	for(n = resultsPointCount; n > 0; n--) {
		deleteSwitch = true;
		o = n-1;
		firstX = getResult("X", o, "Results");
		firstY = getResult("Y", o, "Results");

		//nextの輝点座標を取り出します。
		//nextの座標とResultの座標に基底範囲以内の点があれば削除せずに残す。
		for(q = nextPointCount; q > 0; q--) {
			r = q-1;
			X = getResult("X", r, "next");
			Y = getResult("Y", r, "next");
			squaredDistance = (firstX-X)*(firstX-X)-(firstY-Y)*(firstY-Y);
			if(squaredJudgeDistance > squaredDistance) {
				deleteSwitch = false;
				break;
			}
		}

		if(deleteSwitch) Table.deleteRows(o, o, "Results");
	}
    saveAs("Results", output + "result-" + j + ".csv");
    
	close("next");
	close("Results");
}