
import json
from pathlib import Path

import torch
from PIL import Image
from torchvision import models, transforms
from torchvision.models import ResNet18_Weights

PASTA = Path(r"C:\Users\Windows\Desktop\Canagro_1\canagro")
PASTA_RESULTADO = PASTA / "treinamento" / "resultado"
ARQUIVO_MODELO = PASTA_RESULTADO / "canagro_modelo.pth"
ARQUIVO_CLASSES = PASTA_RESULTADO / "classes.json"

if not ARQUIVO_MODELO.exists() or not ARQUIVO_CLASSES.exists():
    print("ERRO: não encontrei os arquivos do modelo.")
    raise SystemExit(1)

with open(ARQUIVO_CLASSES, "r", encoding="utf-8") as arquivo:
    dados_classes = json.load(arquivo)

if isinstance(dados_classes, dict):
    classes = list(dados_classes.keys())
else:
    classes = dados_classes

# Usar a mesma arquitetura e normalização do treinamento
modelo = models.resnet18(weights=None)
modelo.fc = torch.nn.Linear(modelo.fc.in_features, len(classes))

estado = torch.load(
    ARQUIVO_MODELO,
    map_location="cpu",
    weights_only=True
)
modelo.load_state_dict(estado["estado_modelo"])
modelo.eval()

transformacao = transforms.Compose([
    transforms.Resize((224, 224)),
    transforms.ToTensor(),
    transforms.Normalize(
        mean=[0.485, 0.456, 0.406],
        std=[0.229, 0.224, 0.225]
    )
])

print("\n=== TESTE DO MODELO CANAGRO ===")
caminho = input("Cole o caminho completo da foto e pressione Enter:\n").strip().strip('"')
foto = Path(caminho)

if not foto.is_file():
    print("ERRO: não encontrei essa foto. Confira o caminho.")
    raise SystemExit(1)

try:
    imagem = Image.open(foto).convert("RGB")
    entrada = transformacao(imagem).unsqueeze(0)

    with torch.no_grad():
        saida = modelo(entrada)
        probabilidades = torch.softmax(saida, dim=1)[0]

    indices = torch.argsort(probabilidades, descending=True)

    print("\nResultados do modelo:")
    for indice in indices:
        i = indice.item()
        print(f"{classes[i]}: {probabilidades[i].item() * 100:.1f}%")

    print(
        "\nATENÇÃO: esses percentuais representam a confiança relativa "
        "do modelo, não a garantia de que o diagnóstico esteja correto."
    )

except Exception as erro:
    print(f"Não foi possível analisar a imagem: {erro}")
