  ini_open("blastoise_banner.ini");

var i = 0;

//pokemon
ini_write_real("featured", string(i++), 2); //blastoise
ini_write_real("featured", string(i++), 3); //chansey
ini_write_real("featured", string(i++), 6); //bailly
ini_write_real("featured", string(i++), 13); //poliwrath
ini_write_real("featured", string(i++), 18); //dragonaire
//total
ini_write_real("featured", "total", i-1);

i = 0;

//pokemon
ini_write_real("unfeatured", string(i++), 5); //clefairy
ini_write_real("unfeatured", string(i++), 9); //axle
ini_write_real("unfeatured", string(i++), 14); //luna
ini_write_real("unfeatured", string(i++), 16); //raichu
ini_write_real("unfeatured", string(i++), 17); //beedrill
//total
ini_write_real("unfeatured", "total", i-1);

i = 0

//pokemon
ini_write_real("uncommon", string(i++), 23); //jynx
ini_write_real("uncommon", string(i++), 25); //seel
ini_write_real("uncommon", string(i++), 26); //magmar
ini_write_real("uncommon", string(i++), 27); //parygon
ini_write_real("uncommon", string(i++), 28); //dewgong

ini_write_real("uncommon", "total", i-1);

ini_close();




