import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:uni_links/uni_links.dart';
import 'dart:async';
import '../home_screen.dart';
import '../../services/api_service.dart';

class WalletConnectScreen extends StatefulWidget {
  final ApiService apiService;

  const WalletConnectScreen({
    super.key,
    required this.apiService,
  });

  @override
  _WalletConnectScreenState createState() => _WalletConnectScreenState();
}

class _WalletConnectScreenState extends State<WalletConnectScreen> {
  bool _isConnecting = false;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  String _nonce = '';
  StreamSubscription? _deepLinkSubscription;
  bool _deepLinksInitialized = false;

  @override
  void initState() {
    super.initState();
    _generateNonce();
    _checkExistingSession();
    _initDeepLinks();
  }

  @override
  void dispose() {
    _deepLinkSubscription?.cancel();
    super.dispose();
  }

  // Initialisation des deep links
  Future<void> _initDeepLinks() async {
    if (_deepLinksInitialized) return;
    _deepLinksInitialized = true;

    // Vérifier si l'app a été lancée depuis un deep link
    try {
      final initialUri = await getInitialUri();
      if (initialUri != null) {
        debugPrint('📱 App lancée depuis deep link: $initialUri');
        _handleIncomingLink(initialUri);
      }
    } catch (e) {
      debugPrint('❌ Erreur lors de la récupération du deep link initial: $e');
    }

    // Écouter les deep links entrants
    _deepLinkSubscription = uriLinkStream.listen((Uri? uri) {
      if (uri != null) {
        debugPrint('📱 Deep link reçu pendant l\'exécution: $uri');
        _handleIncomingLink(uri);
      }
    }, onError: (error) {
      debugPrint('❌ Erreur dans le stream de deep link: $error');
    });
  }

  // Traiter les deep links entrants
  void _handleIncomingLink(Uri uri) {
    if (uri.scheme != 'born2bewild') return;

    debugPrint('🔍 Traitement du deep link: $uri');
    final params = uri.queryParameters;

    if (params.containsKey('wallet') || params.containsKey('account')) {
      // Récupérer l'adresse du wallet
      final walletAddress = params['wallet'] ?? params['account'];
      debugPrint('✅ Adresse de portefeuille reçue: $walletAddress');

      if (walletAddress != null) {
        // Stocker l'adresse et demander la signature
        _secureStorage.write(key: 'temp_wallet_address', value: walletAddress);
        _requestSignature(walletAddress);
      }
    } else if (params.containsKey('signature')) {
      // Récupérer la signature et l'adresse associée
      final signature = params['signature'];
      // Récupérer l'adresse stockée temporairement
      _secureStorage.read(key: 'temp_wallet_address').then((walletAddress) {
        if (walletAddress != null && signature != null) {
          debugPrint('✅ Signature reçue pour $walletAddress: $signature');
          _verifyAndCompleteAuth(walletAddress, signature);
        }
      });
    }
  }

  // Générer un nonce aléatoire pour la sécurité
  Future<void> _generateNonce() async {
    final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    final random = DateTime.now().microsecondsSinceEpoch.toString();
    final rawNonce = '$timestamp-$random';

    final bytes = utf8.encode(rawNonce);
    final digest = sha256.convert(bytes);

    _nonce = digest.toString();
    await _secureStorage.write(key: 'auth_nonce', value: _nonce);
    debugPrint('🔐 Nonce généré: $_nonce');
  }

  // Vérifier si une session existe déjà
  Future<void> _checkExistingSession() async {
    debugPrint('🔍 Vérification d\'une session existante...');
    final storedAddress = await _secureStorage.read(key: 'wallet_address');
    final isAuthenticated = await _secureStorage.read(key: 'authenticated');

    if (storedAddress != null && isAuthenticated == 'true') {
      debugPrint('✅ Session existante trouvée pour: $storedAddress');
      // Option: rediriger automatiquement vers HomeScreen si session valide
    } else {
      debugPrint('ℹ️ Aucune session existante trouvée');
    }
  }

  // Générer le message SIWS
  String _generateSIWSMessage(String domain, String walletAddress) {
    final currentDate = DateTime.now().toUtc().toString();

    return '''
    domain: $domain
    wallet: $walletAddress
    nonce: $_nonce
    issued-at: $currentDate
    statement: Sign in to Born2BeWild with your Solana account
    version: 1
    '''
        .trim();
  }

