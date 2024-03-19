class LoginModel {
  Servers? selectedServer;
  bool isPasswordVisible;

  LoginModel({this.selectedServer = Servers.server1, this.isPasswordVisible = false});
}

enum Servers {
  server1("Wasabi", "https://wasabi-server.fly.dev/"),
  server2("localhost", 'http://localhost:8080/'),
  server3("Kipp", 'http://192.168.56.1:8080/'),
  server4("Add Server", '');

  const Servers(this.serverName, this.serverIP);
  final String serverName;
  final String serverIP;
}
