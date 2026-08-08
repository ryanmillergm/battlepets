var pool = argument0;

if(pool >= 8){
    var temp = ini_read_real("common", "total", 0);
	return ini_read_real("common", string(irandom(temp)), 0);
}