  // Lancer le processus de connexion Phantom
  Future<void> _connectWithPhantom() async {
    setState(() {
      _isConnecting = true;
    });

    debugPrint('🔶 Démarrage du processus de connexion Phantom...');

    try {
      // URL de callback vers votre application
      final callbackUrl = 'born2bewild://auth';
      final encodedCallback = Uri.encodeComponent(callbackUrl);
      final connectWithRedirect =
          Uri.parse('phantom://connect?redirect_url=$encodedCallback');

      // Deep link pour la connexion Phantom
      // Pour le développement local, utilisez un nom de domaine temporaire
      final phantomConnectUri = Uri.parse('phantom://connect');

      debugPrint('🔗 Deep link de connexion: $phantomConnectUri');

      // Vérifier si Phantom est installé
      if (await canLaunchUrl(phantomConnectUri)) {
        debugPrint('✅ Lancement de Phantom pour connexion...');
        await launchUrl(phantomConnectUri,
            mode: LaunchMode.externalApplication);

        // À ce stade, on attend le retour via deep link
        // Le traitement se fera dans _handleIncomingLink

        // Pour le développement, nous affichons un message d'attente
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Attente de l\'authentification Phantom...'),
            duration: Duration(seconds: 10),
          ),
        );
      } else {
        // Phantom n'est pas installé
        debugPrint('❌ Phantom n\'est pas installé');

        // Rediriger vers l'App Store
        final appStoreUri = Uri.parse(
            'https://apps.apple.com/app/phantom-crypto-wallet/id1574741552');

        await launchUrl(appStoreUri, mode: LaunchMode.externalApplication);

        setState(() {
          _isConnecting = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content:
                Text('Veuillez installer Phantom Wallet depuis l\'App Store'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      debugPrint('❌ Erreur lors de la connexion: $e');

      setState(() {
        _isConnecting = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur de connexion: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Demander la signature du message
  Future<void> _requestSignature(String walletAddress) async {
    try {
      // Générer le message à signer
      final message = _generateSIWSMessage('born2bewild.app', walletAddress);
      debugPrint('📝 Message généré pour signature:');
      debugPrint(message);

      // Encoder le message pour le deep link
      final encodedMessage =
          Uri.encodeComponent(base64Encode(utf8.encode(message)));
      final callbackUrl = Uri.encodeFull('born2bewild://auth');

      // URL pour la demande de signature
      final signRequestUri = Uri.parse(
          'phantom://sign?message=$encodedMessage&redirect_url=$callbackUrl');

      debugPrint('🔗 Deep link de signature: $signRequestUri');

      // Lancer Phantom pour la signature
      if (await canLaunchUrl(signRequestUri)) {
        await launchUrl(signRequestUri, mode: LaunchMode.externalApplication);
      } else {
        debugPrint('❌ Impossible de lancer Phantom pour la signature');

        // Réinitialiser l'état de connexion en cas d'échec
        setState(() {
          _isConnecting = false;
        });
      }
    } catch (e) {
      debugPrint('❌ Erreur lors de la demande de signature: $e');
      setState(() {
        _isConnecting = false;
      });
    }
  }

  // Vérifier la signature et compléter l'authentification
  Future<void> _verifyAndCompleteAuth(
      String walletAddress, String signature) async {
    debugPrint('🔐 Vérification de la signature pour $walletAddress');

    // Dans une implémentation réelle, envoyez la signature à votre backend pour vérification
    // Ici, nous simulons une vérification réussie

    // Stocker les informations d'authentification
    await _secureStorage.write(key: 'wallet_address', value: walletAddress);
    await _secureStorage.write(key: 'authenticated', value: 'true');
    await _secureStorage.delete(
        key: 'temp_wallet_address'); // Nettoyer l'adresse temporaire

    // Vérifier le stockage des données
    final storedAddress = await _secureStorage.read(key: 'wallet_address');
    debugPrint('💾 Adresse stockée: $storedAddress');

    // Réinitialiser l'état de connexion
    setState(() {
      _isConnecting = false;
    });

    // Informer l'utilisateur
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            'Connecté avec le portefeuille: ${walletAddress.substring(0, 8)}...'),
        backgroundColor: Colors.green,
      ),
    );

    // Naviguer vers l'écran principal
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => HomeScreen(
          walletAddress: walletAddress,
          apiService: widget.apiService,
        ),
      ),
    );
  }

  // Pour le développement: simuler une connexion complète
  void _simulateSuccessfulAuth() async {
    final simulatedAddress = 'bosq5LCREmQ4aiSwzYdvD7N1thoASZzHVqvCA1D2Cg5';

    await _secureStorage.write(key: 'wallet_address', value: simulatedAddress);
    await _secureStorage.write(key: 'authenticated', value: 'true');

    debugPrint('🔧 Simulation d\'authentification avec: $simulatedAddress');

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => HomeScreen(
          walletAddress: simulatedAddress,
          apiService: widget.apiService,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background image
          Image.asset(
            'assets/images/1.png',
            width: double.infinity,
            height: double.infinity,
            fit: BoxFit.cover,
          ),
          // Main content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Application logo
                Image.asset(
                  'assets/logo.png',
                  width: 200,
                  height: 200,
                  fit: BoxFit.contain,
                ),

                const SizedBox(height: 40),

                // Wallet connection button
                _isConnecting
                    ? Column(
                        children: [
                          const CircularProgressIndicator(
                            color: Colors.white,
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'Authentification avec Solana...',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  color: Colors.white,
                                ),
                          ),
                        ],
                      )
                    : Column(
                        children: [
                          ElevatedButton(
                            onPressed: _connectWithPhantom,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 30, vertical: 15),
                              backgroundColor:
                                  const Color.fromARGB(255, 103, 218, 198),
                              foregroundColor: Theme.of(context).primaryColor,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Image.asset(
                                  'assets/phantom_icon.png', // Assurez-vous d'avoir cette image
                                  width: 24,
                                  height: 24,
                                ),
                                const SizedBox(width: 10),
                                const Text(
                                  'Sign in with Solana',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 15),
                          TextButton(
                            onPressed: _simulateSuccessfulAuth,
                            child: Text(
                              'Continuer en tant qu\'invité',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.7),
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                          // Bouton pour les tests de développement uniquement
                          if (kDebugMode)
                            TextButton(
                              onPressed: () {
                                // Simuler un deep link entrant
                                final testUri = Uri.parse(
                                    'born2bewild://auth?wallet=AxGE6q5QnPe3AMrHaLxQzHC8EML1QQK9wrFp5j9DWi4t');
                                _handleIncomingLink(testUri);
                              },
                              child: Text(
                                '(Test: Simuler deep link)',
                                style: TextStyle(
                                  color: Colors.amber.withOpacity(0.8),
                                  fontSize: 12,
                                ),
                              ),
                            ),
                        ],
                      ),

                const SizedBox(height: 40),

                // Texts
                Text(
                  'Born 2 be Wild',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.white,
                        fontSize: 30,
                      ),
                  textAlign: TextAlign.center,
                ),
                Text(
                  'Powered by Solana',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.white,
                      ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
