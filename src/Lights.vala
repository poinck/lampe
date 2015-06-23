using Gtk;

public class Lights : ListBox {

	// initialize a ListBox for lights
	public Lights() {
		this.hexpand = true;
		this.vexpand = false;
		this.margin_start = 1;
		this.margin_end = 1;
		this.margin_top = 1;
		this.margin_bottom = 1;
		this.activate_on_single_click = false;
		this.selection_mode = SelectionMode.NONE;
		this.border_width = 1;
	}
	
	public void addLight(string name) {
		var lightBox = new Light(name);
		
		// this.insert(lightBox, 1);
		this.prepend(lightBox);
	}
}
