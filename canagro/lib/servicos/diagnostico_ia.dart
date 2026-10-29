
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter_onnxruntime/flutter_onnxruntime.dart';
import 'package:image/image.dart' as img;

class ResultadoDiagnostico {
  final String classe;
  final double confianca;

  const ResultadoDiagnostico({
    required this.classe,
    required this.confianca,
  });
}

class DiagnosticoIA {
  DiagnosticoIA._();

  static final DiagnosticoIA instancia = DiagnosticoIA._();

  static const List<String> classes = [
    'Broca-da-cana',
    'Cana saudável',
    'Carvão da cana',
    'Cigarrinha-da-cana',
    'Mosaico da cana',
  ];

  OnnxRuntime? _runtime;
  OrtSession? _sessao;

  Future<void> inicializar() async {
    if (_sessao != null) return;

    _runtime = OnnxRuntime();

    _sessao = await _runtime!.createSessionFromAsset(
      'assets/models/canagro_modelo.onnx',
    );
  }

  Future<ResultadoDiagnostico> analisarFoto(Uint8List bytes) async {
    await inicializar();

    final original = img.decodeImage(bytes);

    if (original == null) {
      throw Exception('Não foi possível abrir essa imagem.');
    }

    final imagem = img.copyResize(
      original,
      width: 224,
      height: 224,
      interpolation: img.Interpolation.linear,
    );

    final dados = Float32List(3 * 224 * 224);

    const medias = [0.485, 0.456, 0.406];
    const desvios = [0.229, 0.224, 0.225];

    for (int y = 0; y < 224; y++) {
      for (int x = 0; x < 224; x++) {
        final pixel = imagem.getPixel(x, y);
        final indice = y * 224 + x;

        dados[indice] =
            (pixel.r.toDouble() / 255.0 - medias[0]) / desvios[0];

        dados[224 * 224 + indice] =
            (pixel.g.toDouble() / 255.0 - medias[1]) / desvios[1];

        dados[2 * 224 * 224 + indice] =
            (pixel.b.toDouble() / 255.0 - medias[2]) / desvios[2];
      }
    }

    final entrada = await OrtValue.fromList(
      dados,
      [1, 3, 224, 224],
    );

    Map<String, OrtValue>? saidas;

    try {
      saidas = await _sessao!.run({'imagem': entrada});

      final tensor = saidas['resultados'];

      if (tensor == null) {
        throw Exception('O modelo não retornou resultados.');
      }

      final valores = (await tensor.asFlattenedList())
          .map((v) => (v as num).toDouble())
          .toList();

      if (valores.length != classes.length) {
        throw Exception('Quantidade inesperada de resultados.');
      }

      final maior = valores.reduce(math.max);

      final probabilidades = valores
          .map((v) => math.exp(v - maior))
          .toList();

      final soma = probabilidades.fold<double>(
        0,
        (total, valor) => total + valor,
      );

      int melhor = 0;

      for (int i = 1; i < probabilidades.length; i++) {
        if (probabilidades[i] > probabilidades[melhor]) {
          melhor = i;
        }
      }

      return ResultadoDiagnostico(
        classe: classes[melhor],
        confianca: probabilidades[melhor] / soma,
      );
    } finally {
      await entrada.dispose();

      if (saidas != null) {
        for (final tensor in saidas.values) {
          await tensor.dispose();
        }
      }
    }
  }

  Future<void> fechar() async {
    if (_sessao != null) {
      await _sessao!.close();
      _sessao = null;
    }
  }
}
