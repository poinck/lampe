using Gtk;
using Json;

public class Lights : ListBox {
	public static const int MAX_LIGHTS = 50;

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
	
	public void addLight(string name, int light_id = 1, int64 hue = 12000, int64 sat = 192, int64 bri = 32, bool lswitch = false) {
		this.light_count++;
		Light light = new Light(light_id, name, hue, sat, bri, lswitch, bridge);
		
		// debug
		stdout.printf("[Lights.addLight] light_count = '%i'\n", light_count);
		
		this.insert(light, light_count);
		this.show_all();
	}
	
	public void deleteLights() {
		// callback: remove() for every child of this (Lights)
		this.foreach((light) => {
			remove(light);
		});
		
		this.light_count = 0;
	}
	
	public void refreshLights() {
		deleteLights();
		
		string name = "";
		int light_id = 0;
		int64 hue = 12000;
		int64 sat = 192;
		int64 bri = 32;
		bool lswitch = false;
		
		string lightStates = this.bridge.getStates();
		Json.Parser parser = new Json.Parser();
		try {
			parser.load_from_data(lightStates);
			Json.Node node = parser.get_root();
			
			Json.Object lightObj = node.get_object();
			foreach (string light in lightObj.get_members()) {
				// debug
				stdout.printf("[Lights.refreshLights] light = '%s'\n", light);
				
				light_id = int.parse(light);
				
				Json.Node categoryNode = lightObj.get_member(light);
				Json.Object categoryObj = categoryNode.get_object();
				foreach (string category in categoryObj.get_members()) {
					// debug
					stdout.printf("[Lights.refreshLights] category ?= '%s'\n", category);
				
					if (category == "state") {
						// debug
						stdout.printf("[Lights.refreshLights] category = '%s'\n", category);
						
						Json.Node stateNode = categoryObj.get_member(category);
						Json.Object stateObj = stateNode.get_object();
						foreach (string state in stateObj.get_members()) {
							if (state == "on") {
								lswitch = stateObj.get_boolean_member(state);
							}
							else if (state == "bri") {
								bri = stateObj.get_int_member(state);
							} 
							else if (state == "hue") {
								hue = stateObj.get_int_member(state);
								debug("[Lights.refreshLights] hue = " + hue.to_string());
							} 
							else if (state == "sat") {
								sat = stateObj.get_int_member(state);
								debug("[Lights.refreshLights] sat = " + sat.to_string());
							}
						}
					}
					else if (category == "name") {
						// debug
						stdout.printf("[Lights.refreshLights] category = '%s'\n", category);
						
						name = categoryObj.get_string_member(category);
						
						// degug
						stdout.printf("[Lights.refreshLights] lightName = '%s'\n", name);
					}
				}
				
				// degug
				stdout.printf("[Lights.refreshLights] lightName (addLight) = '%s'\n", name);
				
				addLight(name, light_id, hue, sat, bri, lswitch);
			}
		}
		catch (Error e) {
			stdout.printf(
				"[Lights.refreshLights] unable to parse 'lightStates': %s\n", 
				e.message
			);
		}
	}
}
