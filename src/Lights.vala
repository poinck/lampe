using Gtk;

public class Lights : ListBox {
	private int light_count = 0;
	
	private HueBridge bridge;

	// initialize a ListBox for lights
	public Lights(HueBridge bridge) {
		this.hexpand = true;
		this.vexpand = false;
		this.margin_start = 1;
		this.margin_end = 1;
		this.margin_top = 1;
		this.margin_bottom = 1;
		this.activate_on_single_click = false;
		this.selection_mode = SelectionMode.NONE;
		this.border_width = 1;
		
		this.bridge = bridge;
	}
	
	public void addLight(string name, int hue = 12000, int sat = 192, int bri = 32, bool lswitch = false) {
		light_count++;
		Light light = new Light(light_count, name, hue, sat, bri, lswitch, bridge);
			// FIXME number needs to be the actual light-id in the bridge
		
		this.insert(light, light_count);
	}
}
