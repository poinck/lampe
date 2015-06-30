using Soup;
using Posix;

public class HueBridge : Soup.Session {
	private string ip_address;
	private string bridge_user = "lampe-bash";
		// TODO  choose user name other than "lampe-bash", use "lampe"; the bash-version should then use the same user
		
	private const int DEFAULT_DELAY = 125; // 125 milliseconds	
	private bool timer_is_running = false;
	private Soup.Message s_msg;
	
	public HueBridge(string ip_address) {
		this.ip_address = ip_address;
		
	}
	
	private void sendMsg() {
		if (s_msg != null) {
			debug("[HueBridge(Light).sendMsg] request = '" 
				+ (string) s_msg.request_body.flatten().data + "'");
			this.send_message(s_msg);
			debug("[HueBridge(Light).sendMsg] response = '" 
				+ (string) s_msg.response_body.flatten().data + "'");
		}
	}
	
	// set state of a light
	public void putState(int light, string request) {
		s_msg = new Soup.Message(
			"PUT", 
			"http://" + this.ip_address + "/api/" + this.bridge_user 
				+ "/lights/" + light.to_string() + "/state"
		);
		s_msg.set_request("application/json", MemoryUse.COPY, request.data);		
		
		// delay msg and always send last msg in that delay-timeframe
		if (timer_is_running == false) {
			Timeout.add(DEFAULT_DELAY, () => {
				sendMsg();
				timer_is_running = false;
				
				return false;
			});
			timer_is_running = true;
		}
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
		
		debug("[HueBridge(Lights).getStates] response = '" + rsp + "'");
		
		return rsp;
	}
}
