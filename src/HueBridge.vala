using Soup;

public class HueBridge : Soup.Session {
	private string ip_address;
	private string bridge_user = "lampe-bash";
		// TODO  choose user name other than "lampe-bash"
	
	public HueBridge(string ip_address) {
		this.ip_address = ip_address;
	}
	
	// set state of a light
	public void putState(int light, string request) {
		Soup.Message msg = new Soup.Message(
			"PUT", 
			"http://" + this.ip_address + "/api/" + this.bridge_user + "/lights/" + light.to_string() + "/state"
		);
		msg.set_request("application/json", MemoryUse.COPY, request.data);
		this.send_message(msg);

		// debug
		stdout.printf("[Light.putState] status = %u\n", msg.status_code);
		stdout.printf("[Light.putState] response = '%s'\n", (string) msg.response_body.flatten().data);
	}
	
	// get all states of all lights
	public string getStates() {
		Soup.Message msg = new Soup.Message(
			"GET", 
			"http://" + this.ip_address + "/api/" + this.bridge_user + "/lights"
		);
		this.send_message(msg);
		string rsp = (string) msg.response_body.flatten().data;
			// FIXME "warning: assignment discards 'const' qualifier from pointer target type" (cast from const unit8[] to string)
		
		// debug
		stdout.printf("[Lights.getStates] response = '%s'\n", rsp);
		
		return rsp;
	}
}
