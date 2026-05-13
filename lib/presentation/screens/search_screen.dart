import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../generated/l10n.dart';
import '../providers/social_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/league_provider.dart';
import '../../domain/models/league_model.dart';
import 'other_profile_screen.dart';
import 'package:confetti/confetti.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _searchController = TextEditingController();
  final _focusNode = FocusNode();
  late ConfettiController _confettiController;
  List<dynamic> _searchResults = [];
  bool _isSearchingUsers = false;
  bool _isLoadingResults = false;
  bool _isDialogShowing = false;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 2));
    _focusNode.addListener(() {
      setState(() {
        _isSearchingUsers = _focusNode.hasFocus || _searchController.text.isNotEmpty;
      });
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = context.read<AuthProvider>().currentUser;
      if (user != null) {
        final leagueProv = context.read<LeagueProvider>();
        leagueProv.initRealtimeListeners(user.id);
        leagueProv.loadUserLeague(user.id);
        leagueProv.addListener(_handleLeagueResults);
      }
    });
  }

  void _handleLeagueResults() {
    final leagueProv = context.read<LeagueProvider>();

    if (leagueProv.pendingResult != null && !_isDialogShowing && mounted) {
      _isDialogShowing = true;
      _showResultDialog(context, leagueProv.pendingResult!);
    }
  }

  @override
  void dispose() {
    context.read<LeagueProvider>().removeListener(_handleLeagueResults);
    _searchController.dispose();
    _focusNode.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  void _searchUsers(String query) async {
    if (query.isEmpty) {
      setState(() => _searchResults = []);
      return;
    }
    setState(() => _isLoadingResults = true);
    try {
      final socialProvider = context.read<SocialProvider>();
      final results = await socialProvider.searchUsers(query);
      if (mounted) setState(() => _searchResults = results);
    } catch (e) {
      debugPrint("Error cerca: $e");
    } finally {
      if (mounted) setState(() => _isLoadingResults = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final strings = S.of(context);

    return Stack(
      children: [
        Scaffold(
          backgroundColor: theme.colorScheme.surface,
          appBar: AppBar(
            elevation: 0,
            backgroundColor: Colors.transparent,
            title: _buildSearchBar(theme, strings),
          ),
          body: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: _isSearchingUsers
                ? _buildSearchResults(strings, theme)
                : _buildLeagueView(strings, theme),
          ),
        ),
        Align(
          alignment: Alignment.topCenter,
          child: ConfettiWidget(
            confettiController: _confettiController,
            blastDirectionality: BlastDirectionality.explosive,
            shouldLoop: false,
            colors: const [Colors.green, Colors.blue, Colors.pink, Colors.orange, Colors.purple],
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar(ThemeData theme, S strings) {
    return Container(
      height: 45,
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.1)),
      ),
      child: TextField(
        controller: _searchController,
        focusNode: _focusNode,
        onChanged: _searchUsers,
        style: const TextStyle(fontSize: 15),
        decoration: InputDecoration(
          hintText: strings.searchUsersHint,
          hintStyle: TextStyle(color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5)),
          border: InputBorder.none,
          prefixIcon: Icon(Icons.search_rounded, color: theme.colorScheme.primary, size: 20),
          suffixIcon: _isSearchingUsers
              ? IconButton(
            icon: const Icon(Icons.close_rounded, size: 20),
            onPressed: () {
              _searchController.clear();
              _searchUsers("");
              _focusNode.unfocus();
            },
          )
              : null,
        ),
      ),
    );
  }

  Widget _buildLeagueView(S strings, ThemeData theme) {
    final leagueProv = context.watch<LeagueProvider>();

    if (leagueProv.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (leagueProv.currentLeague == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.emoji_events_outlined, size: 64, color: theme.colorScheme.outline.withValues(alpha: 0.5)),
            const SizedBox(height: 16),
            Text(strings.noLeagueJoined, style: TextStyle(color: theme.colorScheme.outline)),
          ],
        ),
      );
    }

    return Column(
      children: [
        _buildLeagueHeader(theme, leagueProv.currentLeague!),
        const SizedBox(height: 8),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
            physics: const BouncingScrollPhysics(),
            itemCount: leagueProv.ranking.length,
            separatorBuilder: (context, index) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final participant = leagueProv.ranking[index];
              return _buildRankingItem(theme, participant, leagueProv.currentLeague!);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildLeagueHeader(ThemeData theme, LeagueModel league) {
    final leagueColor = Color(int.parse(league.color.replaceFirst('#', '0xff')));
    final strings = S.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
      decoration: BoxDecoration(
        color: leagueColor.withValues(alpha: 0.05),
        border: Border(bottom: BorderSide(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5))),
      ),
      child: Column(
        children: [
          Icon(Icons.emoji_events_rounded, size: 60, color: leagueColor),
          const SizedBox(height: 12),
          Text(
            league.getLocalizedName(strings).toUpperCase(),
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
              color: leagueColor,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            decoration: BoxDecoration(
              color: leagueColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              strings.xpLevel(league.nivellLliga),
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.timer_outlined, size: 14, color: theme.colorScheme.onSurfaceVariant),
              const SizedBox(width: 4),
              Text(
                league.getTimeRemaining(strings),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.8),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRankingItem(ThemeData theme, LeagueParticipationModel p, LeagueModel league) {
    final auth = context.read<AuthProvider>();
    final isMe = p.userId == auth.currentUser?.id;
    final leagueColor = Color(int.parse(league.color.replaceFirst('#', '0xff')));
    final strings = S.of(context);

    return InkWell(
      onTap: () async {
        if (isMe) {
          auth.setTabIndex(4);
        } else {
          final socialProv = context.read<SocialProvider>();
          final targetUser = await socialProv.getUserById(p.userId);

          if (targetUser != null && mounted) {
            Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => OtherProfileScreen(userData: targetUser))
            );
          }
        }
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isMe ? leagueColor.withValues(alpha: 0.1) : theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isMe ? leagueColor : theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
            width: isMe ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 35,
              child: Text(
                "${p.posicioActual}.",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: p.posicioActual <= 3 ? leagueColor : theme.colorScheme.onSurface,
                ),
              ),
            ),
            CircleAvatar(
              radius: 22,
              backgroundColor: leagueColor.withValues(alpha: 0.1),
              backgroundImage: p.imatgePerfil != null ? NetworkImage(p.imatgePerfil!) : null,
              child: p.imatgePerfil == null
                  ? Text(p.nickname?[0].toUpperCase() ?? "?", style: TextStyle(color: leagueColor, fontWeight: FontWeight.bold))
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(p.nickname ?? "Usuari", style: TextStyle(fontWeight: isMe ? FontWeight.bold : FontWeight.w600)),

                  if (p.posicioActual <= 3 && !league.isMaxLevel)
                    Row(
                      children: [
                        const Icon(Icons.arrow_upward_rounded, size: 12, color: Colors.green),
                        const SizedBox(width: 4),
                        Text(strings.ascensionZone, style: const TextStyle(fontSize: 10, color: Colors.green, fontWeight: FontWeight.bold)),
                      ],
                    ),

                  if (p.posicioActual >= 8 && !league.isMinLevel)
                    Row(
                      children: [
                        const Icon(Icons.arrow_downward_rounded, size: 12, color: Colors.red),
                        const SizedBox(width: 4),
                        Text(strings.descensionZone, style: const TextStyle(fontSize: 10, color: Colors.red, fontWeight: FontWeight.bold)),
                      ],
                    ),
                ],
              ),
            ),
            Text("${p.xpTemporada} XP", style: TextStyle(color: leagueColor, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchResults(S strings, ThemeData theme) {
    if (_isLoadingResults) return const Center(child: CircularProgressIndicator());

    if (_searchResults.isEmpty && _searchController.text.isNotEmpty) {
      return Center(
        child: Text(strings.noResultsFound, style: TextStyle(color: theme.colorScheme.outline)),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _searchResults.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final user = _searchResults[index];
        return _buildUserResultItem(theme, user);
      },
    );
  }

  Widget _buildUserResultItem(ThemeData theme, dynamic user) {
    return InkWell(
      onTap: () async {
        final socialProv = context.read<SocialProvider>();
        final targetUser = await socialProv.getUserById(user['id']);

        if (targetUser != null && mounted) {
          Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => OtherProfileScreen(userData: targetUser))
          );
        }
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5)),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 25,
              backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
              backgroundImage: (user['imatge_perfil'] != null) ? NetworkImage(user['imatge_perfil']) : null,
              child: (user['imatge_perfil'] == null)
                  ? Text(user['nickname'][0].toUpperCase(),
                  style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold))
                  : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(user['nickname'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  Text("${user['nom']} ${user['cognom']}",
                      style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 14)),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: theme.colorScheme.outline.withValues(alpha: 0.5)),
          ],
        ),
      ),
    );
  }

  void _showResultDialog(BuildContext context, LeagueResultModel result) {
    final strings = S.of(context);
    final isPromotion = result.type == LeagueResultType.promoted;
    final isDemotion = result.type == LeagueResultType.demoted;
    final translatedLevelName = LeagueModel.getLocalizedLevelName(result.nivellNou, strings);

    if (isPromotion) {
      _confettiController.play();
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(isPromotion ? strings.leagueResultCongratulation : strings.leagueResultFinished),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isPromotion ? Icons.trending_up : (isDemotion ? Icons.trending_down : Icons.trending_flat),
              size: 64,
              color: isPromotion ? Colors.green : (isDemotion ? Colors.red : Colors.orange),
            ),
            const SizedBox(height: 16),
            Text(strings.leagueResultPosition(result.posicioFinal), textAlign: TextAlign.center),
            const SizedBox(height: 12),
            Text(
              isPromotion
                  ? strings.leagueResultPromoted(translatedLevelName)
                  : (isDemotion ? strings.leagueResultDemoted(translatedLevelName) : strings.leagueResultStayed(translatedLevelName)),
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () {
                context.read<LeagueProvider>().dismissResult();
                _isDialogShowing = false;
                Navigator.pop(context);
              },
              child: Text(strings.leagueResultDismiss),
            ),
          )
        ],
      ),
    );
  }
}