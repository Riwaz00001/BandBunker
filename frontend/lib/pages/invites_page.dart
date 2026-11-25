import 'package:cached_network_image/cached_network_image.dart';
import 'package:frontend/pages/profile_page.dart';
import 'package:frontend/clients/bands_client.dart';
import 'package:frontend/helpers/alert_helper.dart';
import 'package:frontend/models/join_request.dart';
import 'package:frontend/widgets/invite_card.dart';
import 'package:frontend/pages/band_profile_page.dart';

class InvitesPage extends StatefulWidget {
  const InvitesPage({super.key});

  @override
  State<InvitesPage> createState() => _InvitesPageState();
}

class _InvitesPageState extends State<InvitesPage> {
  static const Color orange = Color(0xFFFF7A00);
  static const Color background = Color(0xFF121212);
  static const Color cardColor = Color(0xFF202026);
  static const Color secondaryText = Color(0xFFBDB8C9);

  List<Invite> _invites = [];
  List<JoinRequest> _joinRequests = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadInvites();
  }

  Future<void> _loadInvites() async {
    setState(() => _loading = true);
    try {
      final invites = await BandsClient.instance.getInvites();
      final jrs = await BandsClient.instance.getJoinRequests();
      if (mounted) {
        setState(() {
          _invites = invites;
          _joinRequests = jrs;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
        AlertHelper.error(context, e.toString());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: background,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Invites',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _loadInvites,
        color: orange,
        child: _loading
            ? const Center(child: CircularProgressIndicator(color: orange))
            : (_invites.isEmpty && _joinRequests.isEmpty)
                ? ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.6,
                        child: const Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 35),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.mail_outline,
                                  color: Colors.white24,
                                  size: 65,
                                ),
                                SizedBox(height: 15),
                                Text(
                                  'No pending invites',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Band invites will appear here.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Color(0xFFBDB8C9),
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: _invites.length + _joinRequests.length,
                    itemBuilder: (context, index) {
                      if (index < _invites.length) {
                        return InviteCard(
                          invite: _invites[index],
                          onInviteChanged: _loadInvites,
                        );
                      }
                      final jr = _joinRequests[index - _invites.length];
                      return Card(
                        color: cardColor,
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundImage: jr.musicianProfilePicUrl != null ? CachedNetworkImageProvider(jr.musicianProfilePicUrl!) : null,
                            child: jr.musicianProfilePicUrl == null ? const Icon(Icons.person) : null,
                          ),
                          title: Text(jr.musicianName, style: const TextStyle(color: Colors.white)),
                          subtitle: Text('wants to join ${jr.bandName}', style: const TextStyle(color: secondaryText)),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(icon: const Icon(Icons.close, color: Colors.redAccent), onPressed: () async { await BandsClient.instance.rejectJoinRequest(jr.requestId); _loadInvites(); }),
                              IconButton(icon: const Icon(Icons.check, color: Colors.green), onPressed: () async { await BandsClient.instance.acceptJoinRequest(jr.requestId); _loadInvites(); }),
                            ],
                          ),
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ProfilePage(musicianId: jr.musicianId))),
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}