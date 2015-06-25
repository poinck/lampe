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
	
	public void addLight(string name, int light_id = 1, int hue = 12000, int sat = 192, int bri = 32, bool lswitch = false) {
		this.light_count++;
		Light light = new Light(light_id, name, hue, sat, bri, lswitch, bridge);
		
		// debug
		stdout.printf("[Lights.addLight] light_count = '%i'\n", light_count);
		
		this.insert(light, light_count);
		this.show_all();
	}
	
	public void deleteLights() {	
		this.foreach((w) => {
			remove(w);
		});
		
		this.light_count = 0;
	}
	
	public void refreshLights() {
		deleteLights();
		
		string lightName = "";
		
		string lightStates = this.bridge.getStates();
		Json.Parser parser = new Json.Parser();
		try {
			parser.load_from_data(lightStates);
			Json.Node node = parser.get_root();
			
			Json.Object lightObj = node.get_object();
			foreach (string light in lightObj.get_members()) {
				// debug
				stdout.printf("[Lights.refreshLights] light = '%s'\n", light);
				
				Json.Node categoryNode = lightObj.get_member(light);
				Json.Object categoryObj = categoryNode.get_object();
				foreach (string category in categoryObj.get_members()) {
					// debug
					stdout.printf("[Lights.refreshLights] category ?= '%s'\n", category);
				
					if (category == "state") {
						// debug
						stdout.printf("[Lights.refreshLights] category = '%s'\n", category);
						
//						Json.Node nameNode = categoryObj.get_member(category);
//						Json.Object stateObj = stateNode.get_object();
//						foreach (string category in stateObj.get_members()) {
					}
					else if (category == "name") {
						// debug
						stdout.printf("[Lights.refreshLights] category = '%s'\n", category);
						
						lightName = categoryObj.get_string_member(category);
						
						// degug
						stdout.printf("[Lights.refreshLights] lightName = '%s'\n", lightName);
					}
				}
				
				// degug
				stdout.printf("[Lights.refreshLights] lightName (addLight) = '%s'\n", lightName);
				
				addLight(lightName);
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
