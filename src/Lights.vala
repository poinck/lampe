using Gtk;
using Json;

public class Lights : ListBox {
	private int light_count = 0;
	public static const int MAX_LIGHTS = 50;
	
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
	
	public void refreshLights() {
		this.light_count = 0;
		
		string lightStates = this.bridge.getStates();
		
		Json.Parser parser = new Json.Parser();
		try {
			parser.load_from_data(lightStates);
			Json.Node node = parser.get_root();
			
			Json.Object obj = node.get_object();
			foreach (string light in obj.get_members()) {
				
				// debug
				stdout.printf("[Lights.addLight] light = '%s'\n", light);
			}
			
//			for (int light = 1; light <= MAX_LIGHTS; light++) {
//				
//			}
		}
		catch (Error e) {
			stdout.printf ("[Lights.addLight] unable to parse 'lightStates': %s\n", e.message);
		}
	}
}
