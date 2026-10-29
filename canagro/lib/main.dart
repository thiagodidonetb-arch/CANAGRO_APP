
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'servicos/diagnostico_ia.dart';

void main() {
  runApp(const CanagroApp());
}

class CanagroApp extends StatelessWidget {
  const CanagroApp({super.key});

  static const verde = Color(0xFF236B45);
  static const verdeClaro = Color(0xFFE8F3EC);
  static const fundo = Color(0xFFF6F8F6);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CANAGRO',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: fundo,
        colorScheme: ColorScheme.fromSeed(seedColor: verde),
        appBarTheme: const AppBarTheme(
          backgroundColor: fundo,
          foregroundColor: verde,
          centerTitle: false,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: verde,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 15,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
      ),
      home: const TelaAcesso(),
    );
  }
}

class TelaAcesso extends StatelessWidget {
  const TelaAcesso({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(26),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: const BoxDecoration(
                    color: CanagroApp.verdeClaro,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.agriculture,
                    size: 55,
                    color: CanagroApp.verde,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'CANAGRO',
                  style: TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.bold,
                    color: CanagroApp.verde,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Tecnologia para cuidar da sua lavoura.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 35),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const LoginPage(),
                        ),
                      );
                    },
                    child: const Text('Entrar'),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const CadastroPage(),
                        ),
                      );
                    },
                    child: const Text('Criar conta'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class Campo extends StatelessWidget {
  final String rotulo;
  final IconData? icone;
  final bool senha;
  final TextInputType? tipo;
  final TextEditingController? controlador;

  const Campo({
    super.key,
    required this.rotulo,
    this.icone,
    this.senha = false,
    this.tipo,
    this.controlador,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controlador,
      obscureText: senha,
      keyboardType: tipo,
      decoration: InputDecoration(
        labelText: rotulo,
        prefixIcon: icone == null ? null : Icon(icone),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final email = TextEditingController();
  final senha = TextEditingController();

  @override
  void dispose() {
    email.dispose();
    senha.dispose();
    super.dispose();
  }

  void entrar() {
    if (email.text.trim().isEmpty || senha.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Preencha o e-mail e a senha.'),
        ),
      );
      return;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const InicioPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Entrar')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const Icon(
            Icons.agriculture,
            size: 72,
            color: CanagroApp.verde,
          ),
          const SizedBox(height: 24),
          const Text(
            'Bem-vindo ao CANAGRO',
            style: TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text('Entre para acessar as ferramentas do aplicativo.'),
          const SizedBox(height: 26),
          Campo(
            rotulo: 'E-mail',
            icone: Icons.email_outlined,
            tipo: TextInputType.emailAddress,
            controlador: email,
          ),
          const SizedBox(height: 16),
          Campo(
            rotulo: 'Senha',
            icone: Icons.lock_outline,
            senha: true,
            controlador: senha,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: entrar,
            child: const Text('Entrar no aplicativo'),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const CadastroPage(),
                ),
              );
            },
            child: const Text('Ainda não tenho conta'),
          ),
          const SizedBox(height: 12),
          const Text(
            'Esta tela ainda não autentica usuários em um servidor.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}

class CadastroPage extends StatefulWidget {
  const CadastroPage({super.key});

  @override
  State<CadastroPage> createState() => _CadastroPageState();
}

class _CadastroPageState extends State<CadastroPage> {
  final nome = TextEditingController();
  final email = TextEditingController();
  final senha = TextEditingController();

  @override
  void dispose() {
    nome.dispose();
    email.dispose();
    senha.dispose();
    super.dispose();
  }

  void cadastrar() {
    if (nome.text.trim().isEmpty ||
        email.text.trim().isEmpty ||
        senha.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Preencha todos os campos.'),
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Cadastro demonstrativo. A criação real de contas '
          'ainda precisa ser configurada.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Criar conta')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const Text(
            'Faça seu cadastro',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text('Preencha os dados para continuar.'),
          const SizedBox(height: 24),
          Campo(
            rotulo: 'Nome completo',
            icone: Icons.person_outline,
            controlador: nome,
          ),
          const SizedBox(height: 16),
          Campo(
            rotulo: 'E-mail',
            icone: Icons.email_outlined,
            tipo: TextInputType.emailAddress,
            controlador: email,
          ),
          const SizedBox(height: 16),
          Campo(
            rotulo: 'Senha',
            icone: Icons.lock_outline,
            senha: true,
            controlador: senha,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: cadastrar,
            child: const Text('Criar conta'),
          ),
        ],
      ),
    );
  }
}

class CameraCapturePage extends StatefulWidget {
  const CameraCapturePage({super.key});

  @override
  State<CameraCapturePage> createState() => _CameraCapturePageState();
}

class _CameraCapturePageState extends State<CameraCapturePage> {
  CameraController? _controller;
  String? _erro;
  bool _capturando = false;

  @override
  void initState() {
    super.initState();
    _inicializarCamera();
  }

  Future<void> _inicializarCamera() async {
    try {
      final cameras = await availableCameras();

      if (cameras.isEmpty) {
        throw CameraException('cameraIndisponivel', 'Nenhuma câmera encontrada.');
      }

      final controller = CameraController(
        cameras.first,
        ResolutionPreset.medium,
        enableAudio: false,
      );

      await controller.initialize();

      if (!mounted) {
        await controller.dispose();
        return;
      }

      setState(() => _controller = controller);
    } on CameraException catch (e) {
      if (!mounted) return;

      setState(() {
        _erro = e.description ?? 'Não foi possível acessar a câmera.';
      });
    } catch (e) {
      if (!mounted) return;

      setState(() => _erro = 'Não foi possível acessar a câmera.');
      debugPrint('Erro ao inicializar câmera: $e');
    }
  }

  Future<void> _tirarFoto() async {
    final controller = _controller;

    if (controller == null || !controller.value.isInitialized || _capturando) {
      return;
    }

    setState(() => _capturando = true);

    try {
      final foto = await controller.takePicture();

      if (mounted) Navigator.of(context).pop(foto);
    } on CameraException catch (e) {
      if (!mounted) return;

      setState(() => _erro = e.description ?? 'Não foi possível tirar a foto.');
    } finally {
      if (mounted) setState(() => _capturando = false);
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Fotografar planta'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: _erro != null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  _erro!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            )
          : controller == null || !controller.value.isInitialized
              ? const Center(child: CircularProgressIndicator())
              : Stack(
                  fit: StackFit.expand,
                  children: [
                    CameraPreview(controller),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 28),
                        child: FloatingActionButton(
                          onPressed: _capturando ? null : _tirarFoto,
                          child: _capturando
                              ? const CircularProgressIndicator()
                              : const Icon(Icons.camera_alt),
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }
}

class InicioPage extends StatefulWidget {
  const InicioPage({super.key});

  @override
  State<InicioPage> createState() => _InicioPageState();
}

class _InicioPageState extends State<InicioPage> {
  int selecionado = 0;

  final ImagePicker seletorImagem = ImagePicker();

  Uint8List? bytesImagem;
  String? nomeImagem;
  bool processandoFoto = false;
  ResultadoDiagnostico? resultadoDiagnostico;

  final List<ResultadoDiagnostico> historico = [];

  final List<String> titulos = [
    'Início',
    'Biblioteca',
    'Analisar',
    'Histórico',
    'Perfil',
  ];

  @override
  void initState() {
    super.initState();
    _recuperarFotoPerdida();
  }

  Future<void> _recuperarFotoPerdida() async {
    final LostDataResponse resposta = await seletorImagem.retrieveLostData();

    if (!mounted || resposta.isEmpty) return;

    if (resposta.file != null) {
      await _processarFoto(resposta.file!);
    } else if (resposta.exception != null) {
      mensagem('Não foi possível recuperar a foto. Tente novamente.');
      debugPrint('Erro ao recuperar imagem perdida: ${resposta.exception}');
    }
  }

  void mensagem(String texto) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(texto)),
    );
  }

  // Seleciona a foto, reduz seu tamanho e executa a IA.
  Future<void> selecionarFoto(ImageSource origem) async {
    if (processandoFoto) return;

    try {
      final XFile? foto = await seletorImagem.pickImage(
        source: origem,
        maxWidth: 640,
        maxHeight: 640,
        imageQuality: 70,
      );

      if (!mounted || foto == null) return;

      await _processarFoto(foto);
    } catch (e, stackTrace) {
      _mostrarErroAnalise(e, stackTrace);
    }
  }

  Future<void> _abrirCamera() async {
    if (processandoFoto) return;

    try {
      final XFile? foto = await Navigator.of(context).push<XFile>(
        MaterialPageRoute(builder: (_) => const CameraCapturePage()),
      );

      if (!mounted || foto == null) return;

      await _processarFoto(foto);
    } catch (e, stackTrace) {
      _mostrarErroAnalise(e, stackTrace);
    }
  }

  void _mostrarErroAnalise(Object erro, StackTrace stackTrace) {
    debugPrint('Erro ao analisar imagem: $erro');
    debugPrintStack(stackTrace: stackTrace);

    if (!mounted) return;

    setState(() {
      processandoFoto = false;
      resultadoDiagnostico = null;
    });

    mensagem(
      'Não foi possível analisar a foto. '
      'Tente outra imagem com boa iluminação.',
    );
  }

  Future<void> _processarFoto(XFile foto) async {
    if (!mounted) return;

    setState(() {
      processandoFoto = true;
      resultadoDiagnostico = null;
      bytesImagem = null;
      nomeImagem = foto.name;
    });

    final Uint8List bytes = await foto.readAsBytes();

    if (!mounted) return;

    setState(() {
      bytesImagem = bytes;
    });

    mensagem('Preparando imagem para análise...');

    final ResultadoDiagnostico resultado =
        await DiagnosticoIA.instancia.analisarFoto(bytes);

    if (!mounted) return;

    setState(() {
      resultadoDiagnostico = resultado;
      historico.insert(0, resultado);
      processandoFoto = false;
      selecionado = 2;
    });

    mensagem('Análise concluída.');
  }

  void mudarPagina(int indice) {
    setState(() => selecionado = indice);
  }

  @override
  Widget build(BuildContext context) {
    final paginas = [
      paginaInicial(),
      paginaBiblioteca(),
      paginaAnalisar(),
      paginaHistorico(),
      paginaPerfil(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(
              Icons.agriculture,
              color: CanagroApp.verde,
            ),
            const SizedBox(width: 8),
            Text(
              'CANAGRO · ${titulos[selecionado]}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
      body: SafeArea(child: paginas[selecionado]),
      bottomNavigationBar: NavigationBar(
        selectedIndex: selecionado,
        onDestinationSelected: mudarPagina,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Início',
          ),
          NavigationDestination(
            icon: Icon(Icons.menu_book_outlined),
            selectedIcon: Icon(Icons.menu_book),
            label: 'Biblioteca',
          ),
          NavigationDestination(
            icon: Icon(Icons.camera_alt_outlined),
            selectedIcon: Icon(Icons.camera_alt),
            label: 'Analisar',
          ),
          NavigationDestination(
            icon: Icon(Icons.history),
            label: 'Histórico',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }

  Widget paginaInicial() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: CanagroApp.verde,
            borderRadius: BorderRadius.circular(22),
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Sua lavoura mais saudável',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10),
              Text(
                'Utilize a inteligência artificial para avaliar '
                'fotos da cana-de-açúcar.',
                style: TextStyle(color: Colors.white, fontSize: 15),
              ),
            ],
          ),
        ),
        const SizedBox(height: 22),
        const Text(
          'O que você deseja fazer?',
          style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 14),
        Cartao(
          icone: Icons.camera_alt,
          titulo: 'Analisar uma foto',
          descricao: 'Envie uma imagem para obter uma classificação.',
          aoTocar: () => mudarPagina(2),
        ),
        Cartao(
          icone: Icons.menu_book,
          titulo: 'Biblioteca agrícola',
          descricao: 'Consulte informações sobre pragas e doenças.',
          aoTocar: () => mudarPagina(1),
        ),
        Cartao(
          icone: Icons.history,
          titulo: 'Últimas análises',
          descricao: 'Confira os resultados desta sessão.',
          aoTocar: () => mudarPagina(3),
        ),
        const SizedBox(height: 16),
        const Text(
          'Os resultados são estimativas e precisam ser confirmados '
          'por avaliação agronômica.',
          style: TextStyle(color: Colors.black54, fontSize: 13),
        ),
      ],
    );
  }

  Widget paginaBiblioteca() {
    final itens = [
      (
        'Broca-da-cana',
        'Inseto cuja larva perfura os colmos e pode prejudicar a produção.',
        Icons.pest_control
      ),
      (
        'Cana saudável',
        'Plantas com desenvolvimento adequado e sem sintomas evidentes.',
        Icons.eco
      ),
      (
        'Carvão da cana',
        'Doença que pode provocar uma estrutura escura semelhante a um chicote.',
        Icons.grass
      ),
      (
        'Cigarrinha-da-cana',
        'Praga que suga a seiva e pode causar danos às plantas.',
        Icons.bug_report
      ),
      (
        'Mosaico da cana',
        'Doença viral que pode provocar padrões claros e escuros nas folhas.',
        Icons.spa
      ),
    ];

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text(
          'Biblioteca agrícola',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        const Text('Informações iniciais sobre as classes do modelo.'),
        const SizedBox(height: 16),
        for (final item in itens)
          Card(
            child: ListTile(
              contentPadding: const EdgeInsets.all(14),
              leading: CircleAvatar(
                backgroundColor: CanagroApp.verdeClaro,
                child: Icon(item.$3, color: CanagroApp.verde),
              ),
              title: Text(
                item.$1,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(item.$2),
              ),
            ),
          ),
      ],
    );
  }

  Widget paginaAnalisar() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text(
          'Analisar uma imagem',
          style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        const Text(
          'Fotografe uma planta ou selecione uma imagem da galeria.',
        ),
        const SizedBox(height: 20),
        Container(
          width: double.infinity,
          constraints: const BoxConstraints(minHeight: 220),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.black12),
          ),
          child: bytesImagem == null
              ? const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.add_photo_alternate_outlined,
                      size: 65,
                      color: CanagroApp.verde,
                    ),
                    SizedBox(height: 12),
                    Text('Sua foto aparecerá aqui'),
                  ],
                )
              : ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.memory(
                    bytesImagem!,
                    fit: BoxFit.contain,
                  ),
                ),
        ),
        if (nomeImagem != null) ...[
          const SizedBox(height: 10),
          Text(
            'Arquivo: $nomeImagem',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
        const SizedBox(height: 18),
        ElevatedButton.icon(
          onPressed: processandoFoto
              ? null
              : _abrirCamera,
          icon: const Icon(Icons.camera_alt),
          label: const Text('Tirar foto'),
        ),
        const SizedBox(height: 10),
        OutlinedButton.icon(
          onPressed: processandoFoto
              ? null
              : () => selecionarFoto(ImageSource.gallery),
          icon: const Icon(Icons.photo_library_outlined),
          label: const Text('Escolher da galeria'),
        ),
        if (processandoFoto) ...[
          const SizedBox(height: 24),
          const Center(child: CircularProgressIndicator()),
          const SizedBox(height: 12),
          const Center(
            child: Text(
              'A inteligência artificial está analisando a imagem...',
              textAlign: TextAlign.center,
            ),
          ),
        ],
        if (resultadoDiagnostico != null) ...[
          const SizedBox(height: 24),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(
                        Icons.check_circle_outline,
                        color: CanagroApp.verde,
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Resultado da análise',
                          style: TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    resultadoDiagnostico!.classe,
                    style: const TextStyle(
                      fontSize: 22,
                      color: CanagroApp.verde,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Confiança estimada: '
                    '${(resultadoDiagnostico!.confianca * 100).toStringAsFixed(1)}%',
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'A classificação é uma estimativa do modelo, não '
                    'um diagnóstico definitivo. Confira os sintomas '
                    'e procure orientação agronômica.',
                  ),
                ],
              ),
            ),
          ),
          _cartaoManejo(resultadoDiagnostico!.classe),
        ],
        const SizedBox(height: 20),
        const Card(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Dica: fotografe a planta com boa iluminação e mantenha '
              'os sintomas visíveis. Uma foto isolada pode não ser '
              'suficiente para identificar o problema.',
            ),
          ),
        ),
      ],
    );
  }

  // Orientações iniciais para cada classe reconhecida pelo modelo.
  Widget _cartaoManejo(String classe) {
    late String manejo;
    late String prevencao;
    late String proximoPasso;

    switch (classe) {
      case 'Broca-da-cana':
        manejo =
            'Inspecione os colmos e procure orifícios, galerias e '
            'sinais de ataque. O controle biológico, incluindo o uso '
            'de parasitoides como Cotesia flavipes, pode ser uma opção '
            'quando indicado por avaliação técnica.';
        prevencao =
            'Monitore a lavoura regularmente, utilize material de '
            'plantio de procedência confiável e acompanhe o histórico '
            'da ocorrência da praga.';
        proximoPasso =
            'Examine plantas em diferentes pontos do talhão e registre '
            'a incidência antes de decidir o manejo.';
        break;

      case 'Carvão da cana':
        manejo =
            'Procure estruturas escuras alongadas semelhantes a chicotes. '
            'Se houver suspeita, solicite confirmação técnica e siga '
            'as orientações locais para manejo das plantas afetadas.';
        prevencao =
            'Priorize variedades resistentes quando disponíveis, '
            'mudas sadias e material de plantio de procedência confiável.';
        proximoPasso =
            'Fotografe os sintomas e procure orientação agronômica '
            'para confirmar a doença antes de tomar medidas na lavoura.';
        break;

      case 'Cigarrinha-da-cana':
        manejo =
            'Inspecione a base das plantas e procure ninfas, espuma '
            'e insetos adultos. A necessidade de controle depende '
            'da infestação e da fase da cultura. O controle biológico '
            'ou químico deve ser avaliado tecnicamente.';
        prevencao =
            'Faça monitoramento periódico e acompanhe a presença '
            'da praga em diferentes pontos do talhão.';
        proximoPasso =
            'Registre a ocorrência e a intensidade do ataque. '
            'Procure orientação técnica para escolher as medidas adequadas.';
        break;

      case 'Mosaico da cana':
        manejo =
            'Observe padrões claros e escuros nas folhas e confirme '
            'a suspeita. Não existe tratamento curativo que elimine '
            'o vírus de uma planta infectada. O manejo pode envolver '
            'variedades resistentes e medidas para reduzir a disseminação.';
        prevencao =
            'Utilize material de plantio saudável, prefira variedades '
            'resistentes recomendadas para a região e siga as orientações '
            'técnicas de prevenção.';
        proximoPasso =
            'Solicite confirmação agronômica, pois outras causas '
            'também podem provocar alterações na coloração das folhas.';
        break;

      case 'Cana saudável':
        manejo =
            'A foto foi classificada como cana saudável pelo modelo. '
            'Isso não garante ausência de pragas, doenças ou problemas '
            'que não sejam visíveis na imagem.';
        prevencao =
            'Mantenha o monitoramento, a nutrição equilibrada, '
            'o manejo adequado da água e as inspeções periódicas.';
        proximoPasso =
            'Continue acompanhando folhas, colmos e desenvolvimento '
            'das plantas. Fotografe de perto qualquer sintoma novo.';
        break;

      default:
        manejo =
            'Não há orientações cadastradas para esta classificação.';
        prevencao =
            'Mantenha o monitoramento periódico da lavoura.';
        proximoPasso =
            'Procure um profissional para avaliar a situação.';
    }

    Widget secao(
      String titulo,
      String texto,
      IconData icone,
    ) {
      return Padding(
        padding: const EdgeInsets.only(top: 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icone, color: CanagroApp.verde),
                const SizedBox(width: 9),
                Expanded(
                  child: Text(
                    titulo,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              texto,
              style: const TextStyle(
                fontSize: 14,
                height: 1.5,
              ),
            ),
          ],
        ),
      );
    }

    return Card(
      margin: const EdgeInsets.only(top: 14),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(
                  Icons.agriculture,
                  size: 28,
                  color: CanagroApp.verde,
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Orientações para a lavoura',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: CanagroApp.verde,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            const Text(
              'Recomendações iniciais relacionadas à classe prevista '
              'pela inteligência artificial.',
              style: TextStyle(
                color: Colors.black54,
                height: 1.4,
              ),
            ),
            secao(
              'Manejo recomendado',
              manejo,
              Icons.agriculture,
            ),
            secao(
              'Prevenção',
              prevencao,
              Icons.shield_outlined,
            ),
            secao(
              'O que fazer agora',
              proximoPasso,
              Icons.checklist,
            ),
            const SizedBox(height: 18),
            const Divider(),
            const SizedBox(height: 8),
            const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.info_outline,
                  size: 20,
                  color: Colors.orange,
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'A identificação pela foto é experimental. '
                    'Confirme o problema antes de realizar intervenções. '
                    'Produtos fitossanitários devem ser utilizados '
                    'somente quando registrados para a finalidade, '
                    'conforme o rótulo e com orientação profissional.',
                    style: TextStyle(
                      fontSize: 12,
                      height: 1.5,
                      color: Colors.black54,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget paginaHistorico() {
    if (historico.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(28),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.history,
                size: 65,
                color: CanagroApp.verde,
              ),
              SizedBox(height: 16),
              Text(
                'Nenhuma análise nesta sessão',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8),
              Text(
                'Quando você analisar uma foto, o resultado aparecerá aqui.',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text(
          'Histórico desta sessão',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 14),
        for (final resultado in historico)
          Card(
            child: ListTile(
              leading: const CircleAvatar(
                backgroundColor: CanagroApp.verdeClaro,
                child: Icon(
                  Icons.eco,
                  color: CanagroApp.verde,
                ),
              ),
              title: Text(resultado.classe),
              subtitle: Text(
                'Confiança estimada: '
                '${(resultado.confianca * 100).toStringAsFixed(1)}%',
              ),
            ),
          ),
        const SizedBox(height: 12),
        const Text(
          'Este histórico existe apenas enquanto o aplicativo permanece '
          'aberto; ainda não é salvo permanentemente.',
          style: TextStyle(
            color: Colors.black54,
            fontSize: 13,
          ),
        ),
      ],
    );
  }

  Widget paginaPerfil() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const SizedBox(height: 20),
        const CircleAvatar(
          radius: 48,
          backgroundColor: CanagroApp.verdeClaro,
          child: Icon(
            Icons.person,
            size: 55,
            color: CanagroApp.verde,
          ),
        ),
        const SizedBox(height: 16),
        const Center(
          child: Text(
            'Meu perfil',
            style: TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 24),
        const Card(
          child: ListTile(
            leading: Icon(Icons.info_outline),
            title: Text('Sobre o CANAGRO'),
            subtitle: Text(
              'Aplicativo experimental de apoio à identificação '
              'de problemas na cana-de-açúcar.',
            ),
          ),
        ),
        const Card(
          child: ListTile(
            leading: Icon(Icons.security_outlined),
            title: Text('Conta demonstrativa'),
            subtitle: Text(
              'O login e o cadastro ainda não estão conectados '
              'a um sistema de contas.',
            ),
          ),
        ),
        const SizedBox(height: 20),
        OutlinedButton.icon(
          onPressed: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (_) => const TelaAcesso(),
              ),
              (route) => false,
            );
          },
          icon: const Icon(Icons.logout),
          label: const Text('Sair'),
        ),
      ],
    );
  }
}

class Cartao extends StatelessWidget {
  final IconData icone;
  final String titulo;
  final String descricao;
  final VoidCallback aoTocar;

  const Cartao({
    super.key,
    required this.icone,
    required this.titulo,
    required this.descricao,
    required this.aoTocar,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: CanagroApp.verdeClaro,
          child: Icon(icone, color: CanagroApp.verde),
        ),
        title: Text(
          titulo,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 5),
          child: Text(descricao),
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: aoTocar,
      ),
    );
  }
}
