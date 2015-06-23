using Soup;

public class HueBridge : Soup.Session {
	private string ip_address;
	
	public HueBridge(string ip_address) {
		this.ip_address = ip_address;
	}
	
	public void putState(int light, string request) {
		Soup.Message msg = new Soup.Message (
			"PUT", 
			"http://" + this.ip_address + "/api/lampe-bash/lights/" + light.to_string() + "/state"
		);
			// TODO  choose user name other than "lampe-bash"
		msg.set_request("application/json", MemoryUse.COPY, request.data);
		this.send_message(msg);

		// debug
		stdout.printf ("[Light] status = %u\n", msg.status_code);
		stdout.printf ("[Light] response = \n'%s'\n", (string) msg.response_body.data);
	}
}
