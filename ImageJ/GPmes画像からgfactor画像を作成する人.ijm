//Gfactor画像のimgeIDを所得する
gpmes = getImageID();
name = getTitle();
gpref = 0.207;

imageCalculator("Copy create 32-bit",gpmes,gpmes);
run("Multiply...","value=0.207");
gpmesgpref = getImageID();
imageCalculator("Copy create 32-bit",gpmesgpref,gpmesgpref);
run("Add...","value=0.207");
warareru = getImageID();
imageCalculator("Subtract create 32-bit",warareru,gpmes);
run("Subtract...","value=1");
warareruu = getImageID();
imageCalculator("Add create 32-bit",gpmes,gpmesgpref);
run("Subtract...","value=1.207");
waru = getImageID();
imageCalculator("Divide create 32-bit",warareruu,waru);
gfactor = getImageID();
close("\\Others");