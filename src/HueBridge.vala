using Soup;
using Posix;

public class HueBridge : Soup.Session {
	private string ip_address;
	private string bridge_user = "lampe-bash";
		// TODO  choose user name other than "lampe-bash", use "lampe"; the bash-version should then use the same user
		
	private List<Soup.Message> msgs; 
	private const int MAX_MSGS = 3;
	private const int DEFAULT_DELAY = 125000; // 125 milliseconds
	private Thread<void*> bridgeThread;
	
	public HueBridge(string ip_address) {
		this.ip_address = ip_address;
		
		// sendMsgs.begin();
		try {
			bridgeThread = new Thread<void*>.try(
				"[HueBridge] starting bridgeThread", 
				this.sendMsgs
			);
		}
		catch (Error e) {
			debug("[HueBridge] ERROR during bridgeThread: " + e.message);
		}
	}
	
	~HueBridge() {
		bridgeThread.join();
	}
	
	private void* sendMsgs() {
		while (true) {
			if (msgs.length() > 0) {
				Soup.Message s_msg = msgs.nth_data(0);
				debug("[HueBridge(Light).sendMsgs] request = '" 
					+ (string) s_msg.request_body.flatten().data + "'");
				this.send_message(s_msg);
				debug("[HueBridge(Light).sendMsgs] response = '" 
					+ (string) s_msg.response_body.flatten().data + "'");
				msgs.remove(s_msg);
			}
			Thread.usleep(DEFAULT_DELAY);
		}

		// return 0;
	}
	
	private void addMsg(Soup.Message msg) {
		if (msgs.length() > MAX_MSGS) {
			Soup.Message d_msg = msgs.nth_data(0);
			msgs.remove(d_msg);
		}
		msgs.append(msg);
	}
	
	// set state of a light
	public void putState(int light, string request) {
		Soup.Message msg = new Soup.Message(
			"PUT", 
			"http://" + this.ip_address + "/api/" + this.bridge_user 
				+ "/lights/" + light.to_string() + "/state"
		);
		msg.set_request("application/json", MemoryUse.COPY, request.data);		
		addMsg(msg);
		// debug("[HueBridge(Light).putState] status = " 
		//	+ msg.status_code.to_string());
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
