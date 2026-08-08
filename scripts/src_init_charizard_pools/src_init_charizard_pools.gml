ini_open("charzard_banner.ini");

var i = 0;

//pokemon
ini_write_real("featured", string(i++), 4); //charizard
ini_write_real("featured", string(i++), 1); //alakazam
ini_write_real("featured", string(i++), 12); //jack
ini_write_real("featured", string(i++), 10); //mewtwo
ini_write_real("featured", string(i++), 22); //reeses
//total
ini_write_real("featured", "total", i-1);

ini_close();

















