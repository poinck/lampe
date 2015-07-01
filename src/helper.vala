public void hsv_to_rgb (double h, double s, double v, out double r, 
		out double g, out double b)
		requires (h >= 0 && h <= 360)
		requires (s >= 0 && s <= 1)
		requires (v >= 0 && v <= 1) {
    // by Robert Dyer, GPLv3 or later
    r = 0; 
    g = 0; 
    b = 0;

    if (s == 0) {
        r = v;
        g = v;
        b = v;
    } else {
        var secNum = (int) Math.floor(h / 60);
        // var secNum = (int) (h / 60);
        	// removed Math.floor()
        var fracSec = h / 60.0 - secNum;

        var p = v * (1 - s);
        var q = v * (1 - s * fracSec);
        var t = v * (1 - s * (1 - fracSec));
        
        switch (secNum) {
        case 0:
            r = v;
            g = t;
            b = p;
            break;
        case 1:
            r = q;
            g = v;
            b = p;
            break;
        case 2:
            r = p;
            g = v;
            b = t;
            break;
        case 3:
            r = p;
            g = q;
            b = v;
            break;
        case 4:
            r = t;
            g = p;
            b = v;
            break;
        case 5:
            r = v;
            g = p;
            b = q;
            break;
        }
    }
}

